//
//  EditProfileViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 8/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Constant.h"

@interface EditProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameField;
@property (strong, nonatomic) IBOutlet UITextView *bioField;
@property (strong, nonatomic) IBOutlet UILabel *emailField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUserProfile];
    UIBarButtonItem *saveProfileButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile)];
    self.navigationItem.rightBarButtonItem = saveProfileButton;
}

- (void) saveProfile {
    [self.navigationController popViewControllerAnimated:YES];
    NSURL *url = [NSURL URLWithString:myprofileServiceTestServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         self.phoneNumber.text, @"phone_number",
                         nil];
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:nil];
    [request setHTTPBody:postdata];
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        if ([httpResponse statusCode] == 200) {
            
            [userDefaults setObject:self.phoneNumber.text forKey:@"user_phone_number"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error"
                                                            message:@"Save Profile Failed"
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setUserProfile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastName = [userDefaults stringForKey:@"user_last_name"];
    NSString *firstName = [userDefaults stringForKey:@"user_first_name"];
    
    self.usernameField.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    self.phoneNumber.text = [userDefaults stringForKey:@"user_phone_number"];
    self.bioField.text = [userDefaults stringForKey:@"user_bio"];
    self.emailField.text = [userDefaults stringForKey:@"user_email"];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    if (image) {
        self.image.image = image;
    } else {
        self.image.image = [UIImage imageNamed: @"default_profile_image.png"];
    }
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

@end
