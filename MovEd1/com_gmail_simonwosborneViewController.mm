//
//  ViewController.m
//  MovEd
//
//  Created by Simon Osborne on 03/02/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import "com_gmail_simonwosborneViewController.h"
#include <vector>
#include <iostream>
using namespace std;

@interface com_gmail_simonwosborneViewController ()

@end

@implementation com_gmail_simonwosborneViewController
@synthesize imageView1;
@synthesize videoCamera;
@synthesize pos=_pos;
@synthesize newPoints;
@synthesize previous;


#pragma - Private Methods
- (void) addPoint:(UITapGestureRecognizer *)recognizer
{
    //To get location of the gesture
    CGPoint location = [recognizer locationInView:self.imageView1];
    
    [self.pos addObject:[NSNumber numberWithInteger:location.x]];
    [self.pos addObject:[NSNumber numberWithInteger:location.y]];
    self.newPoints=true;
}
- (void) deletePoint:(UITapGestureRecognizer *)recognizer
{
    //To get location of the gesture
    
    [self.pos removeLastObject];
    [self.pos removeLastObject];
    self.newPoints=false;
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
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.pos = [[NSMutableArray alloc] init];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    Mat gray;
    cvtColor(image, gray, CV_RGBA2GRAY);
    Point2f point;
    vector<Point2f> points[2];
    TermCriteria termcrit(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03);
    cv::Size subPixWinSize(10,10), winSize(31,31);
    int numPts2=[self.pos count]; //number of points is half pos array
    NSLog(@"points = %i ", numPts2);
    if (self.previous.empty())
    {
        self.previous=gray;
    }
    
    if ((numPts2)/2!=0)
    {
        for (int i=0; i<numPts2/2; i++)
        {
            //c++ vector for points
            vector<Point2f> tmp;
            float x=[[self.pos objectAtIndex:2*i] floatValue];
            float y=[[self.pos objectAtIndex:2*i+1] floatValue];
            point = Point2f(float(x),float(y));
            tmp.push_back(point);
            //if a new point the find corners
            if (i==numPts2/2)
            {
                if (self.newPoints==true)
                {
                    cornerSubPix( gray, tmp, winSize, cvSize(-1,-1), termcrit);
                }
            }
            points[0].push_back(tmp[0]);
        }
        vector<uchar> status;
        vector<float> err;
        if (self.previous.empty())
        {
            //NSLog(@"previous is empty");
        }
        else{
            
            calcOpticalFlowPyrLK(self.previous, gray, points[0], points[1], status, err, winSize, 3, termcrit, 0, 0.001);
        }
        size_t i, k;
        for(i = k = 0; i < numPts2/2; i++ )
        {
            if( self.newPoints )
            {
                if( norm(point - points[1][i]) <= 5 )
                {
                    self.newPoints = false;
                    continue;
                }
            }
            if( !status[i] )
                continue;
            
            points[1][k++] = points[1][i];
            circle( image, points[1][i], 3, Scalar(0,255,0), -1, 8);
            point=points[1][i];
            [self.pos replaceObjectAtIndex:2*i withObject:[NSNumber numberWithFloat:point.x]];
            [self.pos replaceObjectAtIndex:(2*i+1) withObject:[NSNumber numberWithFloat:point.y]];
        }
        points[1].resize(k);
    }
    self.previous=gray;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    image=image;
}
#endif

@end
