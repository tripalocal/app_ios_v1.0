//
//  CheckoutViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentOptionViewController.h"

@interface CheckoutViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic) NSInteger guestNumber;
@property (nonatomic) NSNumber *unitPrice;
@property (nonatomic) NSNumber *totalPrice;
@property (nonatomic) NSInteger hours;

@property NSString *exp_ID_string;
@property UIImage *expImage;
@end
