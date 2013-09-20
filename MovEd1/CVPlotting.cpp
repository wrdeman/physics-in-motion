//
//  CVPlotting.cpp
//  MovEd1
//
//  Created by Simon on 29/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#include "CVPlotting.h"

CVPlotting::CVPlotting(){
    //{"t","x","y","A","dA","th","dth"}
        for (int i = 0; i < NUM_PLOT; i++){
            CVPlotting::maxPoints.push_back(0);
            CVPlotting::minPoints.push_back(0);
        }
    }

/**
 defines the points to be plotted
 
 at each step check whether new point is a new max or min - better that search vector at a later stage
 
 1) first point is set as max and min
 2) subsequent points are compared and max/min updated
 3) the derived quatities are calculated and pushed into vector of points to be plotted
 4) if no origin is selected A and theta, and there derivatives with respect to time are zero
 */
void CVPlotting::setPlotPoints(double time){
    //array to be set contains t, A, dA/dt, th, d(th)/dt, x, y
    //originally had as map but thought it was pointless. want python dict!
    //define points
    //add in definitions of A and th
    float A, dA, th, dth,Ox,Oy;
    dA = 0;
    dth = 0;
    float x = CVProcessing::points[0][0].x;
    float y = CVProcessing::points[0][0].y;
    //if an origin put points in otherwise set to zero
    //must catch divide by zero
    if (!CVProcessing::origin2f.empty()){
        Ox = CVProcessing::origin2f[0].x;
        Oy = CVProcessing::origin2f[0].y;
        A = CVPlotting::amp(x,y,Ox,Oy);
        th = CVPlotting::th(x,y,Ox,Oy);
    }
    else{
        Ox = 0.;
        Oy = 0.;
        A = 0.;
        th = 0.;
    }
    //set max/min values
    int size = CVPlotting::plotPoints.size();
    if (size==0){
        
        CVPlotting::maxPoints[0] = (float)time;
        CVPlotting::minPoints[0] = (float)time;
        
        CVPlotting::maxPoints[1] = x;
        CVPlotting::minPoints[1] = x;
        
        CVPlotting::maxPoints[2] = y;
        CVPlotting::minPoints[2] = y;
        
        CVPlotting::maxPoints[3] = A;
        CVPlotting::minPoints[3] = A;
        
        CVPlotting::maxPoints[4] = th;
        CVPlotting::minPoints[4] = th;
 
    }
    else{
        CVPlotting::maxPoints[0] = float(time)+CVPlotting::plotPoints[size-1][0];
        
        if (x>CVPlotting::maxPoints[1]){
            CVPlotting::maxPoints[1] = x;
        }
        if (x<CVPlotting::minPoints[1]){
            CVPlotting::minPoints[1] = x;
        }
        if (y>CVPlotting::maxPoints[2]){
            CVPlotting::maxPoints[2] = y;
        }
        if (y<CVPlotting::minPoints[2]){
            CVPlotting::minPoints[2] = y;
        }
        if (A>CVPlotting::maxPoints[3]){
            CVPlotting::maxPoints[3] = A;
        }
        if (A<CVPlotting::minPoints[3]){
            CVPlotting::minPoints[3] = A;
        }
        if (th>CVPlotting::maxPoints[5]){
            CVPlotting::maxPoints[5] = th;
        }
        if (th<CVPlotting::minPoints[5]){
            CVPlotting::minPoints[5] = th;
        }
        
        if (size >= 1){
            dA = CVPlotting::damp(A, CVPlotting::plotPoints[size-1][3], 1.);
            dth = CVPlotting::dth(th, CVPlotting::plotPoints[size-1][5], 1.);
            if(size == 1){
                //set max/min
                CVPlotting::maxPoints[4] = dA;
                CVPlotting::minPoints[4] = dA;
                CVPlotting::maxPoints[6] = dth;
                CVPlotting::minPoints[6] = dth;
            }
            else{
                if (dA>CVPlotting::maxPoints[4]){
                    CVPlotting::maxPoints[4] = dA;
                }
                if (dA<CVPlotting::minPoints[4]){
                    CVPlotting::minPoints[4] = dA;
                }
                if (dth>CVPlotting::maxPoints[6]){
                    CVPlotting::maxPoints[6] = dth;
                }
                if (dth<CVPlotting::minPoints[6]){
                    CVPlotting::minPoints[6] = dth;
                }
            }
        }
    }
    //using structure
    //float vals[] = {(float)size, x, y,A,dA,th,dth};
    CVPlotting::plotPoints.push_back({CVPlotting::maxPoints[0], x, y,A,dA,th,dth});
}

/*
reset all the plotte points
*/
void CVPlotting::resetPlotPoints(){
    CVPlotting::plotPoints.clear();
}

/*
 plot the data:
 
 axis are plotted on the screen as 90% of the quadrant
 the plotted points are then fitted into this quadrant
 
 */
