//
//  PaymentSuccessViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 8/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentSuccessViewController.h"

@interface PaymentSuccessViewController ()

@end

@implementation PaymentSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goToMyTrip:(id)sender {
    [self performSegueWithIdentifier:@"unwind_to_home" sender:self];
}

@end
