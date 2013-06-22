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

-(UIDeviceOrientation)interfaceOrientation
{
    return [[UIDevice currentDevice] orientation];
}

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation
 {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
 }

-(NSInteger)supportedInterfaceOrientations{
    
    //    UIInterfaceOrientationMaskLandscape;
    //    24
    //
    //    UIInterfaceOrientationMaskLandscapeLeft;
    //    16
    //
    //    UIInterfaceOrientationMaskLandscapeRight;
    //    8
    //
    //    UIInterfaceOrientationMaskPortrait;
    //    2
    
    //    return UIInterfaceOrientationMaskPortrait;
    //    or
    return UIInterfaceOrientationMaskLandscape;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#ifdef __cplusplus
-(void)processImage:(Mat&)image;
{
    /*
     iOS
   (0,0)       (0,1000)
     -------------
     |           |
 cam |           | button
     |           |
     -------------
 (700,0)     (700,1000)
     
     
     opencv
   (w,0)        (w,l)
     -------------
     |           |
 cam |           | button
     |           |
     -------------
   (0,0)       (0,l)
     
     */
    Mat gray;
    cvtColor(image, gray, CV_RGBA2GRAY);
    Point2f point;
    vector<Point2f> points[2];
    static vector<Point2f> plotPoints;
    TermCriteria termcrit(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03);
    cv::Size subPixWinSize(10,10), winSize(31,31);
    int numPts2=[self.pos count]; //number of points is half pos array
    
    int lenYAxis,lenXAxis,axisX1,axisX2,axisY1,axisY2;
    cv::Size cvwidlen=image.size();

    vector<uchar> status;
    vector<float> err;
    
    int maxx=0;
    int minx=10000;
    int maxy=0;
    int miny=10000;
    
    //if there are points stored in vector
    if ((numPts2)/2>1){
        //loop through the points
        for (int i=0; i<numPts2/2; i++){
            //define a c++ vector for points needed for opencv
            vector<Point2f> tmp;
            //these are the ipad points
            float x=[[self.pos objectAtIndex:2*i] floatValue];
            float y=[[self.pos objectAtIndex:2*i+1] floatValue];
            //invert the x-axis around
            x=IPAD_X-x;
            if (x<minx){minx=int(x);}
            if (x>maxx){maxx=int(x);}
            if (y<miny){miny=int(y);}
            if (y>maxy){maxy=int(y);}
            
            minx=(cvwidlen.width*minx/IPAD_X);
            maxx=(cvwidlen.width*maxx/IPAD_X);
            miny=(cvwidlen.height*miny/IPAD_Y);
            maxy=(cvwidlen.height*maxy/IPAD_Y);
            
            NSLog(@"nax %d %d %d %d",minx,maxx,miny,maxy);
//            NSLog(@"x  = %e y = %e",x,y);
            
            //these are the points that go into opencv
            point = Point2f(float(cvwidlen.width*x/IPAD_X),float(cvwidlen.height*y/IPAD_Y));
            tmp.push_back(point);
            //if a new point the find corners - the last points CHECK
            if (i==numPts2/2){
                if (self.newPoints==true){
                    cornerSubPix( gray, tmp, winSize, cvSize(-1,-1), termcrit);
                }
            }
            points[0].push_back(tmp[0]);
        }//end looping through the points

        
        if (!self.previous.empty()){
            calcOpticalFlowPyrLK(self.previous, gray, points[0], points[1], status, err, winSize, 3, termcrit,      0, 0.001);
        }
        size_t i, k;
        bool flag=true;
        for(i = k = 0; i < numPts2/2; i++ ){
            if( self.newPoints ){
                if( norm(point - points[1][i]) <= 5 ){
                    self.newPoints = false;
                    continue;
                }
            }
            if( !status[i] )
                continue;
            
            points[1][k++] = points[1][i];
            circle( image, points[1][i], 3, Scalar(0,255,0), -1, 8);
            point=points[1][i];
            if (flag==true){
                //should only get the first point
                if (plotPoints.size()>1000){
                    //to limit size to 1000 
                    plotPoints.erase  (plotPoints.begin()+0);
                }
                plotPoints.push_back(point);
                flag=false;
            }
            //update iOS array - so convert the points back into there iOS format
            [self.pos replaceObjectAtIndex:2*i withObject:[NSNumber numberWithFloat:(IPAD_X-IPAD_X*point.x/cvwidlen.width)]];
            [self.pos replaceObjectAtIndex:(2*i+1) withObject:[NSNumber numberWithFloat:IPAD_Y*point.y/cvwidlen.height]];
        }
        points[1].resize(k);
    }//end if num_pts/2!=1
    self.previous=gray;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    lenXAxis = int((cvwidlen.width-0)/2);
    lenYAxis = int((cvwidlen.height-0)/3);
    axisY1 = float(lenYAxis);
    axisY2 = float(lenYAxis+(lenYAxis*0.9));
    axisX1 = float(lenXAxis*0.1);
    axisX2 = float(lenXAxis);
    //#opencv lengths of axis
    int dy = int((lenYAxis+lenYAxis*0.9)-lenYAxis);
    int dx = int(lenXAxis - (lenXAxis*0.1));

    //#define axes
 
    if ( ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)) {
        //       NSLog(@"portrait");
        cv::line(image,Point2f(axisY1,axisX1),Point2f(axisY1,axisX2),(255,0,0),1);
        cv::line(image,Point2f(axisY1,axisX1),Point2f(axisY2,axisX1),(255,0,0),1);
        
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
        //coordinates re y,x
        cv::line(image,Point2f(axisY2,axisX2),Point2f(axisY2,axisX1),(255,0,0),1);
        cv::line(image,Point2f(axisY2,axisX2),Point2f(axisY1,axisX2),(255,0,0),1);
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        //coordinates are y,x
        cv::line(image,Point2f(axisY1,axisX1),Point2f(axisY1,axisX2),(255,0,0),1);
        cv::line(image,Point2f(axisY1,axisX1),Point2f(axisY2,axisX1),(255,0,0),1);
    }
    
    if (self.previous.empty()){
        self.previous=gray;
    }
    
/*    lenXAxis = int((cvwidlen.width-0)/2);
    lenYAxis = int((cvwidlen.height-0)/3);
    axisY1 = float(lenYAxis);
    axisY2 = float(lenYAxis+(lenYAxis*0.9));
    axisX1 = float(lenXAxis*0.1);
    axisX2 = float(lenXAxis);
    //#opencv lengths of axis
    int dx = int((lenXAxis+lenXAxis*0.9)-lenXAxis);
    int dy = int(lenYAxis - (lenYAxis*0.1));
*/
    int xdat,ydat,x_cv1,y_cv1,x_cv2,y_cv2;
    
    xdat=0;
    minx=0;
    maxx=numPts2/2;
    
    
    if ((numPts2/2) > 1){
    for (int i=0;i<(plotPoints.size());i++){
        //xdat=points[1][i].x;
        ydat=plotPoints[i].x;
        x_cv1 = int( ( (xdat-minx)/(maxx-minx) * lenXAxis*0.9 + lenXAxis) );
        y_cv1 = int( ( (ydat-miny)/(maxy-miny) * lenYAxis*0.9 + lenYAxis) );
        xdat=points[1][i+1].x;
        ydat=points[1][i+1].y;
        x_cv2 = int( ( (xdat-minx)/(maxx-minx) * lenXAxis*0.9 + lenXAxis) );
        y_cv2 = int( ( (ydat-miny)/(maxy-miny) * lenYAxis*0.9 + lenYAxis) );
        
        xdat++;
        
        NSLog(@"some %d %d",xdat,ydat);
        
        NSLog(@"some %d %d %d %d",x_cv1,y_cv1,x_cv2,y_cv2);
        cv::line(image,Point2f(int(x_cv1),int(y_cv1)),Point2f(int(x_cv2),int(y_cv2)),(255,0,0),2);
    }
}

    image=image;
}
#endif

@end
