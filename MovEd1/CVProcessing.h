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
#include <opencv2/highgui/cap_ios.h>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/video/tracking.hpp"
//#import "CVPlotting.h"
//using namespace std;

class CVProcessing{
    
private:
    cv::Point2f newpoint2f;
    cv::Size subPixWinSize, winSize;
    cv::TermCriteria termcrit;
    void cvAddPoint(int xtrans, int ytrans);
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
    void cvTracking(cv::Mat image ,bool newPoints, int xtrans, int ytrans);
    int cvTrackedPoints();
    void cvOrigin(int x, int y, int xtrans, int ytrans);
    std::vector<cv::Point2f> points[2];
    std::vector<int> newpoint;
    std::vector<cv::Point2f> origin2f;
};

#endif /* defined(__MovEd1__CVProcessing__) */
