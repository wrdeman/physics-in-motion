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
#include "PlotPoints.h"
#include <vector>
#include <string>
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"

class CVPlotting: public CVProcessing
{
private:
    PlotPoints::PlotPoints * maxPoints;
    PlotPoints::PlotPoints * minPoints;
    
public:
    CVPlotting();
    void setPlotPoints();
    void plotData(cv::Mat image);    
    
    std::vector<PlotPoints::PlotPoints*> plotPoints;
    
};


#endif /* defined(__MovEd1__CVPlotting__) */
