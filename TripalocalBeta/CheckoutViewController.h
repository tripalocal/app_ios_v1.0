//
//  CheckoutViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKPickerView.h"
#import "PaymentOptionViewController.h"

@interface CheckoutViewController : UIViewController <UITextFieldDelegate,UIPickerViewDataSource, UIPickerViewDelegate, AKPickerViewDataSource, AKPickerViewDelegate, UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) NSInteger guestNumber;
@property (nonatomic) NSNumber *unitPrice;
@property (nonatomic) NSNumber *totalPrice;
@property (nonatomic) NSInteger hours;
@property (nonatomic) NSString *hostName;

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
@property (weak, nonatomic) IBOutlet UITextField *couponField;

@property (retain, nonatomic) UIPickerView *datePicker;
@property (retain, nonatomic) UIPickerView *timePicker;
@property (retain, nonatomic) IBOutlet UIView *guestView;
@property (retain, nonatomic) AKPickerView *guestPickerView;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UILabel *expTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLangLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (weak, nonatomic) IBOutlet UITableView *instantTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableVisibleConstrain;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end
