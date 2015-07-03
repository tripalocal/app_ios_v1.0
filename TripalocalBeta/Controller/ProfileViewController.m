//
//  ProfileController.m
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameField;
@property (strong, nonatomic) IBOutlet UITextView *bioField;
@property (strong, nonatomic) IBOutlet UILabel *emailField;
@property (strong, nonatomic) IBOutlet UILabel *phoneField;
@property (strong, nonatomic) IBOutlet UIImageView *image;

@end


@implementation ProfileViewController

- (IBAction)logout:(id)sender {
    NSURL *url = [NSURL URLWithString:logoutServiceTestServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];

    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        if ([httpResponse statusCode] == 200) {
            //              Scuccessfully logged out and remove user defualts
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
            [self swapUnloggedinController];
        }
        
#if DEBUG
        NSString *decodedData = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
        NSLog(@"Receiving data = %@", decodedData);
#endif
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)swapUnloggedinController {

    UIViewController *unloggedinViewController = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"unloggedin_controller"];
    
    NSMutableArray *listOfViewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    [listOfViewControllers removeLastObject];
    [listOfViewControllers addObject:unloggedinViewController];
    
    UITabBarItem *myprofileBarItem = [[UITabBarItem alloc] init];
    myprofileBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    myprofileBarItem.selectedImage = [[UIImage imageNamed:@"myprofile_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    myprofileBarItem.image = [[UIImage imageNamed:@"myprofile.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    myprofileBarItem.title = nil;
    unloggedinViewController.tabBarItem = myprofileBarItem;
    
    [self.tabBarController setViewControllers:listOfViewControllers];
}


- (void) getProfileInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastName = [userDefaults stringForKey:@"user_last_name"];
    NSString *firstName = [userDefaults stringForKey:@"user_first_name"];
    
    self.usernameField.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    self.phoneField.text = [userDefaults stringForKey:@"user_phone_number"];
    self.bioField.text = [userDefaults stringForKey:@"user_bio"];
    self.emailField.text = [userDefaults stringForKey:@"user_email"];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    self.image.image = image;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self getProfileInfo];
    }
}

@end
