//
//  PhoneSIgnupViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 15/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestController.h"

@interface PhoneSIgnupViewController :RequestController <UITextFieldDelegate>
@property (strong, nonatomic) NSString *phoneNumber;
@end
