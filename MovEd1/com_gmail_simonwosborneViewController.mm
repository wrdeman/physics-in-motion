//
//  ViewController.m
//  MovEd
//
//  Created by Simon Osborne on 03/02/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import "com_gmail_simonwosborneViewController.h"

#define SCALING_FACTOR_X (1024.0/480.0)
#define SCALING_FACTOR_Y (768.0/360.0)
#define IPAD_X 1024
#define IPAD_Y 768

#define kxaxis 0
#define kyaxis 1
#define calibShots 10
#define FPS 30


#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

#include <vector>
#include <algorithm>
#include <iostream>
#include "CVProcessing.h"
#include "CVPlotting.h"

using namespace std;

@interface com_gmail_simonwosborneViewController ()

@end

@implementation com_gmail_simonwosborneViewController
@synthesize imageView1;
@synthesize btnCamera;
@synthesize btnPausePlay;
@synthesize btnCalib;
@synthesize btnScale;
@synthesize toolbar;
@synthesize showPicker;
@synthesize scaleText;
@synthesize scaleNum;
@synthesize scaleNumChess;

@synthesize videoCamera;
@synthesize process;
@synthesize newPoints;
@synthesize runVideo;
@synthesize plotModifierValue;
@synthesize axisx;
@synthesize axisy;
@synthesize calibratingCamera;
@synthesize calibCameraShot;
@synthesize calibCameraDone;

#pragma - Private Methods
- (void) addPoint:(UITapGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //To get location of the gesture
        CGPoint location = [recognizer locationInView:self.imageView1];
        //convert NSNumber to int
        int x =[[NSNumber numberWithInteger:location.x] intValue];
        int y =[[NSNumber numberWithInteger:location.y] intValue];
        //send to CVProcessing instance    
        self.process->cvNewPoint(x,y);
        //declare new points
        self.newPoints=true;
    }
}

- (void) addOrigin:(UILongPressGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //To get location of the gesture
        CGPoint location = [recognizer locationInView:self.imageView1];
        //convert NSNumber to int
        int x =[[NSNumber numberWithInteger:location.x] intValue];
        int y =[[NSNumber numberWithInteger:location.y] intValue];
        self.process->cvOrigin(x,y);
        //declare new points
        self.newOrigin=true;
    }
}

- (void) deletePoint:(UIPinchGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //remove last point from vector in instance of CVProcessing
        self.process->cvDeletePoint();
    }
}

- (void) deleteOrigin:(UILongPressGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //remove last point from vector in instance of CVProcessing
        self.process->cvDeleteOrigin();
        self.newOrigin=false;
    }
}

-(void) plotModifier:(UISwipeGestureRecognizer *)gesture
{
/*  get the gesture and assign a value
    positions of plot are
    -----
    |1|2|
    -----
    |3|4|
    -----
*/
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if (self.plotModifierValue%2 == 0){
            self.plotModifierValue -= 1;
        }
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if (self.plotModifierValue%2 == 1){
            self.plotModifierValue += 1;
        }
    }
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp)
    {
        if (self.plotModifierValue >=3){
            self.plotModifierValue -= 2;
        }
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionDown)
    {
        if (self.plotModifierValue <=2){
            self.plotModifierValue += 2;
        }
    }
}

- (BOOL) isPad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
    return NO;
}

#pragma mark - UI Actions


- (IBAction)actionCamera:(id)sender {
    [self.videoCamera switchCameras];
}

- (IBAction)actionPausePlay:(id)sender {
    if (self.runVideo){
        [self.videoCamera stop];
        self.runVideo = FALSE;
    }
    else{
        [self.videoCamera start];
        self.runVideo = TRUE;
        
    }
}

- (IBAction)showPicker:(id)sender {
    if (self.pickerView) self.pickerView.hidden = !self.pickerView.hidden;
}

- (IBAction)scale:(id)sender {
    if (calibCameraDone){
        self.scaleText.hidden = !self.scaleText.hidden;
        self.scaleSubmit.hidden = !self.scaleSubmit.hidden;
        self.scaleLabel.hidden = !self.scaleLabel.hidden;
    }
}

-(IBAction)scaleSubmit:(id)sender{
    if (self.scaleText.keyboardType == UIKeyboardTypeNumberPad){
        NSLog(@"%@",self.scaleText.text);
        if (self.scaleText) self.scaleText.hidden = !self.scaleText.hidden;
        if (self.scaleSubmit) self.scaleSubmit.hidden = !self.scaleSubmit.hidden;
        if (self.scaleLabel) self.scaleLabel.hidden = !self.scaleLabel.hidden;
        //self.scaleLabel.text =  @"Take chessboard image";
        self.btnCalib.title = @"Take Scale";
    }
    else{
        self.scaleLabel.text =  @"Error: try again";
    }
}

- (IBAction)resetArray:(id)sender{
    self.process->CVPlotting::resetPlotPoints();
}

- (IBAction)calibCamera:(id)sender{

    if(!calibCameraDone){
        if (!calibratingCamera){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Calibrate Camera"
                                  message:@"Press Calib to take 10 images."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            self.calib = new CVCalib();
        }
        else{
            self.calibCameraShot = true;
            int left = calibShots-self.calib->countStaticImage-1;
            if (left != 1){
                self.btnCalib.title = [NSString stringWithFormat:@"%d Left", left];
            }
            else{
                self.btnCalib.title = @"Done";
            }
        }
    }
    else{
        
        self.calibCameraShot = true;
    }
}

