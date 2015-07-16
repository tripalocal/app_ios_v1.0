//
//  smsVerificationViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 15/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
extern float const DISABLE_ALPHA;

@interface SmsVerificationViewController : UIViewController  <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *telephoneField;
@property (strong, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UILabel *alreadyMember;
@property (strong, nonatomic) IBOutlet UIButton *gotoLoginButton;
@property (strong, nonatomic) IBOutlet UITextField *verificationCodeField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *alreadyMemberConstraint;
@end
