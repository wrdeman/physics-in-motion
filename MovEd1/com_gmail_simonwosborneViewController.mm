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
@synthesize videoCamera;
@synthesize process;
@synthesize newPoints;
@synthesize previous;


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

- (BOOL) isPad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
    return NO;
}

#pragma mark - UI Actions
- (IBAction)startVideo:(id)sender {
    [self.videoCamera start];
}
- (IBAction)stopVideo:(id)sender {
    [self.videoCamera stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Instantiate a tap gesture recognizer
    self.newPoints=false;
    
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
    
    UISwipeGestureRecognizer *leftSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(startVideo:)];
    leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    leftSwipe.delegate=self;
    
    UISwipeGestureRecognizer *rightSwipe=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(stopVideo:)];
    rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    rightSwipe.delegate=self;
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView1];
    self.videoCamera.delegate=self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
//    //self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    
    [self.videoCamera.captureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    //self.videoCamera.videoCaptureConnection.supportsVideoOrientation =
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    //self.pos = [[NSMutableArray alloc] init];
 
    self.process = new CVPlotting();
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
    return NO;
}
*/
#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    
    self.process->cvTracking(image , newPoints);
    self.newPoints = false;
    if (self.process->cvTrackedPoints()>0){
        self.process->setPlotPoints();
        self.process->plotData(image);
    }
    // cv::circle(image, cv::Point2f(10,10), 5, cv::Scalar(0,255,0), -1, 8);
  //  image = self.process->testCV(image);

}
#endif

@end
