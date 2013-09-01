//
//  PlotPoints.h
//  MovEd1
//
//  Created by Simon on 30/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#ifndef __MovEd1__PlotPoints__
#define __MovEd1__PlotPoints__


#include <iostream>
#include <string>
#include <map>
#include <vector>

class PlotPoints
{
private:
    std::map<std::string, int> points;
    
public:
    PlotPoints();
    PlotPoints(std::string name[], float vals[]);
    void setData(std::string name[], float vals[]);
    void replace(std::string name, float vals);
    int getParam(std::string x);
};

#endif /* defined(__MovEd1__PlotPoints__) */
