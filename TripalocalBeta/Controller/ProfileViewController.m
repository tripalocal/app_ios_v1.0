//
//  ProfileController.m
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ProfileViewController.h"
#import "Utility.h"
#import "Constant.h"

@interface ProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameField;
@property (strong, nonatomic) IBOutlet UITextView *bioField;
@property (strong, nonatomic) IBOutlet UILabel *emailField;
@property (strong, nonatomic) IBOutlet UILabel *phoneField;
@property (strong, nonatomic) IBOutlet UIImageView *image;

@end


@implementation ProfileViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancalButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissProfile:)];
    cancalButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = cancalButton;
    
    self.navigationItem.title = NSLocalizedString(@"profile_title", nil);
    UIBarButtonItem *editProfileButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editProfile)];
    editProfileButton.tintColor = [Utility themeColor];
    self.navigationItem.rightBarButtonItem = editProfileButton;
}

- (void)editProfile {
     [self performSegueWithIdentifier:@"edit_profile" sender:self];
}

- (void) setUserProfile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastName = [userDefaults stringForKey:@"user_last_name"];
    NSString *firstName = [userDefaults stringForKey:@"user_first_name"];

    self.usernameField.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    self.phoneField.text = [userDefaults stringForKey:@"user_phone_number"];
    self.bioField.text = [userDefaults stringForKey:@"user_bio"];
    self.emailField.text = [userDefaults stringForKey:@"user_email"];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    if (image) {
        self.image.image = image;
    } else {
        self.image.image = [UIImage imageNamed: @"default_profile_image.png"];
    }

}

- (IBAction)dismissProfile:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setUserProfile];
    [super viewWillAppear:animated];
}


@end
