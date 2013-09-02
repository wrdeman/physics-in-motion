//
//  PlotPoints.cpp
//  MovEd1
//
//  Created by Simon on 30/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#include "PlotPoints.h"
#include <string>

PlotPoints::PlotPoints(){}

PlotPoints::PlotPoints(std::string name[], float vals[]){
    PlotPoints::setData(name, vals);
}

void PlotPoints::setData(std::string name[], float vals[])
{
    size_t size;
    size=sizeof(vals);
    //std::cout<<"size is = "<<sizeof(vals)<<std::endl;
    for (int i = 0; i < size; i++){
        PlotPoints::points[name[i]] = vals[i];
    }
}

void PlotPoints::replace(std::string name, float val)
{
    std::map<std::string,int>::iterator it;
    it=PlotPoints::points.find(name);
    PlotPoints::points.erase (it);
    PlotPoints::points[name] = val;
}

float PlotPoints::getParam(std::string x){
    return PlotPoints::points.find(x)->second;
}


