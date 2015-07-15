//
//  smsVerificationViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 15/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "SmsVerificationViewController.h"
#include <stdlib.h>
#import "Constant.h"

NSInteger const VERI_CODE_LENGTH = 5;

@interface SmsVerificationViewController ()
// make this field singleton
@property (nonatomic,retain) NSNumber *i;
@property (nonatomic, retain) NSString *verificationCode;
@end

@implementation SmsVerificationViewController {
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.telephoneField.delegate = self;
    self.telephoneField.borderStyle = UITextBorderStyleRoundedRect;
    self.verificationCodeField.delegate = self;
    self.verificationCodeField.borderStyle = UITextBorderStyleRoundedRect;

    [self.sendCodeButton setEnabled:NO];
    self.sendCodeButton.alpha = 0.5;
    [self.verificationCodeField setHidden:YES];
    [self.confirmButton setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissSignup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissLoginAndSignup:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)telephoneFieldChanged:(id)sender {
    if (self.telephoneField.text && self.telephoneField.text.length == 11) {
        [self.sendCodeButton setEnabled:YES];
        self.sendCodeButton.alpha = 1;
    } else {
        [self.sendCodeButton setEnabled:NO];
        self.sendCodeButton.alpha = 0.5;
    }
}

- (IBAction)verificationFieldChanged:(id)sender {
    if (self.verificationCodeField.text && self.verificationCodeField.text.length == 5) {
        [self.confirmButton setEnabled:YES];
        self.confirmButton.alpha = 1;
    } else {
        [self.confirmButton setEnabled:NO];
        self.confirmButton.alpha = 0.5;
    }
}

- (IBAction)sendVerificationRequest:(id)sender {
    self.i = @(60);
    [self.telephoneField setEnabled:NO];
    [self.sendCodeButton setEnabled:NO];
    self.sendCodeButton.alpha = 0.5;
    
    [self.verificationCodeField setHidden:NO];
    [self.confirmButton setHidden:NO];
    [self.confirmButton setEnabled:NO];
    self.confirmButton.alpha = 0.5;

    self.verificationCode = [self generateVerificationCode];
    BOOL result = [self sendVerificationCode:self.verificationCode];
    
    if (result == YES) {
        [self startTimer];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Telephone number invalid"
                                                        message:@"Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self.telephoneField setEnabled:YES];
        [self.sendCodeButton setEnabled:YES];
        self.sendCodeButton.alpha = 1;
    }

}

-(void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(aTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)aTime
{
    NSInteger temp = [self.i integerValue];
    [self.sendCodeButton setTitle:[@(temp) stringValue] forState:UIControlStateNormal];
    
    if (temp == 0) {
        [timer invalidate];
        [self.sendCodeButton setEnabled:YES];
        [self.telephoneField setEnabled:YES];
        self.sendCodeButton.alpha = 1;
        [self.sendCodeButton setTitle:NSLocalizedString(@"send_verification_code", nil) forState:UIControlStateNormal];
        self.i = @(59);
    } else {
        [UIView setAnimationsEnabled:NO];
        [self.sendCodeButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"verification_count_msg", nil), [self.i stringValue]] forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
    }
    
    self.i = @([self.i intValue] - 1);
}

- (IBAction)confirmCode:(id)sender {
    if ([self.verificationCode isEqualToString:self.verificationCodeField.text]) {
        [self performSegueWithIdentifier:@"telephone_signup" sender:nil];
    } else {
        //if times left is 0, change verification code.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wrong Verification Code"
                                                        message:@"You have n times left"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (NSString *)generateVerificationCode {
    NSString *code = @"";
    for (int i = 0; i < VERI_CODE_LENGTH; i++) {
        int r = arc4random_uniform(10);
        code = [code stringByAppendingString:[@(r) stringValue]];
    }

    return code;
}

- (BOOL)sendVerificationCode:(NSString *)code {
    NSString *msgContent = code;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 1;
    
    if (textField == self.telephoneField) {
        maxLength = 11;
    } else if (textField == self.verificationCodeField) {
        maxLength = 5;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
