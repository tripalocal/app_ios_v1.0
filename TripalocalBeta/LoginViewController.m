//
//  LoginViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 30/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation LoginViewController

- (IBAction)dismissLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)login:(id)sender {
    [self.loginButton setEnabled:NO];
    NSURL *url = [NSURL URLWithString:loginServiceTestServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *body =  [NSString stringWithFormat:@"email=%@&password=%@", self.emailField.text, self.passwordField.text];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    void (^resultHandler) (NSURLResponse *response,
                           NSData *data, NSError *connectionError) = ^(NSURLResponse *response,
                                                                       NSData *data, NSError *connectionError){
        NSString *jsonStringResult = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
        NSLog(@"JSON data = %@", jsonStringResult);
        
        if (connectionError == nil) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:nil];

            NSInteger userId = [[result objectForKey:@"user_id"] integerValue];
            NSString *token = [result objectForKey:@"token"];
//            Successflly login
//            {
//                "token": "cc99d502c5cf2b03342d0a60f81a20e49a24f77f",
//                "user_id": 455
//            }
            if (userId && token) {
                
            } else {
                NSString *errorMsg = [result objectForKey:@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                message:errorMsg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                            message:@"You must be connected to the internet."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        [self.loginButton setEnabled:YES];
    };
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler: resultHandler];
}

- (IBAction)facebookLogin:(id)sender {
    NSLog(@"facebookloginclicked");
}

- (IBAction)inputFieldChanged:(id)sender {
    if (self.emailField.text && self.passwordField.text && self.emailField.text.length > 0 && self.passwordField.text.length > 0) {
        [self.loginButton setEnabled:YES];
    } else {
        [self.loginButton setEnabled:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.tableView addGestureRecognizer:tap];
    
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.tableView.alwaysBounceVertical = NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     
//}

@end
