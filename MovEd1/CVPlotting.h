//
//  CVPlotting.h
//  MovEd1
//
//  Created by Simon on 29/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#ifndef __MovEd1__CVPlotting__
#define __MovEd1__CVPlotting__

#include <iostream>
#include "CVProcessing.h"
#include <vector>
#include <string>
#include <math.h>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"


#define NUM_PLOT 7

class CVPlotting: public CVProcessing
{
private:
    //int num_plot;
    std::vector<float> maxPoints;
    std::vector<float> minPoints;
    
    cv::Point transformPlot(float x, float y, float dx, float dy, float xx2, float yy2, float xp, float yp, int xaxis, int yaxis);
    
    float amp(float x, float y, float Ox, float Oy);
    float damp(float a1, float a0, float dt);
    float th(float x, float y, float Ox, float Oy);
    float dth(float t1, float t0, float dt);
    
public:
    CVPlotting();
    void setPlotPoints(double time);
    void plotData(cv::Mat image, int plotPosition, int xaxis, int yaxis, float toolBarHeight);
    static std::vector<std::vector<float>> plotPoints;
    void resetPlotPoints();
    std::string outputData(float scaleNum, float scaleNumChess, float time);
    std::vector<std::vector<float> > outputPlotData(float scaleNum, float scaleNumChess, float time);
};


#endif /* defined(__MovEd1__CVPlotting__) */
