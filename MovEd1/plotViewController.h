//
//  plotViewController.h
//  MovEd1
//
//  Created by Simon on 22/09/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "com_gmail_simonwosborneViewController.h"
#import "CorePlot-CocoaTouch.h"
#import <vector>

@interface plotViewController : com_gmail_simonwosborneViewController<UIPickerViewDelegate,UIPickerViewDataSource,MFMailComposeViewControllerDelegate,CPTPlotDataSource>{
    NSArray *axisPlotArray;
    NSArray *axisPlotArrayNoOrigin;
    IBOutlet UIBarButtonItem * btnEmail;
    IBOutlet UIBarButtonItem * btnAxis;
//    IBOutlet UIPickerView * plotPicker;
    NSMutableArray *dataArray;
    NSMutableArray *xlim;
    NSMutableArray *ylim;
    IBOutlet CPTGraphHostingView *hostView;
    CPTXYGraph *graph;
}
- (IBAction)btnEmail:(id)sender;
- (IBAction)btnAxis:(id)sender;
- (IBAction)showplotPicker:(id)sender;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAxis;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnEmail;
@property (strong, nonatomic) IBOutlet UIPickerView * plotPicker;
@property (strong, retain) IBOutlet CPTGraphHostingView *hostView;

@property (nonatomic,assign) int plotAxisx;
@property (nonatomic,assign) int plotAxisy;

@end