- (IBAction) finish:(id)sender{
    if(![MFMailComposeViewController canSendMail]){
        NSString *errorTitle = @"Error";
        NSString *errorString = @"Not configured to send mail";
        UIAlertView * errorView = [[UIAlertView alloc]
                                   initWithTitle:errorTitle
                                   message:errorString
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"OK", nil];
        [errorView show];
    }
    else{
        NSString* result = [NSString stringWithUTF8String:self.process->outputData(self.scaleNum,self.scaleNumChess,(1./FPS)).c_str()];
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:@"Data"];
        [mailView setMessageBody:result isHTML:NO];
        [self presentViewController:mailView animated:YES completion:NULL];
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(error){
        NSString * errorTitle = @"Mail Error";
        NSString * errorDescription = [error localizedDescription];
        UIAlertView *errorView = [[UIAlertView alloc]
                                  initWithTitle:errorTitle
                                  message:errorDescription
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil
                                  ];
        [errorView show];
    }else{
        
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (!self.runVideo){
        [self.videoCamera start];
        self.runVideo = TRUE;
    }

    if (buttonIndex == 0) {
        //self.busy = false;
        int left = calibShots-self.calib->countStaticImage;
        self.calibratingCamera = true;
        self.btnCalib.title = [NSString stringWithFormat:@"%d Left", left];
    }
}

- (void)viewDidLoad
{
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [super viewDidLoad];
    
    
    //--------------------long tap gesture---------------------------------
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(addOrigin:)];
    [self.imageView1 addGestureRecognizer:longPress];
    longPress.delegate = self;
    
    UIPinchGestureRecognizer *pinchPress = [[UIPinchGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(deleteOrigin:)];
    [self.imageView1 addGestureRecognizer:pinchPress];
    pinchPress.delegate = self;
    
    //-----------------tap gestures------------------------------
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(addPoint:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageView1 addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(deletePoint:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.imageView1 addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    doubleTap.delegate = self;

    //----------------------swipe gestures--------------------------------
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(plotModifier:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.imageView1 addGestureRecognizer:leftSwipe];
    leftSwipe.delegate=self;
    
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(plotModifier:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.imageView1 addGestureRecognizer:rightSwipe];
    rightSwipe.delegate=self;

    UISwipeGestureRecognizer *upSwipe=[[UISwipeGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(plotModifier:)];
    upSwipe.direction=UISwipeGestureRecognizerDirectionUp;
    [self.imageView1 addGestureRecognizer:upSwipe];
    upSwipe.delegate=self;
    
    UISwipeGestureRecognizer *downSwipe=[[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(plotModifier:)];
    downSwipe.direction=UISwipeGestureRecognizerDirectionDown;
    [self.imageView1 addGestureRecognizer:downSwipe];
    downSwipe.delegate=self;

    //-----------------------------------------------------------------------------------------------
    
    
    // camera + video settings (cap_ios.h in opencv frmaework)
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView1];
    self.videoCamera.delegate=self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    [self.videoCamera.captureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    self.videoCamera.defaultFPS = FPS;
    self.videoCamera.grayscaleMode = NO;
    self.imageView1.userInteractionEnabled = YES;
    //tracking and plotting variables
    self.plotModifierValue = 2;
    self.process = new CVPlotting();
    
    self.newPoints = false;
    self.newOrigin = false;
    axisArray = [NSArray arrayWithObjects:@"time", @"x", @"y",@"Ø", @"dØ/dt", @"A", @"dA/dt", nil];
    self.axisx = 1;
    self.axisy = 2;
    self.calibCameraCount = 0;
    self.calibratingCamera = false;
    self.calibCameraShot = false;
    self.calibCameraDone = false;
    self.scaleNumChess = 0;
    self.scaleNum = 0;
    self.time = CACurrentMediaTime();
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    //depreacted in IOS6
    // Release any retained subviews of the main view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark Picker Data Source Methods
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
//both the same length
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [axisArray count];
}

-(NSString *)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == kxaxis)
        return [axisArray objectAtIndex:row];
    return [axisArray objectAtIndex:row];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == kxaxis){
        self.axisx = row;
    }
    if (component == kyaxis){
        self.axisy = row;
    }
}


#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    //if calibrating the camera and #remaining shot count not zero
    if (self.calibratingCamera){
        if(calibShots-self.calib->countStaticImage-1 != 0){
            //if shot is required
            if ( self.calibCameraShot ){
                self.calib->takeStaticImage(image);
                self.calibCameraCount = self.calib->countStaticImage;
                self.calibCameraShot = false;
                NSLog(@"count = %d",self.calibCameraCount);
            }
        }
        //else still calibrating camera and 
        else{
            double rms = self.calib->calibrate(image.size());
            self.calibratingCamera = false;
            self.calibCameraDone = true;
        }
    }
    if (self.calibCameraDone){
        self.calib->reMap(image);
        //if a number of the scale is entered and the chess scale not yet set
        //need an error message
         if (self.calibCameraShot){
                self.scaleNumChess =self.calib->getScale(image);
             self.calibCameraShot = false;
        }
    }
    double time_old = self.time;
    self.time = CACurrentMediaTime();
    self.process->cvTracking(image , newPoints);
    self.newPoints = false;
    if (self.process->cvTrackedPoints()>0){
        self.process->setPlotPoints(self.time-time_old);
//        std::cout<<time_old-self.time<<std::endl;
        self.process->plotData(image,self.plotModifierValue, self.axisx, self.axisy);
    }
    
}
#endif


@end
