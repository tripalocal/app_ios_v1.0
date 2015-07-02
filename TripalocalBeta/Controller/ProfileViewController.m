//
//  ProfileController.m
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextView *bioField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;

@end


@implementation ProfileViewController

- (IBAction)logout:(id)sender {
    NSURL *url = [NSURL URLWithString:logoutServiceTestServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    
    void (^resultHandler) (NSURLResponse *response,
                           NSData *data, NSError *connectionError) = ^(NSURLResponse *response,
                                                                       NSData *data, NSError *connectionError){
        if (connectionError == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            if ([httpResponse statusCode] == 200) {
//              Scuccessfully logged out and remove user defualts
                NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                
                [self swapUnloggedinController];
            }
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:nil];
            NSString *resultString = [result objectForKey:@"result"];
            NSLog(@"%@", resultString);

        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                            message:@"You must be connected to the internet."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    };
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler: resultHandler];
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


- (void) getProfileInfo:(NSString *) token {
    NSURL *url = [NSURL URLWithString:myprofileServiceTestServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    
    void (^resultHandler) (NSURLResponse *response,
                           NSData *data, NSError *connectionError) = ^(NSURLResponse *response,
                                                                       NSData *data, NSError *connectionError){
        if (connectionError == nil) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:nil];
//            {
//                "last_name": "He",
//                "image": "",
//                "id": 455,
//                "first_name": "Ye",
//                "phone_number": "",
//                "bio": "",
//                "rate": null,
//                "email": "yehe01@gmail.com"
//            }
            NSString *lastName = [result objectForKey:@"last_name"];
            NSString *firstName = [result objectForKey:@"first_name"];

            if (lastName && firstName) {
                NSString *email = [result objectForKey:@"email"];
                NSString *bio = [result objectForKey:@"bio"];
                NSString *phoneNumber = [result objectForKey:@"phone_number"];
                
                self.emailField.text = email;
                self.usernameField.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                self.phoneField.text = phoneNumber;
                self.bioField.text = bio;
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                            message:@"You must be connected to the internet."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    };
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler: resultHandler];
    
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self getProfileInfo:token];
    }
}

@end
