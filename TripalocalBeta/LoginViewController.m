//
//  LoginViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 30/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "LoginViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "URLConfig.h"
#import "Utility.h"
#import "Constant.h"
#import "Mixpanel.h"

@interface LoginViewController ()
@property(strong, nonatomic) IBOutlet UITextField *emailField;
@property(strong, nonatomic) IBOutlet UITextField *passwordField;
@property(strong, nonatomic) IBOutlet UITextView *forgotPasswordText;
@property(strong, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation LoginViewController

- (IBAction)dismissLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)login:(id)sender {
    [self.loginButton setEnabled:NO];
    NSURL *url = [NSURL URLWithString:[URLConfig loginServiceURLString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

    NSDictionary *tmp = @{@"email" : self.emailField.text,
            @"password" : self.passwordField.text};

    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:nil];
    [request setHTTPBody:postdata];

#if DEBUG
    NSString *decodedData = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
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
            NSString *token = result[@"token"];
            [self fetchProfileAndCache:token];

            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setSecretObject:token forKey:@"user_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.unloggedinVC hideUnloggedinView];
#ifndef DEBUG
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
            
            if (token) {
                NSString * userEmail = [userDefaults stringForKey:@"user_email"];
                [mixpanel identify:userEmail];
            }
            
            [mixpanel track:mpTrackSignin properties:@{@"language":language}];
#endif
            
#ifdef CN_VERSION
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
#else
                [self dismissViewControllerAnimated:YES completion:nil];
#endif
        } else {
            NSString *errorMsg = result[@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login_failed", nil)
                                                            message:errorMsg
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }

#if DEBUG
        decodedData = [[NSString alloc] initWithData:data
                                            encoding:NSUTF8StringEncoding];
        NSLog(@"Receiving data = %@", decodedData);
#endif
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg",nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }

    [self.loginButton setEnabled:YES];
}


- (IBAction)changeToSignup:(id)sender {
    NSLog(@"conditional signup");
#ifdef CN_VERSION
        [self dismissViewControllerAnimated:YES completion:nil];
#else
        [self performSegueWithIdentifier:@"normal_signup" sender:nil];
#endif
}

- (IBAction)inputFieldChanged:(id)sender {
    if (self.emailField.text && self.passwordField.text && self.emailField.text.length > 0 && self.passwordField.text.length > 0) {
        [self.loginButton setEnabled:YES];
        self.loginButton.alpha = 1;
    } else {
        [self.loginButton setEnabled:NO];
        self.loginButton.alpha = 0.5;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginButton.alpha = 0.5;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:5.0f];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;

    [self.forgotPasswordText setLinkTextAttributes:@{NSForegroundColorAttributeName : [Utility themeColor]}];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Forgot password?", nil)];
    [str addAttribute:NSLinkAttributeName value:@"https://tripalocal.com/accounts/password/reset/" range:NSMakeRange(0, str.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, str.length)];

    self.forgotPasswordText.attributedText = str;
}

- (void)dismissKeyboard {
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

@end
