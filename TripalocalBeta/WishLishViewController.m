//
//  WishLishViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 9/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "WishLishViewController.h"
#import "TLSearchViewController.h"
#import "URLConfig.h"

@interface WishLishViewController ()

@end

@implementation WishLishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"wishlist_title", nil);
}

- (NSMutableArray *)fetchExpData:(NSString *) cityName {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *wishList = [userDefaults objectForKey:@"wish_list"];
    for (NSString *expID in wishList) {
        NSString *post = [NSString stringWithFormat:@"{\"experience_id\":\"%@\"}",expID];
#ifdef DEBUG
        NSLog(@"(Detail)POST: %@", post);
#endif
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[URLConfig expDetailhServiceURLString]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        
        NSError *connectionError = nil;
        NSURLResponse *response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        if (connectionError == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSDictionary *exp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([httpResponse statusCode] == 200) {
                NSMutableDictionary *resultExp = [[NSMutableDictionary alloc] init];
                [resultExp setObject:[exp objectForKey:@"experience_duration"] forKey:@"duration"];
                [resultExp setObject:[exp objectForKey:@"experience_title"] forKey:@"title"];
                [resultExp setObject:[exp objectForKey:@"experience_language"] forKey:@"language"];
                [resultExp setObject:[exp objectForKey:@"experience_description"] forKey:@"description"];
                [resultExp setObject:[exp objectForKey:@"experience_price"] forKey:@"price"];
                [resultExp setObject:[exp objectForKey:@"host_image"]forKey:@"host_image"];
                [resultExp setObject:[NSNumber numberWithInt:[expID intValue]]forKey:@"id"];
                [expList addObject:resultExp];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error", nil)
                                                                message:NSLocalizedString(@"connection_failed", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                            message:NSLocalizedString(@"no_network_msg", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    return expList;
}

- (void)loginClicked {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"login_view_controller"];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self.view sendSubviewToBack:self.needToLoginView];
        self.expList = [self fetchExpData:self.cityName];
        [self.tableView reloadData];
    } else {
        self.needToLoginView.delegate = self;
        [self.view bringSubviewToFront:self.needToLoginView];
    }
    
    if ([self.expList count] == 0)
    {
        [[self view] addSubview:self.noDataLabel];
    }
    else
    {
        [self.noDataLabel removeFromSuperview];
    }
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
