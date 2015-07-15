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
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *hostName;
@property (strong, nonatomic) IBOutlet UIView *wishLIstImage;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    NSString *origHostName = [userDefaults objectForKey:@"host_name"];
    NSArray *array = [origHostName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    NSString *firstName = [array objectAtIndex:1];
    NSString *lastName = [array objectAtIndex:0];
    NSString *lastNameInitial = [[lastName substringWithRange:NSMakeRange(0, 1)] stringByAppendingString:@"."];
    
    self.hostName.text = [[NSArray arrayWithObjects:firstName, lastNameInitial, nil] componentsJoinedByString:@" "];
    
    if (image) {
        self.image.image = image;
    } else {
        self.image.image = [UIImage imageNamed: @"default_profile_image.png"];
    }
    
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
    self.backgroundView.layer.borderWidth = 1;
    
    self.image.layer.cornerRadius = self.image.frame.size.height / 2;
    self.image.layer.masksToBounds = YES;
    self.image.layer.borderColor = [UIColor whiteColor].CGColor;
    self.image.layer.borderWidth = 3.0f;
    
    UITapGestureRecognizer *hostImageSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHostImage)];
    hostImageSingleTap.numberOfTapsRequired = 1;
    [self.image setUserInteractionEnabled:YES];
    [self.image addGestureRecognizer:hostImageSingleTap];
    
    UITapGestureRecognizer *wishListSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wishListTapped)];
    wishListSingleTap.numberOfTapsRequired = 1;
    [self.wishLIstImage setUserInteractionEnabled:YES];
    [self.wishLIstImage addGestureRecognizer:wishListSingleTap];
}


-(void)wishListTapped{
    [self performSegueWithIdentifier:@"show_wishlist" sender:self];
}

-(void)tapHostImage{
    NSLog(@"single Tap on imageview");
    [self performSegueWithIdentifier:@"show_my_profile" sender:self];
}

- (IBAction)logout:(id)sender {
    NSURL *url = [NSURL URLWithString:NSLocalizedString(logoutServiceURL, nil)];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}


@end
