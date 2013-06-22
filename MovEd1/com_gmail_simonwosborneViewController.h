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

using namespace cv;


@interface com_gmail_simonwosborneViewController : UIViewController<CvVideoCameraDelegate,UIGestureRecognizerDelegate>
{
    CvVideoCamera* videoCamera;
    IBOutlet UIImageView *imageView1;
}
- (IBAction)actionStart:(id)sender;


@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (strong, nonatomic) NSMutableArray *pos;
@property (nonatomic, assign) BOOL newPoints;
@property (nonatomic, retain) IBOutlet UIImageView *imageView1;

@property (nonatomic) Mat previous;
-(void) addPoint;
-(void) deletePoint;
-(void) startVideo;
-(void) stopVideo;
- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation;
-(UIDeviceOrientation)interfaceOrientation;
-(NSInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation;
@end
