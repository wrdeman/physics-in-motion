//
//  CVProcessing.cpp
//  MovEd1
//
//  Created by Simon on 26/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//
//#define SCALING_FACTOR_X (1024.0/480.0)
//#define SCALING_FACTOR_Y (768.0/360.0)

//these are the width and heights of the imageview - could do this better.
//will have to iPhone5 has bigger screen
#define IPAD_X 1024
#define IPAD_Y 706
#define IPHONE_Y 258
#define IPHONE_X 568
#include "CVProcessing.h"

CVProcessing::CVProcessing(){
    CVProcessing::subPixWinSize = cv::Size(10,10);
    CVProcessing::winSize = cv::Size(31,31);
    CVProcessing::termcrit = cv::TermCriteria(CV_TERMCRIT_ITER|CV_TERMCRIT_EPS,20,0.03);
    }

/**
 add the new point to the newpoint vector
 call on tapping for point
 */
void CVProcessing::cvNewPoint(int x, int y){
    CVProcessing::newpoint.push_back(x);
    CVProcessing::newpoint.push_back(y);
}

/**
 add the new point
 
 this transforms the iOS coordinate to the opencv coordinate
 then uses cornersubpix to get better position
 */
void CVProcessing::cvAddPoint(bool isPad){
    
    /*
     iOS
    (0,0)      (1024,0)
     -------------
     |           |
 cam |           | button
     |           |
     -------------
     (0,768)     (1024,768)
     
     
     opencv
    (w,l)        (w,0)
     -------------
     |           |
 cam |           | button
     |           |
     -------------
     (0,l)       (0,0)
     
     */
    
    cv::Size cvwidlen=CVProcessing::gray.size();
    int x = CVProcessing::newpoint[0];
    int y = CVProcessing::newpoint[1];
    //define a c++ vector for points needed for opencv
    std::vector<cv::Point2f> tmp;
    int xtrans, ytrans;
    
    if (isPad){
        xtrans = IPAD_X;
        ytrans = IPAD_Y;
    }
    else{
        xtrans = IPHONE_X;
        ytrans = IPHONE_Y;
    }
    
    //THESE TRANSFORMATIONS WILL NEED TO
    x=xtrans-x;
    y=ytrans-y;
    //these are the points that go into opencv
    CVProcessing::newpoint2f = cv::Point2f(float(cvwidlen.width*x/xtrans),float(cvwidlen.height*y/ytrans));
    tmp.push_back(CVProcessing::newpoint2f);
    //if a new point the find corners - the last points CHECK
    cornerSubPix( CVProcessing::gray, tmp, CVProcessing::winSize, cvSize(-1,-1), CVProcessing::termcrit);
    //put all old points
    CVProcessing::points[1].push_back(tmp[0]);
    tmp.clear();
    newpoint.clear();
}

/*
 add the origin
 from the long press gesture
 this is simply where one presses but transformed into opencv
 */
void CVProcessing::cvOrigin(int x, int y, bool isPad){
    cv::Size cvwidlen=CVProcessing::gray.size();
    //define a c++ vector for points needed for opencv
    std::vector<cv::Point2f> origin2f;
    int xtrans, ytrans;

    if (isPad){
        xtrans = IPAD_X;
        ytrans = IPAD_Y;
    }
    else{
        xtrans = IPHONE_X;
        ytrans = IPHONE_Y;
    }
    //THESE TRANSFORMATIONS WILL NEED TO
    x=xtrans-x;
    y=ytrans-y;
    //these are the points that go into opencv
    CVProcessing::origin2f.push_back(cv::Point2f(float(cvwidlen.width*x/xtrans),float(cvwidlen.height*y/ytrans)));
}

/**
 delete a point from the array
 */
void CVProcessing::cvDeletePoint(){
    if (!CVProcessing::points[0].empty()){
        CVProcessing::points[0].pop_back();
        CVProcessing::points[1].pop_back();
    }
}
/**
 delete the origin
 */
void CVProcessing::cvDeleteOrigin(){
    if (!CVProcessing::origin2f.empty()){
        CVProcessing::origin2f.pop_back();
    }
}

/**
 how many tracked points?
 */
int CVProcessing::cvTrackedPoints(){
    return CVProcessing::points[0].size();
}

/**
 this does the tracking of the points.
 
 see opencv documentation for more details - opencv.org and samples/cpp/lk_demo.cpp 
 */
void CVProcessing::cvTracking(cv::Mat image, bool newPoints, bool isPad){
    cv::cvtColor(image, CVProcessing::gray, CV_RGBA2GRAY);
    size_t i, k;
    
    if (newPoints){
        CVProcessing::cvAddPoint(isPad);
    }
    if (CVProcessing::cvTrackedPoints()!=0){
        if (!CVProcessing::previous.empty()){
            cv::calcOpticalFlowPyrLK(CVProcessing::previous, CVProcessing::gray, CVProcessing::points[0], CVProcessing::points[1], CVProcessing::status, CVProcessing::err, CVProcessing::winSize, 3, CVProcessing::termcrit,0,0.001);
        }
        for(i = k = 0; i < CVProcessing::points[1].size(); i++ ){
            if( !CVProcessing::status[i] )
                continue;
            CVProcessing::points[1][k++] = CVProcessing::points[1][i];
            cv::circle(image, CVProcessing::points[1][i], 3, cv::Scalar(0,255,0), -1, 8);
        }
        CVProcessing::points[1].resize(k);
    }
    if (!CVProcessing::origin2f.empty()){
        cv::circle(image, CVProcessing::origin2f[0], 3, cv::Scalar(255,255,0), -1, 8);
    }
    std::swap(CVProcessing::points[1],CVProcessing::points[0]);
    CVProcessing::gray.copyTo(CVProcessing::previous);
    
}