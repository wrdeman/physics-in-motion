//
//  CVProcessing.h
//  MovEd1
//
//  Created by Simon on 26/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#ifndef __MovEd1__CVProcessing__
#define __MovEd1__CVProcessing__

#include <vector>
#include <algorithm>
#include <iostream>
#import <opencv2/highgui/cap_ios.h>
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"
#import "opencv2/video/tracking.hpp"
//#import "CVPlotting.h"
//using namespace std;

class CVProcessing{
    
private:
    cv::Point2f newpoint2f;
    cv::Size subPixWinSize, winSize;
    cv::TermCriteria termcrit;
    void cvAddPoint();
    std::vector<uchar> status;
    std::vector<float> err;

protected:
    std::vector<cv::Point2f> plotPoints;
    cv::Mat previous, gray;
    
public:
    //empty constructor
    CVProcessing();
    void cvNewPoint(int x, int y);
    void cvDeletePoint();
    void cvDeleteOrigin();
    void cvTracking(cv::Mat image ,bool newPoints);
    int cvTrackedPoints();
    void cvOrigin(int x, int y);
    std::vector<cv::Point2f> points[2];
    std::vector<int> newpoint;
    std::vector<cv::Point2f> origin2f;
};

#endif /* defined(__MovEd1__CVProcessing__) */
