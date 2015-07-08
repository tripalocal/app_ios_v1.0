//
//  MenuViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 8/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MenuViewController.h"
#import "Constant.h"

@interface MenuViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *image;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    if (token) {
        if (image) {
            self.image.image = image;
        } else {
            self.image.image = [UIImage imageNamed: @"default_profile_image.png"];
        }
    }
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
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
