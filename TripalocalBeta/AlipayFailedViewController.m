//
//  AlipayFailedViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 24/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "AlipayFailedViewController.h"

@interface AlipayFailedViewController ()
@property (strong, nonatomic) IBOutlet UILabel *orderNumberLabel;

@end

@implementation AlipayFailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewItInMyTrips.layer setMasksToBounds:YES];
    [self.viewItInMyTrips.layer setCornerRadius:5.0f];
    
    [self.orderNumberLabel.text stringByAppendingString: self.orderNumber];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
