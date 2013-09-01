//
//  MyNavigationController.m
//  MovEd1
//
//  Created by Simon on 26/08/2013.
//  Copyright (c) 2013 Simon Osborne. All rights reserved.
//

#import "MyNavigationController.h"

@interface MyNavigationController ()

@end

@implementation MyNavigationController

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    - (BOOL)shouldAutorotate {
        return YES;
    }
    
    - (NSUInteger)supportedInterfaceOrientations {
        return UIInterfaceOrientationMaskAll;
    }
    ...
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