void CVPlotting::plotData(cv::Mat image, int plotPosition, int xaxis, int yaxis, float toolBarHeight){
    float xdat,ydat;
    //size of the opencv frame
    cv::Size cvwidlen=CVProcessing::gray.size();

    int x_cvFrame = cvwidlen.width;
    int y_cvFrame = int(cvwidlen.height * toolBarHeight);
    
    float sizeToolbarHeight = (cvwidlen.height * (1.- toolBarHeight));
    
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
            yp = -dy+sizeToolbarHeight;
        }
        else{
            yp = 0+sizeToolbarHeight;
        }
    }
    else{
        //1 or 3
        xp=dx;
        if (plotPosition>1){
            //1
            yp = -dy+sizeToolbarHeight;
        }
        else{
            yp = 0+sizeToolbarHeight;
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
    if (CVPlotting::minPoints[yaxis]*CVPlotting::maxPoints[yaxis] > 0){
        cv::line(image,
                 cv::Point(xx2+xp,yy2+yp),
                 cv::Point((xx2*0.1)+xp,yy2+yp),
                 cv::Scalar(255,0,0),
                 1);
    }
    else{
        float adYInt = float(yy2 - dy*abs(CVPlotting::minPoints[yaxis]/(CVPlotting::maxPoints[yaxis]-CVPlotting::minPoints[yaxis])));
        cv::line(image,
                 cv::Point(xx2,adYInt+yp),
                 cv::Point((xx2*0.1)+xp,adYInt+yp),
                 cv::Scalar(255,0,0),
                 1);
    }
    
    if (CVPlotting::plotPoints.size() > 1){
        for (int i_graph = 0; i_graph < CVPlotting::plotPoints.size()-1; i_graph++){
            xdat = CVPlotting::plotPoints[i_graph][xaxis];
            ydat = CVPlotting::plotPoints[i_graph][yaxis];
                
            cv::Point p1 = CVPlotting::transformPlot(xdat, ydat,dx,dy,xx2,yy2,xp,yp,xaxis,yaxis);
            
            xdat = CVPlotting::plotPoints[i_graph+1][xaxis];
            ydat = CVPlotting::plotPoints[i_graph+1][yaxis];
                
            cv::Point p2 = CVPlotting::transformPlot(xdat, ydat,dx,dy,xx2,yy2,xp,yp,xaxis,yaxis);
            
            cv::line(image,
                    p1,
                    p2,
                    cv::Scalar(255,255,0),
                    1);
        }
    }
}

cv::Point CVPlotting::transformPlot(float xdat, float ydat, float dx, float dy, float xx2, float yy2, float xp, float yp, int xaxis, int yaxis){
    
    float xmin = CVPlotting::minPoints[xaxis];
    float xmax = CVPlotting::maxPoints[xaxis];
    float ymin = CVPlotting::minPoints[yaxis];
    float ymax = CVPlotting::maxPoints[yaxis];
    
    
    float x_new = ((xdat-xmin)/(xmax-xmin))*dx+(xx2*0.1)+xp;
    float y_new = ((ydat-ymin)/(ymax-ymin))*dy+yy2+yp;
    
    
    return cv::Point(x_new,y_new);
}

float CVPlotting::amp(float x, float y, float Ox, float Oy){
    return x-Ox;
}
float CVPlotting::damp(float a1, float a0, float dt){
    if (dt==0){
        return 0;
    }
    else{
        return (a1 - a0)/dt;
    }
}
float CVPlotting::th(float x, float y, float Ox, float Oy){
    //if Ox == zero then I haven't set origin
    if ((Ox) == 0){
        return 0;
    }
    else{
        return atan((x-Ox)/(y-Oy));
    }
}
float CVPlotting::dth(float t1, float t0, float dt){
    if (dt == 0){
        return 0;
    }
    else{
        return (t1 - t0)/dt;
    }
}

std::string CVPlotting::outputData(float scaleNum, float scaleNumChess, float time){
    //set to real units
    //time in seconds
    //if scaled x, y in whatever unit - otherwide px
    //if scaled dA unit per second  otherwise px per sec
    if (scaleNum == 0 || scaleNumChess == 0){
        scaleNum = 1;
        scaleNumChess = 1;
    }
    
    std::ostringstream s;
    int size = NUM_PLOT;
    if (CVProcessing::origin2f.empty()){
        size = 3;
        s<<"t \t x \t y \t"<<std::endl;
    }
    else{
        s<<"t \t x \t y \t A \t dA \t Th \t dTh \t"<<std::endl;
            }
    for (int i = 0; i < CVPlotting::plotPoints.size(); i++){
        s << CVPlotting::plotPoints[i][0] << "\t";
        for (int j = 1; j < size; j++){
            if (j == 1 || j == 2){
                s << CVPlotting::plotPoints[i][j]*scaleNum/scaleNumChess << "\t";
            }
            if (j == 3){
                s << CVPlotting::plotPoints[i][j]*scaleNum/scaleNumChess << "\t";
            }
            if (j == 4){
                s << CVPlotting::plotPoints[i][j]*scaleNum/(scaleNumChess*time) << "\t";
            }
            if (j == 5){
                s << CVPlotting::plotPoints[i][j] << "\t";
            }
            if (j == 6){
                s << CVPlotting::plotPoints[i][j]/(time) << "\t";
            }
            
        }
        s << std::endl;
    }
    return s.str();
}
