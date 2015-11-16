//
//  PaymentOptionViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentViewController.h"

@interface PaymentOptionViewController : UITableViewController
@property (nonatomic) NSInteger guestNumber;
@property (nonatomic) NSString *coupon;
@property (nonatomic) NSNumber *unitPrice;
@property (nonatomic) NSNumber *totalPrice;
@property (nonatomic) NSString *expId;
@property (nonatomic) NSString *date;
@property (nonatomic) NSString *timePeriod;
@property (nonatomic) NSString *hostName;
@property (nonatomic) NSString *expType;
@end
