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

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property NSString *exp_ID_string;
@property UIImage *expImage;
@property NSMutableArray *dynamicPriceArray;
@property NSMutableArray *availbleDateArray;
@property NSString *expTitle;
@property NSString *durationString;
@property NSString *languageString;

@end
