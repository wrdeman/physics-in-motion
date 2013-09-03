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
@synthesize btnStart;
@synthesize btnPauseStart;
@synthesize btnCamera;
@synthesize videoCamera;
@synthesize process;
@synthesize newPoints;
@synthesize runVideo;
@synthesize plotModifierValue;

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
- (void) deletePoint:(UITapGestureRecognizer *)recognizer
{
    //remove last point from vector in instance of CVProcessing
    self.process->cvDeletePoint();
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

- (IBAction)star:(id)sender {
}

- (IBAction)actionStart:(id)sender {
    [self.videoCamera start];
    self.btnStart.hidden = YES;
    self.btnPauseStart.hidden = FALSE;
    self.runVideo = TRUE;
}

- (IBAction)actionStopStart:(id)sender {
    if (self.runVideo){
        [self.videoCamera stop];
        self.runVideo = FALSE;
        [btnPauseStart setImage:[UIImage imageNamed:@"playone.png"] forState:UIControlStateNormal];
    }
    else{
        [self.videoCamera start];
        self.runVideo = TRUE;
        [btnPauseStart setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];

    }
}

- (IBAction)actionCamera:(id)sender {
    [self.videoCamera switchCameras];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //-----------------------------------------tap gestures-------------------------------------------------------------------------
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPoint:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletePoint:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    doubleTap.delegate = self;

    //-----------------------------------------swipe gestures-----------------------------------------------------------------------
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    leftSwipe.delegate=self;
    
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    rightSwipe.delegate=self;

    UISwipeGestureRecognizer *upSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    upSwipe.direction=UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
    upSwipe.delegate=self;
    
    UISwipeGestureRecognizer *downSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(plotModifier:)];
    downSwipe.direction=UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:downSwipe];
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
    
    //tracking and plotting variables
    self.plotModifierValue = 2;
    self.process = new CVPlotting();
    self.newPoints = false;


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

#pragma mark - InterfaceOrientation iOS 6
/*
- (BOOL)shouldAutorotate{
    return YES;
}*/

#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    
    self.process->cvTracking(image , newPoints);
    self.newPoints = false;
    if (self.process->cvTrackedPoints()>0){
        self.process->setPlotPoints();
        self.process->plotData(image,self.plotModifierValue);
    }
}
#endif


@end
