//
//  SignUpViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 30/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "SignUpViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "Utility.h"
#import "URLConfig.h"
#import "Mixpanel.h"
#import "Constant.h"

@interface SignUpViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *firstnameField;
@property (strong, nonatomic) IBOutlet UITextField *lastnameField;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) IBOutlet UITextView *termsTextView;

@end

@implementation SignUpViewController

- (IBAction)facebookSignup:(id)sender {
}

- (IBAction)dismissLoginAndSignup:(id)sender {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)mpTrackSignup:(NSUserDefaults *)userDefaults token:(NSString *)token {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    if (token) {
        NSString * userEmail = [userDefaults stringForKey:@"user_email"];
        [mixpanel identify:userEmail];
        [mixpanel.people set:@{}];
    }
    
    [mixpanel track:mpTrackSignup properties:@{@"language":language}];
}

- (IBAction)signup:(id)sender {
    BOOL success;
    [self.signupButton setEnabled:NO];
    self.signupButton.alpha = 0.5;
    
    NSURL *url = [NSURL URLWithString:[URLConfig signupServiceURLString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         self.emailField.text, @"email",
                         self.passwordField.text, @"password",
                         self.firstnameField.text, @"first_name",
                         self.lastnameField.text, @"last_name",
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
            NSString *user_id = [result objectForKey:@"user_id"];
            
            [self fetchProfileAndCache: token];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setSecretObject:token forKey:@"user_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //sign up the openfire account
            NSString *username = [NSString stringWithFormat:@"%@%@",user_id,@"@tripalocal.com"];
            NSString *password = [NSString stringWithFormat:@"%@", user_id];
            
            AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            del.xmppStream.myJID = [XMPPJID jidWithString:username];
            
            NSLog(@"Does supports registration");
            NSLog(@"Attempting registration for username %@",del.xmppStream.myJID.bare);
            NSError *error = nil;
            success = [del.xmppStream registerWithPassword:password error:&error];
            if (success)
            {
                del.isRegistering = YES;
                NSLog(@"Registration in progress");
            }
            else
            {
                NSLog(@"Create user failed");
            }

            
            [self mpTrackSignup:userDefaults token:token];

            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            

        
#if DEBUG
        NSString *decodedData = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
        NSLog(@"Receiving data = %@", decodedData);
#endif
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self.signupButton setEnabled:YES];
    self.signupButton.alpha = 1;
}
}

- (IBAction)dismissSignup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inputFieldChanged:(id)sender {
    if (self.emailField.text && self.passwordField.text && self.firstnameField.text && self.lastnameField.text && self.emailField.text.length > 0 && self.passwordField.text.length > 0 && self.firstnameField.text.length > 0 && self.lastnameField.text.length > 0) {
        [self.signupButton setEnabled:YES];
        self.signupButton.alpha = 1;
    } else {
        [self.signupButton setEnabled:NO];
        self.signupButton.alpha = 0.5;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signupButton.alpha = 0.5;
    [self.signupButton setEnabled:NO];
    [self.signupButton.layer setMasksToBounds:YES];
    [self.signupButton.layer setCornerRadius:5.0f];
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.firstnameField.delegate = self;
    self.lastnameField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.firstnameField.borderStyle = UITextBorderStyleRoundedRect;
    self.lastnameField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;

    [self.termsTextView setLinkTextAttributes:@{NSForegroundColorAttributeName:[Utility themeColor]}];
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"By signing up, I agree to Tripalocal’s Terms of Service, Privacy Policy, and Refund Policy."];
    [str addAttribute: NSLinkAttributeName value: @"https://tripalocal.com/termsofservice" range: NSMakeRange(39, 16)];
    
    [str addAttribute: NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, str.length)];
    [str addAttribute: NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, str.length)];

    [str addAttribute: NSLinkAttributeName value: @"https://tripalocal.com/privacypolicy" range: NSMakeRange(57, 14)];

    [str addAttribute: NSLinkAttributeName value: @"https://tripalocal.com/refundpolicy" range: NSMakeRange(77, 13)];

    self.termsTextView.attributedText = str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
