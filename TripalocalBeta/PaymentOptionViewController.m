//
//  PaymentOptionViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentOptionViewController.h"

@interface PaymentOptionViewController ()

@end

@implementation PaymentOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"payByCreditCard"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PaymentViewController *controller = (PaymentViewController *)navController.topViewController;
        
        controller.expId = self.expId;
        controller.guestNumber = self.guestNumber;
        controller.date = self.date;
        controller.timePeriod = self.timePeriod;
        controller.unitPrice = self.unitPrice;
    }
}

@end
