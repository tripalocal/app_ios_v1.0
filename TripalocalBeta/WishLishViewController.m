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

@implementation WishLishViewController {
    UIRefreshControl *refreshControl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"wishlist_title", nil);
    if (!self.expList)
    {
        self.expList = [self fetchExpData:self.cityName];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor colorWithRed:0.20f green:0.80f blue:0.80f alpha:1.0f];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)reloadData
{
    if (!refreshControl)
    {
        return;
    }
    
    if ([self.expList count] != 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSSet *wishList = [NSSet setWithArray:(NSArray *)[userDefaults objectForKey:@"wish_list"]];
        NSMutableSet *origWishList = [[NSMutableSet alloc] init];
        
        for (int i = 0; i < [self.expList count]; i++)
        {
            NSNumber *expId = self.expList[i][@"id"];
            [origWishList addObject:[expId stringValue]];
        }
        if (![wishList isEqualToSet:origWishList])
        {
            self.expList = [self fetchExpData:self.cityName];
        }
        
        [self.tableView reloadData];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    refreshControl.attributedTitle = attributedTitle;
    [refreshControl endRefreshing];
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
                
                NSMutableArray *dynamicPriceArray = [exp objectForKey:@"experience_dynamic_price"];
                NSNumber *maxGuestNum = [exp objectForKey:@"experience_guest_number_max"];
                NSNumber *minGuestNum = [exp objectForKey:@"experience_guest_number_min"];
                
                NSNumber *priceNumber = nil;
                if ([dynamicPriceArray count] == 0) {
                    priceNumber = exp[@"experience_price"];
                } else if ([minGuestNum intValue] <= 4 && [maxGuestNum intValue] >= 4) {
                    priceNumber = dynamicPriceArray[4 - [minGuestNum intValue]];
                } else if ([minGuestNum intValue] > 4) {
                    priceNumber = dynamicPriceArray[0];
                } else if ([maxGuestNum intValue] < 4) {
                    priceNumber = [dynamicPriceArray lastObject];
                }

                [resultExp setObject:[self decimalwithFormat:@"0" floatV:[priceNumber floatValue]] forKey:@"price"];

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

- (NSString *) decimalwithFormat:(NSString *)format floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self.view sendSubviewToBack:self.needToLoginView];
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
