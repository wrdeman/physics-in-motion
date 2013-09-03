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
    //using structure
    float vals[] = {(float)size, x, y};
    CVPlotting::plotPoints.push_back(new PlotPoints::PlotPoints(names,vals));
}

    
void CVPlotting::plotData(cv::Mat image, int plotPosition){
    float xdat,ydat;
    size_t cvwidlem;
    //size of the opencv frame
    cv::Size cvwidlen=CVProcessing::gray.size();

    //the parameters y_cvFrame and y_offset are hardcoded for LandscapeLeft
    //this is a fudge because iOS and CV have different image sizes
    //in an ideal world this world be dynamically set but am I that fussed of PoC?
    int x_cvFrame = cvwidlen.width;
    int y_cvFrame = int(cvwidlen.width * (3./5.));
    float y_offset = 75;
    
    //size of half the opencv frame
    float xx2=float((x_cvFrame)/2);
    float yy2=float((y_cvFrame)/2);
    
    //opencv lengths of axis
    // 90% of the half size - i.e. isn't flush with edges
    float dx = (xx2*0.9);
    float dy = (yy2*0.9);
    
    float xp,yp;
    
    //----get plot position---------
    if (plotPosition%2==0){
        xp=0;
        if (plotPosition>3){
            //4
            yp = -dy+y_offset;
        }
        else{
            yp = 0+y_offset;
        }
    }
    else{
        //1 or 3
        xp=dx;
        if (plotPosition>1){
            //1
            yp = -dy+y_offset;
        }
        else{
            yp = 0+y_offset;
        }
    }
    //-----------------------------
    //y-axis
    cv::line(image,
             (cv::Point(xx2+xp,yy2+(yy2*0.9)+yp)),
             cv::Point(xx2+xp,yy2+yp),
             cv::Scalar(255,0,0),
             1);
    
    //x-axis
    // i want the x axis to intercept the y at x=0
    if (CVPlotting::minPoints->getParam("y")*CVPlotting::maxPoints->getParam("y")>0){
        cv::line(image,
                 cv::Point(xx2+xp,yy2+yp),
                 cv::Point((xx2*0.1)+xp,yy2+yp),
                 cv::Scalar(255,0,0),
                 1);
    }
    else{
        float adYInt = float(yy2 - dy*abs(CVPlotting::minPoints->getParam("y")/(CVPlotting::maxPoints->getParam("y")-CVPlotting::minPoints->getParam("y"))));
        cv::line(image,
                 cv::Point(xx2,adYInt+yp),
                 cv::Point((xx2*0.1)+xp,adYInt+yp),
                 cv::Scalar(255,0,0),
                 1);
    }
    
    if (CVPlotting::plotPoints.size() > 1){
        for (int i_graph = 0; i_graph < CVPlotting::plotPoints.size()-1; i_graph++){
            xdat = CVPlotting::plotPoints[i_graph]->getParam("x");
            ydat = CVPlotting::plotPoints[i_graph]->getParam("y");
                
            cv::Point p1 = CVPlotting::transformPlot(xdat, ydat,dx,dy,xx2,yy2,xp,yp);
            
            xdat = CVPlotting::plotPoints[i_graph+1]->getParam("x");
            ydat = CVPlotting::plotPoints[i_graph+1]->getParam("y");
                
            cv::Point p2 = CVPlotting::transformPlot(xdat, ydat,dx,dy,xx2,yy2,xp,yp);
            
            cv::line(image,
                    p1,
                    p2,
                    cv::Scalar(255,255,0),
                    1);
        }
    }
}

cv::Point CVPlotting::transformPlot(float xdat, float ydat, float dx, float dy, float xx2, float yy2, float xp, float yp){
    
    float xmin = CVPlotting::minPoints->getParam("x");
    float xmax = CVPlotting::maxPoints->getParam("x");
    float ymin = CVPlotting::minPoints->getParam("y");
    float ymax = CVPlotting::maxPoints->getParam("y");
    
    
    float x_new = ((xdat-xmin)/(xmax-xmin))*dx+(xx2*0.1)+xp;
    float y_new = ((ydat-ymin)/(ymax-ymin))*dy+yy2+yp;
    
    
    return cv::Point(x_new,y_new);
}

