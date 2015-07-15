//
//  smsVerificationViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 15/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "SmsVerificationViewController.h"
#import "PhoneSIgnupViewController.h"
#include <stdlib.h>
#import "Constant.h"

NSInteger const VERI_CODE_LENGTH = 5;
NSInteger const PHONE_NUMBER_LENGTH = 11;
float const DISABLE_ALPHA = 0.8;
NSInteger const COUNT_DOWN_SECONDS = 60;

@interface SmsVerificationViewController ()
// make this field singleton
@property (nonatomic,retain) NSNumber *i;
@property (nonatomic, retain) NSString *verificationCode;
@end

@implementation SmsVerificationViewController {
    NSTimer *timer;
    NSInteger nVeriTrial;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    nVeriTrial = 3;
    self.telephoneField.delegate = self;
    self.verificationCodeField.delegate = self;

    [self.sendCodeButton setEnabled:NO];
    self.sendCodeButton.alpha = DISABLE_ALPHA;
    [self.verificationCodeField setHidden:YES];
    [self.confirmButton setHidden:YES];
    
    [self.sendCodeButton.layer setMasksToBounds:YES];
    [self.sendCodeButton.layer setCornerRadius:5.0f];
    [self.confirmButton.layer setMasksToBounds:YES];
    [self.confirmButton.layer setCornerRadius:5.0f];
    
    UIImage *targetImage = [UIImage imageNamed:@"backgroundImage.jpg"];
    // redraw the image to fit view's size
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.f);
    [targetImage drawInRect:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resultImage];
}

- (IBAction)telephoneFieldChanged:(id)sender {
    if (self.telephoneField.text && self.telephoneField.text.length == PHONE_NUMBER_LENGTH) {
        [self.sendCodeButton setEnabled:YES];
        self.sendCodeButton.alpha = 1;
    } else {
        [self.sendCodeButton setEnabled:NO];
        self.sendCodeButton.alpha = DISABLE_ALPHA;
    }
}

- (IBAction)verificationFieldChanged:(id)sender {
    if (self.verificationCodeField.text && self.verificationCodeField.text.length == VERI_CODE_LENGTH) {
        [self.confirmButton setEnabled:YES];
        self.confirmButton.alpha = 1;
    } else {
        [self.confirmButton setEnabled:NO];
        self.confirmButton.alpha = DISABLE_ALPHA;
    }
}

- (IBAction)sendVerificationRequest:(id)sender {
    self.i = @(COUNT_DOWN_SECONDS);
    [self.telephoneField setEnabled:NO];
    [self.sendCodeButton setEnabled:NO];
    self.sendCodeButton.alpha = DISABLE_ALPHA;
    
    [self.verificationCodeField setHidden:NO];
    [self.confirmButton setHidden:NO];

    self.verificationCode = [self generateVerificationCode];
    BOOL result = [self sendVerificationCode:self.verificationCode];
    
    if (result == YES) {
        [self startTimer];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_no_error", nil)
                                                        message:NSLocalizedString(@"phone_no_error_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
        [self.telephoneField setEnabled:YES];
        [self.sendCodeButton setEnabled:YES];
        self.sendCodeButton.alpha = 1;
    }
}

-(void)startTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(aTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)aTime {
    if ([self.i isEqualToNumber:@(0)]) {
        [self resetState];
    } else {
        [UIView setAnimationsEnabled:NO];
        [self.sendCodeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"verification_count_msg", nil), [self.i stringValue]] forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
    }
    
    self.i = @([self.i intValue] - 1);
}

- (void)resetState {
    [self.sendCodeButton setEnabled:YES];
    [self.telephoneField setEnabled:YES];
    self.sendCodeButton.alpha = 1;
    [self.sendCodeButton setTitle:NSLocalizedString(@"verfication_expire", nil) forState:UIControlStateNormal];
    [self.verificationCodeField setHidden:YES];
    self.verificationCodeField.text = @"";
    [self.confirmButton setHidden:YES];
    [self.confirmButton setEnabled:NO];
    self.confirmButton.alpha = DISABLE_ALPHA;
    
    self.i = @(COUNT_DOWN_SECONDS);
    nVeriTrial = 3;
    [timer invalidate];
}

- (IBAction)confirmCode:(id)sender {
    nVeriTrial -= 1;
    if ([self.verificationCode isEqualToString:self.verificationCodeField.text]) {
        [self performSegueWithIdentifier:@"telephone_signup" sender:nil];
    } else if (nVeriTrial > 0) {
        NSString *verificationHint = [NSString stringWithFormat:NSLocalizedString(@"verification_hint", nil), nVeriTrial];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Wrong Verification Code", nil)
                                                        message:verificationHint
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self resetState];
    }
}

- (NSString *)generateVerificationCode {
    NSString *code = @"";
    for (int i = 0; i < VERI_CODE_LENGTH; i++) {
        int r = arc4random_uniform(10);
        code = [code stringByAppendingString:[@(r) stringValue]];
    }
#if DEBUG
    NSLog(@"Verification code generated: %@", code);
#endif
    return code;
}

- (BOOL)sendVerificationCode:(NSString *)code {
    NSString *msgContent = [NSString stringWithFormat:NSLocalizedString(@"sms_content", nil), code];
    NSString *urlString = [NSString stringWithFormat:@"%@HttpBatchSendSM?account=%@&pswd=%@&mobile=%@&msg=%@&needstatus=true", phoneRegURL, phoneRegUsername, phoneRegPwd, self.telephoneField.text, msgContent];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *firstRowString = [[dataString componentsSeparatedByString: @"\n"] objectAtIndex:0];
        NSString *returnCode = [[firstRowString componentsSeparatedByString:@","] objectAtIndex:1];
        
        if ([returnCode isEqualToString:@"0"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 1;
    if (textField == self.telephoneField) {
        maxLength = PHONE_NUMBER_LENGTH;
    } else if (textField == self.verificationCodeField) {
        maxLength = VERI_CODE_LENGTH;
    }
    
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= maxLength;
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"telephone_signup"]) {
        PhoneSIgnupViewController *vc = (PhoneSIgnupViewController *)segue.destinationViewController;
        vc.phoneNumber = self.telephoneField.text;
    }
}

@end
