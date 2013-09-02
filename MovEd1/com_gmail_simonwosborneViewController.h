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
    IBOutlet UIButton *btnStart;
    IBOutlet UIButton *btnPauseStart;
    IBOutlet UIButton *btnCamera;
}

- (IBAction)actionStart:(id)sender;
- (IBAction)actionStopStart:(id)sender;
- (IBAction)actionCamera:(id)sender;

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, assign) BOOL newPoints;
@property (nonatomic, assign) BOOL runVideo;
@property (nonatomic, assign) int plotModifierValue;
@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (nonatomic, retain) IBOutlet UIButton * btnStart;
@property (nonatomic, retain) IBOutlet UIButton * btnPauseStart;
@property (nonatomic, retain) IBOutlet UIButton * btnCamera;
@property (nonatomic, assign) CVPlotting * process;
@property (nonatomic, retain) CALayer *customPreviewLayer;

-(void) addPoint;
-(void) deletePoint;
-(void) plotModifier;

//-(BOOL)shouldAutorotate;
//-(NSInteger)supportedInterfaceOrientations;

@end
