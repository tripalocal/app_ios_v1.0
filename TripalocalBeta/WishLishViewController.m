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
#import "TLDetailViewController.h"
#import "LocalDetailViewController.h"
#import "Utility.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "JGProgressHUD.h"

@interface WishLishViewController ()

@end

@implementation WishLishViewController {
    UIRefreshControl *refreshControl;
    JGProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *cancalButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissWishList:)];
    cancalButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = cancalButton;
    
    self.navigationItem.title = NSLocalizedString(@"wishlist_title", nil);
    if (!self.expList)
    {
        self.expList = [self fetchExpData];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [Utility themeColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(reloadData)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    [HUD showInView:self.view];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [HUD dismissAfterDelay:1.0];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

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
            NSNumber *expId = self.expList[i][@"experience_id"];
            [origWishList addObject:[expId stringValue]];
        }
        if (![wishList isEqualToSet:origWishList])
        {
            self.expList = [self fetchExpData];
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

- (NSMutableArray *)fetchExpData {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *wishList = [userDefaults objectForKey:@"wish_list"];
    for (NSString *expID in wishList) {
        NSString *queryString = [NSString stringWithFormat:@"%@?experience_id=%@",[URLConfig expDetailServiceURLString],expID];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:queryString]];
        [request setHTTPMethod:@"GET"];

        NSError *connectionError = nil;
        NSURLResponse *response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
        
        if (connectionError == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSDictionary *exp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([httpResponse statusCode] == 200) {
//                NSMutableDictionary *resultExp = [[NSMutableDictionary alloc] init];
//                [resultExp setObject:[exp objectForKey:@"experience_duration"] forKey:@"duration"];
//                [resultExp setObject:[exp objectForKey:@"experience_title"] forKey:@"title"];
//                [resultExp setObject:[exp objectForKey:@"experience_language"] forKey:@"language"];
//                [resultExp setObject:[exp objectForKey:@"experience_description"] forKey:@"description"];
//                
//                NSMutableArray *dynamicPriceArray = [exp objectForKey:@"experience_dynamic_price"];
//                NSNumber *maxGuestNum = [exp objectForKey:@"experience_guest_number_max"];
//                NSNumber *minGuestNum = [exp objectForKey:@"experience_guest_number_min"];
//                
//                NSNumber *priceNumber = nil;
//                if ([dynamicPriceArray count] == 0) {
//                    priceNumber = exp[@"experience_price"];
//                } else if ([minGuestNum intValue] <= 4 && [maxGuestNum intValue] >= 4) {
//                    priceNumber = dynamicPriceArray[4 - [minGuestNum intValue]];
//                } else if ([minGuestNum intValue] > 4) {
//                    priceNumber = dynamicPriceArray[0];
//                } else if ([maxGuestNum intValue] < 4) {
//                    priceNumber = [dynamicPriceArray lastObject];
//                }

//                [resultExp setObject:[Utility decimalwithFormat:@"0" floatV:[priceNumber floatValue]] forKey:@"price"];

//                [resultExp setObject:[exp objectForKey:@"host_image"]forKey:@"host_image"];
//                [resultExp setObject:[NSNumber numberWithInt:[expID intValue]]forKey:@"id"];
                [expList addObject:exp];
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
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
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


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SearchCell";
    static NSString *cellIdentifier2 = @"SearchCell2";
    
    TLSearchTableViewCell *cell;
    
    NSDictionary *exp = [self.expList objectAtIndex:indexPath.row];
    
    if ([exp[@"experience_type"] isEqualToString:@"PRIVATE"] || [exp[@"experience_type"] isEqualToString:@"NONPRIVATE"]) {
        cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        NSString *hostImageRelativeURL = exp[@"host_image"];
        if (hostImageRelativeURL != (id)[NSNull null] && hostImageRelativeURL.length > 0) {
            NSString *hostImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: hostImageRelativeURL];
            
            [cell.hostImage sd_setImageWithURL:[NSURL URLWithString:hostImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];
        } else {
            cell.hostImage.image = [UIImage imageNamed:@"default_profile_image.png"];
        }
        
        cell.titleLabel.text = exp[@"experience_title"];
        cell.descriptionLabel.text = exp[@"experience_description"];
        
    } else if ([exp[@"experience_type"] isEqualToString:@"PrivateProduct"] || [exp[@"experience_type"] isEqualToString:@"PublicProduct"]) {
        cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if(!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell2" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        }
        
        cell.titleLabel.text = exp[@"title"];
        cell.descriptionLabel.text = exp[@"description"];
    }
    
    NSString *expIdString = [exp[@"experience_id"] stringValue];
    
    NSString *duration = [exp[@"experience_duration"] stringValue];
    NSString *handledDurationString = [duration stringByAppendingString:NSLocalizedString(@"Hours", nil)];
    cell.durationLabel.text = handledDurationString;
    cell.languageLabel.text = [Utility transformLanugage:(NSString *)exp[@"experience_language"]];
    
    NSString *backgroundImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], expIdString];
    
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.experienceImage.center;
    activityIndicator.hidesWhenStopped = YES;
    [cell.experienceImage addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [cell.experienceImage sd_setImageWithURL:[NSURL URLWithString:backgroundImageURL]
                            placeholderImage:nil
                                     options:0
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       [activityIndicator removeFromSuperview];
                                   }];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *wishList = [userDefaults objectForKey:@"wish_list"];
    
    if ([wishList containsObject:expIdString]) {
        [cell.wishListButton setBackgroundImage:[UIImage imageNamed:@"wishlisted.png"] forState:UIControlStateNormal];
        cell.smallWishImage.image = [UIImage imageNamed:@"heart_sr.png"];
        cell.wishStatus.text = NSLocalizedString(@"Saved", nil);;
    } else {
        [cell.wishListButton setBackgroundImage:[UIImage imageNamed:@"unwishlisted.png"] forState:UIControlStateNormal];
        cell.smallWishImage.image = [UIImage imageNamed:@"heart_sw.png"];
        cell.wishStatus.text = NSLocalizedString(@"add_to_wishlist", nil);
    }
    cell.delegate = self;
    cell.wishListButton.tag = indexPath.row;
    NSString *priceString = [Utility decimalwithFormat:@"0" floatV:[exp[@"experience_price"] floatValue]];
    cell.priceLabel.text = priceString;
    

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 340.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)saveToWishListClicked:(NSInteger)buttonTag {
    [self toggleWishList: buttonTag];
}

- (IBAction)toggleWishList:(NSInteger)buttonTag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    NSIndexPath * index = [NSIndexPath indexPathForRow:buttonTag inSection:0];
    
    if (token) {
        NSString *expIdString = [self.expList[index.row][@"experience_id"] stringValue];
        NSMutableArray *wishList = [NSMutableArray arrayWithArray:(NSArray *)[userDefaults objectForKey:@"wish_list"]];
        if ([wishList containsObject:expIdString]) {
            [wishList removeObject:expIdString];
        } else {
            [wishList addObject:expIdString];
        }
        
        [userDefaults setObject:wishList forKey:@"wish_list"];
        [userDefaults synchronize];
        
        NSArray *indexPaths = @[index];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    } else {
        [self performSegueWithIdentifier:@"login_segue" sender:nil];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *expType = self.expList[indexPath.row][@"experience_type"];
    if ([expType isEqualToString:@"PRIVATE"] || [expType isEqualToString:@"NONPRIVATE"]) {
        [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
    } else if ([expType isEqualToString:@"PrivateProduct"] || [expType isEqualToString:@"PublicProduct"]) {
        [self performSegueWithIdentifier:@"LocalSearchResultSegue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *exp = self.expList[self.tableView.indexPathForSelectedRow.row];
    if ([segue.identifier isEqualToString:@"SearchResultSegue"]) {
        TLDetailViewController *vc = (TLDetailViewController *)segue.destinationViewController;
        vc.expType = @"PRIVATE";
        vc.experience_id_string = [exp[@"experience_id"] stringValue];
        vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[exp[@"experience_price"] floatValue]];
        
    } else if ([segue.identifier isEqualToString:@"LocalSearchResultSegue"]) {
        LocalDetailViewController *vc = (LocalDetailViewController *) segue.destinationViewController;
        vc.expType = @"LOCAL";
        vc.experience_id_string = [exp[@"experience_id"] stringValue];
        vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[exp[@"experience_price"] floatValue]];
        
    }
}

- (IBAction)dismissWishList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
