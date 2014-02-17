//
//  plotViewController.m
//  MovEd1
//
//  Created by Simon on 22/09/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

//not good!
#define plotxaxis 0
#define plotyaxis 1
#define FPS 30

#import "plotViewController.h"

@interface plotViewController ()

@end

@implementation plotViewController
@synthesize btnEmail;
@synthesize btnAxis;
@synthesize plotPicker;
@synthesize plotAxisx;
@synthesize plotAxisy;
@synthesize hostView = hostView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (void)viewDidLoad
{
    [self.plotPicker setDelegate:self];
    [self.plotPicker setDataSource:self];

    //    self.plotPicker.dataSource = self;
//    self.plotPicker.delegate = self;
    [super viewDidLoad];

    //-----------------tap gestures------------------------------
    
    self.hostView.userInteractionEnabled = YES;
    
    axisPlotArray = [NSArray arrayWithObjects:@"time", @"x", @"y", @"A", @"dA/dt", @"Ø", @"dØ/dt", nil];
    
    self.plotAxisx = 1;
    self.plotAxisy = 2;
    //array for data
    dataArray = [[NSMutableArray alloc] init];
    xlim = [[NSMutableArray alloc] init];
    ylim = [[NSMutableArray alloc] init];

    [self plotData];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAxis:(id)sender {
 if (self.plotPicker) self.plotPicker.hidden = !self.plotPicker.hidden;
}

///Move to new storyboard
/*!
 get action to finish and email results
 */
- (IBAction)btnEmail:(id)sender {
    if(![MFMailComposeViewController canSendMail]){
        NSString *errorTitle = @"Error";
        NSString *errorString = @"Not configured to send mail";
        UIAlertView * errorView = [[UIAlertView alloc]
                                   initWithTitle:errorTitle
                                   message:errorString
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"OK", nil];
        [errorView show];
    }
    else{
        NSString* result = [NSString stringWithUTF8String:self.process->outputData(self.scaleNum,self.scaleNumChess,(1./FPS)).c_str()];
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;
        [mailView setSubject:@"Data"];
        [mailView setMessageBody:result isHTML:NO];
        [self presentViewController:mailView animated:YES completion:NULL];
    }
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if(error){
        NSString * errorTitle = @"Mail Error";
        NSString * errorDescription = [error localizedDescription];
        UIAlertView *errorView = [[UIAlertView alloc]
                                  initWithTitle:errorTitle
                                  message:errorDescription
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK",nil
                                  ];
        [errorView show];
    }else{
        
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark
#pragma mark Picker Data Source Methods
//methods to get the axis from the picker views
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)plotPicker{
    return 2;
}
//both the same length
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [axisPlotArray count];
}

-(NSString *)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == plotxaxis)
        return [axisPlotArray objectAtIndex:row];
    return [axisPlotArray objectAtIndex:row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"row = %d",row);
    if (component == plotxaxis){
        self.plotAxisx = row;
    }
    if (component == plotyaxis){
        self.plotAxisy = row;
    }
    [self plotData];
}



//where the data is taken from CVPlotting object in NSMutable array for coreplot
//define max and min here.
-(void) getDataArray{
    CVPlotting* process = self.getProcess;
    float xmax, xmin, ymin, ymax;
    
    std::vector<std::vector<float> > array = process->outputPlotData(self.scaleNum,self.scaleNumChess,(1./FPS));

    int sizeInner = 0;
    int sizeOuter = array.size();
    if (sizeOuter != 0){
        sizeInner = array[0].size();
    }
    
    xmax = array[0][self.plotAxisx];
    xmin = array[0][self.plotAxisx];
    ymin = array[0][self.plotAxisy];
    ymax = array[0][self.plotAxisy];
    
    for (int i = 0; i < sizeOuter; i++){
        
        NSMutableArray *innerArray = [[NSMutableArray alloc] init];
        for (int j=0; j < sizeInner; j++){
                NSNumber* x = [NSNumber numberWithFloat:array[i][j]];
                [innerArray addObject:x];
            }
        if (array[i][self.plotAxisx]>xmax){
            xmax = array[i][self.plotAxisx];
        }
        if (array[i][self.plotAxisx]<xmin){
            xmin = array[i][self.plotAxisx];
        }
        if (array[i][self.plotAxisy]>ymax){
            ymax = array[i][self.plotAxisy];
        }
        if (array[i][self.plotAxisy]<ymin){
            ymin = array[i][self.plotAxisy];
        }
        
        [dataArray addObject:innerArray];
    }
    [xlim addObject:[NSNumber numberWithFloat:xmin]];
    [xlim addObject:[NSNumber numberWithFloat:xmax]];
    [ylim addObject:[NSNumber numberWithFloat:ymin]];
    [ylim addObject:[NSNumber numberWithFloat:ymax]];
}

- (void) plotData{
    // We need a hostview, you can create one in IB (and create an outlet) or just do this:
    
    [dataArray removeAllObjects];
    [xlim removeAllObjects];
    [ylim removeAllObjects];
    
    [self getDataArray];
    float x0, y0, xrange, yrange;
    
    x0 = [[xlim objectAtIndex:0] floatValue];
    y0 = [[ylim objectAtIndex:0] floatValue];
    
    xrange = [[xlim objectAtIndex:1] floatValue];
    yrange = [[ylim objectAtIndex:1] floatValue];
    
    xrange = xrange - x0;
    yrange = yrange - y0;

    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.hostView;
    // hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph  = graph;
    
    graph.paddingLeft   = 10.0;
    graph.paddingTop    = 10.0;
    graph.paddingRight  = 10.0;
    graph.paddingBottom = 10.0;
    
    // Get the (default) plotspace from the graph so we can set its x/y ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( y0 ) length:CPTDecimalFromFloat( yrange )]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat( x0 ) length:CPTDecimalFromFloat( xrange )]];
    
    // Create the plot (we do not define actual x/y values yet, these will be supplied by the datasource...)
    CPTScatterPlot* plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];

    
    
    // Let's keep it simple and let this class act as data  source (therefore we implemtn <CPTPlotDataSource>)
    plot.dataSource = self;
        
    // Finally, add the created plot to the default plot space of the CPTGraph object we created before
    [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plotnumberOfRecords {
    return [dataArray count];
    
}

// This method is here because this class also functions as datasource for our graph
// Therefore this class implements the CPTPlotDataSource protocol
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    // We need to provide an X or Y (this method will be called for each) value for every index
    
    // This method is actually called twice per point in the plot, one for the X and one for the Y value
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return dataArray[index][self.plotAxisx];
    } else {
        return dataArray[index][self.plotAxisy];
    }
    
}

@end
