//
//  com_gmail_simonwosborneViewController.h
//  MovEd1
//
//  Created by Simon on 29/04/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h> 
#import <opencv2/highgui/cap_ios.h>
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"
#import "opencv2/video/tracking.hpp"
#include "CVPlotting.h"
#include "CVCalib.h"
#import <QuartzCore/CAAnimation.h>

using namespace cv;


@interface com_gmail_simonwosborneViewController : UIViewController<CvVideoCameraDelegate,UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
{
    CvVideoCamera* videoCamera;
    NSArray *axisArray;
    IBOutlet UIImageView *imageView1;
    IBOutlet UIBarButtonItem *btnPausePlay;
    IBOutlet UIBarButtonItem *btnCamera;
    IBOutlet UIBarButtonItem *btnCalib;
    IBOutlet UIBarButtonItem *btnScale;
    IBOutlet UIBarButtonItem *btnFinish;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *showPicker;
    IBOutlet UITextField *scaleText;
    IBOutlet UILabel *scaleLabel;
    IBOutlet UIButton *scaleSubmit;
}


- (IBAction)actionCamera:(id)sender;
- (IBAction)actionPausePlay:(id)sender;
- (IBAction)showPicker:(id)sender;
- (IBAction)resetArray:(id)sender;
- (IBAction)calibCamera:(id)sender;
- (IBAction)scale:(id)sender;
- (IBAction)scaleSubmit:(id)sender;
- (IBAction)finish:(id)sender;

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, assign) BOOL newPoints;
@property (nonatomic, assign) BOOL newOrigin;
@property (nonatomic, assign) BOOL runVideo;
@property (nonatomic, assign) int plotModifierValue;

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCamera;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnPausePlay;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCalib;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnScale;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *showPicker;
@property (strong, nonatomic) IBOutlet UIPickerView * pickerView;
@property (strong, nonatomic) IBOutlet UITextField *scaleText;
@property (strong, nonatomic) IBOutlet UIButton *scaleSubmit;
@property (strong, nonatomic) IBOutlet UILabel *scaleLabel;


@property (nonatomic, assign) CVPlotting * process;
@property (nonatomic, assign) CVCalib * calib;
@property (nonatomic, retain) CALayer *customPreviewLayer;
@property (nonatomic,assign) int axisx;
@property (nonatomic,assign) int axisy;
@property (nonatomic,assign) int calibCameraCount;
@property (nonatomic,assign) bool calibratingCamera;
@property (nonatomic,assign) bool calibCameraShot;
@property (nonatomic, assign) bool calibCameraDone;
@property (nonatomic, assign) float scaleNum;
@property (nonatomic, assign) float scaleNumChess;
@property (nonatomic, assign) double time;


-(void) addPoint;
-(void) addOrigin;
-(void) deletePoint;
-(void) deleteOrigin;
-(void) plotModifier;

@end
