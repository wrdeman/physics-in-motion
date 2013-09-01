//
//  CVPlotting.cpp
//  MovEd1
//
//  Created by Simon on 29/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#include "CVPlotting.h"

std::string names[] = {"t","x","y"};

CVPlotting::CVPlotting(){
    CVPlotting::maxPoints = new PlotPoints::PlotPoints();
    CVPlotting::minPoints = new PlotPoints::PlotPoints();

    float vals[] = {0,0,0};
    CVPlotting::maxPoints->setData(names,vals);
    CVPlotting::minPoints->setData(names,vals);
    }

void CVPlotting::setPlotPoints(){
    //array to be set contains t, A, dA/dt, theta, d(theta)/dt, x, y
    //define points
   
    float x = CVProcessing::points[0][0].x;
    float y = CVProcessing::points[0][0].y;
    int size = CVPlotting::plotPoints.size();
    if (size==0){
        CVPlotting::maxPoints->replace("x",x);
        CVPlotting::minPoints->replace("x",x);
        CVPlotting::maxPoints->replace("y",y);
        CVPlotting::minPoints->replace("y",y);
    }
    else{
        if (x>CVPlotting::maxPoints->getParam("x")){
            CVPlotting::maxPoints->replace("x",x);
        }
        if (x<CVPlotting::minPoints->getParam("x")){
            CVPlotting::minPoints->replace("x",x);
        }
        if (y>CVPlotting::maxPoints->getParam("y")){
            CVPlotting::maxPoints->replace("y",y);
        }
        if (y<CVPlotting::minPoints->getParam("y")){
            CVPlotting::minPoints->replace("y",y);
        }
    }
    ////////////////////////////////
    //using structure
    
    float vals[] = {(float)size, x, y};
    CVPlotting::plotPoints.push_back(new PlotPoints::PlotPoints(names,vals));
}

    
void CVPlotting::plotData(cv::Mat image){
    float xdat,ydat,xmin,xmax,ymin,ymax;
    float x_cv1, x_cv2, y_cv1, y_cv2;
    //size of the opencv frame
    cv::Size cvwidlen=CVProcessing::gray.size();
    int x_cvFrame = cvwidlen.width;
    int y_cvFrame = cvwidlen.height;

    //size of half the opencv frame
    float xx2=float((x_cvFrame)/2);
    float yy2=float((y_cvFrame)/2);
    
    //opencv lengths of axis
    float dx = (xx2*0.9);
    float dy = (yy2*0.9);
    
    //y-axis
    cv::line(image,
             (cv::Point(xx2,yy2*0.1)),
             cv::Point(xx2,yy2),
             cv::Scalar(255,0,0),
             1);
    //x-axis
    // i want the x axis to intercept the y at x=0
    if (CVPlotting::minPoints->getParam("y")*CVPlotting::maxPoints->getParam("y")>0){
        cv::line(image,
                 cv::Point(xx2,yy2),
                 cv::Point(int(xx2+xx2*0.9),yy2),
                 cv::Scalar(255,0,0),
                 1);
    }
    else{
        float adYInt = float(yy2 - dy*abs(CVPlotting::minPoints->getParam("y")/(CVPlotting::maxPoints->getParam("y")-CVPlotting::minPoints->getParam("y"))));
        cv::line(image,
                 cv::Point(xx2,adYInt),
                 cv::Point((xx2+xx2*0.9),adYInt),
                 cv::Scalar(255,0,0),
                 1);
    }
    
        if (CVPlotting::plotPoints.size() > 1){
            for (int i_graph = 0; i_graph < CVPlotting::plotPoints.size()-1; i_graph++){
                xdat = CVPlotting::plotPoints[i_graph]->getParam("x");
                ydat = CVPlotting::plotPoints[i_graph]->getParam("y");
                
                xmin = CVPlotting::minPoints->getParam("x");
                xmax = CVPlotting::maxPoints->getParam("x");
                ymin = CVPlotting::minPoints->getParam("y");
                ymax = CVPlotting::maxPoints->getParam("y");
                
                x_cv1 = ((xdat-xmin)/(xmax-xmin))*dx+xx2;
                y_cv1 = ((ydat-ymin)/(ymax-ymin))*dy+yy2*0.1;
                
                xdat = CVPlotting::plotPoints[i_graph+1]->getParam("x");
                ydat = CVPlotting::plotPoints[i_graph+1]->getParam("y");
                
                x_cv2 = ((xdat-xmin)/(xmax-xmin))*dx+xx2;
                y_cv2 = ((ydat-ymin)/(ymax-ymin))*dy+yy2*0.1;
                cv::line(image,
                         cv::Point((x_cv1),(y_cv1)),
                         cv::Point((x_cv2),(y_cv2)),
                         cv::Scalar(255,255,0),
                         1);
                }
        
    }
}



