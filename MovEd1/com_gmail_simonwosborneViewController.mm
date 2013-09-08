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
@synthesize toolbar;
@synthesize showPicker;
@synthesize scaleText;

@synthesize videoCamera;
@synthesize process;
@synthesize newPoints;
@synthesize runVideo;
@synthesize plotModifierValue;
@synthesize axisx;
@synthesize axisy;
@synthesize calibCamera;
@synthesize calibCameraShot;

#pragma - Private Methods
- (void) addPoint:(UITapGestureRecognizer *)recognizer
{
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

- (void) addOrigin:(UILongPressGestureRecognizer *)recognizer
{
    //To get location of the gesture
    CGPoint location = [recognizer locationInView:self.imageView1];
    //convert NSNumber to int
    int x =[[NSNumber numberWithInteger:location.x] intValue];
    int y =[[NSNumber numberWithInteger:location.y] intValue];
    self.process->cvOrigin(x,y);
    //declare new points
    self.newOrigin=true;
}

- (void) deletePoint:(UIPinchGestureRecognizer *)recognizer
{
    //remove last point from vector in instance of CVProcessing
    self.process->cvDeletePoint();
}

- (void) deleteOrigin:(UILongPressGestureRecognizer *)recognizer
{
    //remove last point from vector in instance of CVProcessing
    self.process->cvDeleteOrigin();
    self.newOrigin=false;
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
    self.scaleText.hidden = !self.scaleText.hidden;
    self.scaleSubmit.hidden = !self.scaleSubmit.hidden;
    self.scaleLabel.hidden = !self.scaleLabel.hidden;
}

-(IBAction)scaleSubmit:(id)sender{
    
    try{
        NSLog(@"%@",self.scaleText.text);
        float scaleNum = [self.scaleText.text floatValue];
        if (self.scaleText) self.scaleText.hidden = !self.scaleText.hidden;
        if (self.scaleSubmit) self.scaleSubmit.hidden = !self.scaleSubmit.hidden;
        if (self.scaleLabel) self.scaleLabel.hidden = !self.scaleLabel.hidden;
    }
    catch(NSException *e){
        self.scaleLabel.text =  @"something";
    }
}

- (IBAction)resetArray:(id)sender{
    self.process->CVPlotting::resetPlotPoints();
}

- (IBAction)calibCamera:(id)sender{
    if (!calibCamera){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calibrate Camera"
                                                    message:@"Press Calib to take 10 images."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        [alert show];
        self.calib = new CVCalib();
    }
    else{
        self.calibCameraShot = true;
        [self.busy startAnimating];
    }
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (!self.runVideo){
        [self.videoCamera start];
        self.runVideo = TRUE;
    }

    if (buttonIndex == 0) {
        //self.busy = false;
        int left = calibShots-self.calib->countStaticImage;
        self.calibCamera = true;
        self.btnCalib.title = [NSString stringWithFormat:@"%d Left", left];
    }
}

- (void)viewDidLoad
{
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [super viewDidLoad];
    
    
    //-----------------------------------------long tap gesture---------------------------------------------------------------------
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addOrigin:)];
    [self.imageView1 addGestureRecognizer:longPress];
    longPress.delegate = self;
    
    UIPinchGestureRecognizer *pinchPress = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(deleteOrigin:)];
    [self.imageView1 addGestureRecognizer:pinchPress];
    pinchPress.delegate = self;
    
    //-----------------------------------------tap gestures-------------------------------------------------------------------------
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPoint:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageView1 addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletePoint:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.imageView1 addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    doubleTap.delegate = self;

    //-----------------------------------------swipe gestures-----------------------------------------------------------------------
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.imageView1 addGestureRecognizer:leftSwipe];
    leftSwipe.delegate=self;
    
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.imageView1 addGestureRecognizer:rightSwipe];
    rightSwipe.delegate=self;

    UISwipeGestureRecognizer *upSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    upSwipe.direction=UISwipeGestureRecognizerDirectionUp;
    [self.imageView1 addGestureRecognizer:upSwipe];
    upSwipe.delegate=self;
    
    UISwipeGestureRecognizer *downSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    downSwipe.direction=UISwipeGestureRecognizerDirectionDown;
    [self.imageView1 addGestureRecognizer:downSwipe];
    downSwipe.delegate=self;

    //------------------------------------------------------------------------------------------------------------------------------
    
    // camera + video settings (cap_ios.h in opencv frmaework)
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView1];
    self.videoCamera.delegate=self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    [self.videoCamera.captureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    self.videoCamera.defaultFPS = 30;
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
    self.calibCamera = false;
    self.calibCameraShot = false;
    [self.busy stopAnimating];
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
    if (self.calibCamera && self.calibCameraCount < calibShots){
        if ( self.calibCameraShot ){
            self.calib->takeStaticImage(image);
            self.calibCameraCount = self.calib->countStaticImage;
            self.calibCameraShot = false;
        }
    }
    else if (self.calibCamera && self.calibCameraCount == calibShots){
        double rms = self.calib->calibrate(image.size());
        self.calibCamera = false;
    }
    [self.busy stopAnimating];
    
    if (self.calibCamera == false && self.calibCameraCount == calibShots){
        self.calib->reMap(image);
    }
    self.process->cvTracking(image , newPoints);
    self.newPoints = false;
    if (self.process->cvTrackedPoints()>0){
        self.process->setPlotPoints();
        self.process->plotData(image,self.plotModifierValue, self.axisx, self.axisy);
    }
    
}
#endif


@end
