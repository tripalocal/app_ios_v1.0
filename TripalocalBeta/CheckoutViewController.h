//
//  CheckoutViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentOptionViewController.h"

@interface CheckoutViewController : UIViewController <UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic) NSInteger guestNumber;
@property (nonatomic) NSNumber *unitPrice;
@property (nonatomic) NSNumber *totalPrice;
@property (nonatomic) NSInteger hours;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property NSString *exp_ID_string;
@property NSString *expTitleString;
@property UIImage *expImage;
@property NSString *fixPriceString;
@property NSMutableArray *dynamicPriceArray;
@property NSMutableArray *availbleDateArray;
@property NSString *durationString;
@property NSString *languageString;
@property NSNumber *maxGuestNum;
@property NSNumber *minGuestNum;

@property (weak, nonatomic) IBOutlet UIPickerView *datePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *guestPicker;
@property (weak, nonatomic) IBOutlet UILabel *expTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;


@end
