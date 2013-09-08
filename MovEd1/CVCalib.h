//
//  Calb.h
//  MovEd1
//
//  Created by Simon on 06/09/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#ifndef __MovEd1__CVCalib__
#define __MovEd1__CVCalib__

#include <vector>
#include <algorithm>
#include <iostream>
#import <opencv2/highgui/cap_ios.h>
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"




class CVCalib{
    
private:
    static cv::Size boardSize;
    static std::vector<std::vector<cv::Point2f>> chessPoints;
    static std::vector<std::vector<cv::Point3f>> objectPoints;
    static bool mustInitUndistort;
    cv::Mat cameraMatrix;
    cv::Mat distCoeffs;
    cv::Mat map1;
    cv::Mat map2;

public:
    CVCalib();
    void takeStaticImage(cv::Mat image);
    double calibrate(cv::Size imageSize);
    void reMap(cv::Mat image);
    int getNumStatics();
    static int countStaticImage;
};

#endif /* defined(__MovEd1__CVCalib__) */
