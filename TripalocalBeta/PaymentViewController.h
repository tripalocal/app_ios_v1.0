//
//  PaymentViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 29/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@interface PaymentViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic) NSInteger guestNumber;
@property (nonatomic) NSNumber *unitPrice;
@property (nonatomic) NSNumber *totalPrice;
@property (nonatomic) NSString *coupon;
@property (nonatomic) NSString *expId;
@property (nonatomic) NSString *date;
@property (nonatomic) NSString *timePeriod;

@end
