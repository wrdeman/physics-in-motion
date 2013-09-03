//
//  com_gmail_simonwosborneViewController.h
//  MovEd1
//
//  Created by Simon on 29/04/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <opencv2/highgui/cap_ios.h>
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"
#import "opencv2/video/tracking.hpp"
#include "CVPlotting.h"

using namespace cv;


@interface com_gmail_simonwosborneViewController : UIViewController<CvVideoCameraDelegate,UIGestureRecognizerDelegate>
{
    CvVideoCamera* videoCamera;
    IBOutlet UIImageView *imageView1;
    IBOutlet UIBarButtonItem *btnPausePlay;
    IBOutlet UIBarButtonItem *btnCamera;
    IBOutlet UIToolbar *toolbar;
}

- (IBAction)actionCamera:(id)sender;
- (IBAction)actionPausePlay:(id)sender;

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, assign) BOOL newPoints;
@property (nonatomic, assign) BOOL newOrigin;
@property (nonatomic, assign) BOOL runVideo;
@property (nonatomic, assign) int plotModifierValue;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCamera;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnPausePlay;
@property (nonatomic, assign) CVPlotting * process;
@property (nonatomic, retain) CALayer *customPreviewLayer;

-(void) addPoint;
-(void) addOrigin;
-(void) deletePoint;
-(void) deleteOrigin;
-(void) plotModifier;

//-(BOOL)shouldAutorotate;
//-(NSInteger)supportedInterfaceOrientations;

@end
