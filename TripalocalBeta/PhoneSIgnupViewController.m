//
//  PhoneSIgnupViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 15/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "URLConfig.h"
#import "PhoneSIgnupViewController.h"
#import "SmsVerificationViewController.h"

NSInteger const NAME_MAX_LENGTH = 10;
NSInteger const PWD_MAX_LENGTH = 15;
NSInteger const EMAIL_MAX_LENGTH = 20;

@interface PhoneSIgnupViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *passwordAgainField;
@property (strong, nonatomic) IBOutlet UITextField *firstnameField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameField;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@end

@implementation PhoneSIgnupViewController {
    UIColor *INACTIVE_COLOR;
    UIColor *THEME_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    INACTIVE_COLOR = [UIColor colorWithRed:204.0f/255.0f
                                     green:204.0f/255.0f
                                      blue:204.0f/255.0f
                                     alpha:1.0f];
    THEME_COLOR = [UIColor colorWithRed:0.20f green:0.80f blue:0.80f alpha:1.0f];
    
    [self.signupButton setEnabled:NO];
    [self.signupButton setBackgroundColor:INACTIVE_COLOR];
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.firstnameField.delegate = self;
    self.lastnameField.delegate = self;
    
    [self.signupButton.layer setMasksToBounds:YES];
    [self.signupButton.layer setCornerRadius:5.0f];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.passwordField.secureTextEntry = YES;
    self.passwordAgainField.secureTextEntry = YES;
    
    UIImage * targetImage = [UIImage imageNamed:@"backgroundImage.jpg"];
    // redraw the image to fit view's size
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.f);
    [targetImage drawInRect:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resultImage];
}

- (IBAction)signup:(id)sender {
    if (![self.passwordAgainField.text isEqualToString:self.passwordField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mismatch_pwd", nil)
                                                        message:NSLocalizedString(@"mismatch_pwd_hint", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self.signupButton setEnabled:NO];
        [self.signupButton setBackgroundColor:INACTIVE_COLOR];
        
        NSURL *url = [NSURL URLWithString:[URLConfig signupServiceURLString]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        
        NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                             self.emailField.text, @"email",
                             self.passwordField.text, @"password",
                             self.firstnameField.text, @"first_name",
                             self.lastnameField.text, @"last_name",
                             self.phoneNumber, @"phone_number",
                             nil];
        
        NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:nil];
        [request setHTTPBody:postdata];
        
#if DEBUG
        NSString * decodedData =[[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
        NSLog(@"Sending data = %@", decodedData);
#endif
        NSError *connectionError = nil;
        NSURLResponse *response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        if (connectionError == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:nil];
            if ([httpResponse statusCode] == 200) {
                NSString *token = [result objectForKey:@"token"];
                [self fetchProfileAndCache: token];
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:token forKey:@"user_token"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                
            } else {
                NSString *errorMsg = [result objectForKey:@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"signup_failed", nil)
                                                                message:errorMsg
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
#if DEBUG
            NSString *decodedData = [[NSString alloc] initWithData:data
                                                          encoding:NSUTF8StringEncoding];
            NSLog(@"Receiving data = %@", decodedData);
#endif
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                            message:NSLocalizedString(@"no_network_msg", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [self.signupButton setEnabled:YES];
        [self.signupButton setBackgroundColor:THEME_COLOR];
    }
    
}

- (IBAction)dismissSignup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inputFieldChanged:(id)sender {
    if (self.emailField.text && self.passwordField.text && self.firstnameField.text && self.lastnameField.text && self.passwordAgainField.text && self.emailField.text.length > 0 && self.passwordField.text.length > 0 && self.firstnameField.text.length > 0 && self.lastnameField.text.length > 0 && self.passwordAgainField.text.length > 0) {
        [self.signupButton setEnabled:YES];
        [self.signupButton setBackgroundColor:THEME_COLOR];
    } else {
        [self.signupButton setEnabled:NO];
        [self.signupButton setBackgroundColor:INACTIVE_COLOR];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 1;
    if (textField == self.firstnameField) {
        maxLength = NAME_MAX_LENGTH;
    } else if (textField == self.lastnameField) {
        maxLength = NAME_MAX_LENGTH;
    } else if (textField == self.passwordField) {
        maxLength = PWD_MAX_LENGTH;
    } else if (textField == self.passwordAgainField) {
        maxLength = PWD_MAX_LENGTH;
    } else if (textField == self.emailField) {
        maxLength = EMAIL_MAX_LENGTH;
    }
    
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= maxLength;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
