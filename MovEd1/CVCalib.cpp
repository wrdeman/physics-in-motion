//
//  Calb.cpp
//  MovEd1
//
//  Created by Simon on 06/09/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#include "CVCalib.h"

int CVCalib::countStaticImage = 0;
cv::Size CVCalib::boardSize = cv::Size(0,0);
std::vector<std::vector<cv::Point2f>> CVCalib::chessPoints;
std::vector<std::vector<cv::Point3f>> CVCalib::objectPoints;
bool CVCalib::mustInitUndistort = true;

CVCalib::CVCalib(){
    
}

void CVCalib::takeStaticImage(cv::Mat image){
    
    CVCalib::countStaticImage++;
    
    std::vector<cv::Point2f> chessCorners;
    std::vector<cv::Point3f> objectCorners;
    cv::Mat grey;
    cv::cvtColor(image, grey, CV_RGB2HSV);
    bool found;
    int maxsize=0;
    //must have more that 3 squares showing
    //this finds the board size which is now fixed
    //othewise the calibration won't work (I think)

    if (CVCalib::countStaticImage == 1){
            for (int i = 3; i < 8; i++) {
                    for (int j = 3; j < 8; j++){
                        found = cv::findChessboardCorners(image, cv::Size(i,j), chessCorners);
                        if (found){
                            if (i*j > maxsize){
                                CVCalib::boardSize = cv::Size(i,j);
                                maxsize = i*j;
                            }
                        }
                    }
            }
            if (CVCalib::boardSize.height != 0 || CVCalib::boardSize.width != 0) {
                found = cv::findChessboardCorners(image, cv::Size(CVCalib::boardSize.height,CVCalib::boardSize.width), chessCorners);
            }
        //3D points
        
    }
    else{
        found = cv::findChessboardCorners(image, cv::Size(CVCalib::boardSize.height,CVCalib::boardSize.width), chessCorners);
    }
    
    for (int i = 0; i<CVCalib::boardSize.height; i++){
        for (int j = 0; j<CVCalib::boardSize.width; j++){
            objectCorners.push_back(cv::Point3f(i,j,0.0f));
        }
    }
    
    //improve accuracy on corners
    cv::cvtColor(image, grey, CV_RGBA2GRAY);
    if (found){
        cv::cornerSubPix(grey, chessCorners, cv::Size(5,5), cv::Size(-1,-1), cv::TermCriteria(cv::TermCriteria::MAX_ITER + cv::TermCriteria::EPS, 20, 0.5));
//            NSLog(@"size = %d area =%d",CVCalib::boardSize.area(),chessCorners.size());
        if (CVCalib::boardSize.area() == chessCorners.size()){
            CVCalib::chessPoints.push_back(chessCorners);
            CVCalib::objectPoints.push_back(objectCorners);
            cv::drawChessboardCorners(image, CVCalib::boardSize, chessCorners,found);
        }
        else{
            CVCalib::countStaticImage--;
        }
    }
    else{
        CVCalib::countStaticImage--;
    }
    
}

double CVCalib::getScale(cv::Mat image){
    cv::Mat grey;
    std::vector<cv::Point2f> chessCorners;
    float diff=0;
    
    cv::cvtColor(image, grey, CV_RGBA2GRAY);
    bool found = cv::findChessboardCorners(image, cv::Size(CVCalib::boardSize.height,CVCalib::boardSize.width), chessCorners);
    if (found){
        cv::cornerSubPix(grey, chessCorners, cv::Size(5,5), cv::Size(-1,-1), cv::TermCriteria(cv::TermCriteria::MAX_ITER + cv::TermCriteria::EPS, 20, 0.5));
        //            NSLog(@"size = %d area =%d",CVCalib::boardSize.area(),chessCorners.size());
        if (CVCalib::boardSize.area() == chessCorners.size()){
            cv::drawChessboardCorners(image, CVCalib::boardSize, chessCorners,found);
            for (int i = 0; i<CVCalib::boardSize.height; i++){
                for (int j = 0; j<CVCalib::boardSize.width-1; j++){
                    diff += chessCorners[i+1].x-chessCorners[i].x;
                }
            }
            return diff/(CVCalib::boardSize.height*(CVCalib::boardSize.width-1));
        }
    }
    return 0;
}

double CVCalib::calibrate(cv::Size imageSize){
    CVCalib::mustInitUndistort = true;
    std::vector<cv::Mat> rvecs, tvecs;
    return cv::calibrateCamera(CVCalib::objectPoints, CVCalib::chessPoints, imageSize, CVCalib::cameraMatrix, CVCalib::distCoeffs, rvecs, tvecs);
    
}

void CVCalib::reMap(cv::Mat image){
    cv::Mat undistorted;
    if (CVCalib::mustInitUndistort){
        cv::initUndistortRectifyMap(CVCalib::cameraMatrix, CVCalib::distCoeffs, cv::Mat(), cv::Mat(), image.size(), CV_16SC2, CVCalib::map1, CVCalib::map2);
        CVCalib::mustInitUndistort = false;
    }   
    cv::remap(image, undistorted, CVCalib::map1, CVCalib::map2, cv::INTER_LINEAR);
    image = undistorted;
}
