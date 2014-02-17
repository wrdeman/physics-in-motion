//
//  ViewController.m
//  MovEd
//
//  Created by Simon Osborne on 03/02/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import "com_gmail_simonwosborneViewController.h"


#define kxaxis 0
#define kyaxis 1
#define calibShots 10
#define FPS 30
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

#include <vector>
#include <algorithm>
#include <iostream>
#include "CVProcessing.h"
#include "CVPlotting.h"

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

/*!
 add the point to be tracked - triggered from single tap
 will not work when calbrating the camera
 */
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
/*!
 add an origin - triggered from long press
 */
- (void) addOrigin:(UILongPressGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //To get location of the gesture
        CGPoint location = [recognizer locationInView:self.imageView1];
        //convert NSNumber to int
        int x =[[NSNumber numberWithInteger:location.x] intValue];
        int y =[[NSNumber numberWithInteger:location.y] intValue];
        self.process->cvOrigin(x,y,(int)self.imageView1.bounds.size.width, (int)self.imageView1.bounds.size.height);
        //declare new points
        self.newOrigin=true;
    }
}
/*!
 delete a tracked pointed
 */
- (void) deletePoint:(UITapGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //remove last point from vector in instance of CVProcessing
        self.process->cvDeletePoint();
        self.process->resetPlotPoints();
    }
}
/*!
 delete the origin
 */
- (void) deleteOrigin:(UIPinchGestureRecognizer *)recognizer
{
    if(!self.calibratingCamera){
        //remove last point from vector in instance of CVProcessing
        self.process->cvDeleteOrigin();
        self.newOrigin=false;
    }
}
/*!
 returns an integer 1,2,3,4 which informs CVPlotting where to plot the graph
 triggered from swipe gestures
 */
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


#pragma mark - UI Actions

/*!
 get action to switch around the camera output
 */
- (IBAction)actionCamera:(id)sender {
    [self.videoCamera switchCameras];
}
/*!
 get action to start or stop the camera
 */
- (IBAction)actionPausePlay:(id)sender {
    NSLog(@"run = %d",self.runVideo);
    if (self.runVideo){
        [self.videoCamera stop];
        self.runVideo = FALSE;
    }
    else{
        [self.videoCamera start];
        self.runVideo = TRUE;
        
    }
}

/*!
 get action to display the picker that enables the axis to be selected
 */
- (IBAction)showPicker:(id)sender {
    if (self.pickerView) self.pickerView.hidden = !self.pickerView.hidden;
}

/*!
 get action to display the message to allow input of size of chessboards
 */
- (IBAction)scale:(id)sender {
    if (calibCameraDone){
        self.scaleText.hidden = !self.scaleText.hidden;
        self.scaleSubmit.hidden = !self.scaleSubmit.hidden;
        self.scaleLabel.hidden = !self.scaleLabel.hidden;
    }
}

/*!
 get action accept the size of the chess board square
 */
-(IBAction)scaleSubmit:(id)sender{
    if (self.scaleText.keyboardType == UIKeyboardTypeNumberPad){
        if (self.scaleText) self.scaleText.hidden = !self.scaleText.hidden;
        if (self.scaleSubmit) self.scaleSubmit.hidden = !self.scaleSubmit.hidden;
        if (self.scaleLabel) self.scaleLabel.hidden = !self.scaleLabel.hidden;
        self.btnCalib.title = @"Take Scale";
    }
    else{
        self.scaleLabel.text =  @"Error: try again";
    }
}

/*!
 get action to reset the array of tracked points
 */
- (IBAction)resetArray:(id)sender{
    self.process->CVPlotting::resetPlotPoints();
}

/*!
 get action to calibrate the camera output
  
 here there are 3 stages:
 1) initiating the calibrating -> alert view informing 10 shots needed
 2) taking the 10 shots
 3) done -> allows to take shot for calibrating square size
 */
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

 
 
/*!
 get action of alertview re the calibration of the camera
 */
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

/*!
 this switches the orientation 
 commented out for the time being
 */

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeLeft;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL) shouldAutorotate{

    return YES;
}



- (void)viewDidLoad
{
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
    
    [super viewDidLoad];
    
    //declare the gestures
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
    
    
    //set the imageview to accept gestures
    self.imageView1.userInteractionEnabled = YES;
    self.imageView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    //tracking and plotting variables
    //default plot position
    self.plotModifierValue = 2;
    //instatiated Plotting and Processing Class
    self.process = new CVPlotting();
    
    //default flags and counters
    self.newPoints = false;
    self.newOrigin = false;
    axisArray = [NSArray arrayWithObjects:@"time", @"x", @"y", @"A", @"dA/dt", @"Ø", @"dØ/dt", nil];
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

-(CVPlotting*) getProcess{
    return self.process;
}

#pragma mark
#pragma mark Picker Data Source Methods
//methods to get the axis from the picker views
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

//the c++ methods that do the processing
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
            }
        }
        //else still calibrating camera and 
        else{
            double rms = self.calib->calibrate(image.size());
            self.calibratingCamera = false;
            self.calibCameraDone = true;
        }
    }
    //if done calibrating the remap the image
    if (self.calibCameraDone){
        self.calib->reMap(image);
        //if a number of the scale is entered and the chess scale not yet set
        //need an error message
         if (self.calibCameraShot){
                self.scaleNumChess =self.calib->getScale(image);
             self.calibCameraShot = false;
        }
    }
    //calc the time difference
    double time_old = self.time;
    self.time = CACurrentMediaTime();

    //track the points
    //if new add and reset newpoints to false
    self.process->cvTracking(image , newPoints, (int)self.imageView1.bounds.size.width, (int)self.imageView1.bounds.size.height);
    self.newPoints = false;

    //we have tracked points then plot the data
    if (self.process->cvTrackedPoints()>0){
        self.process->setPlotPoints(self.time-time_old);
        //fraction of available screen 44 is the height
        //according to the storyboard for ipad and iphone
        float availableScreen= 1. - (44./self.imageView1.bounds.size.height);
        self.process->plotData(image,self.plotModifierValue, self.axisx, self.axisy, availableScreen);
    }
    
}
#endif


@end
