//
//  TLSearchViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLSearchViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "TLSearchTableViewCell.h"
#import "Spinner.h"
#import "Constant.h"
#import "URLConfig.h"
#import "Utility.h"
#import "TLDetailViewController.h"
#import "Mixpanel.h"
#import "JGProgressHUD.h"
#import "MultidayTableViewCell.h"
#import "MultidayTableViewCell2.h"
#import "LocalDetailViewController.h"

@interface TLSearchViewController (){
    NSMutableArray *dynamicPricingArray;
}

@property (nonatomic, retain) NSMutableArray *normalExpList;
@property (nonatomic, retain) NSMutableArray *localExpList;
@property (nonatomic, retain) NSMutableArray *itineraryExpList;
@property (nonatomic, retain) NSDictionary *exp;
@end

@implementation TLSearchViewController{
    JGProgressHUD *HUD;
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    UIView *header = self.filterView;

    [header setNeedsLayout];
    [header layoutIfNeeded];

    CGRect frame = header.frame;

    frame.size.height = 70;
    header.frame = frame;

    self.tableView.tableHeaderView = header;
}

- (void)mpTrackViewSearchPage {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    
    if (token) {
        NSString * userEmail = [userDefaults stringForKey:@"user_email"];
        [mixpanel identify:userEmail];
        [mixpanel.people set:@{}];
    }
    
    [mixpanel track:mpTrackViewSearchPage properties:@{@"language":language}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString([self.cityName lowercaseString], nil);
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-LL-dd"];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    [HUD showInView:self.view];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    dynamicPricingArray = [[NSMutableArray alloc]init];
    [HUD dismissAfterDelay:1.0];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self mpTrackViewSearchPage];
    
    [self updateFilterView];
}

- (void)applyFilterWithHandler:(void(^)()) handler {
    if ([self.expSearchType isEqualToString:@"PRIVATE"] && [self.normalExpList count] == 0) {
        [HUD showInView:self.view];
        [self fetchExpData:self.cityName completionHandler:^(NSMutableArray *expList) {
            [HUD dismissAfterDelay:0.3];
            [self.tableView reloadData];
            handler();
        }];
    } else if ([self.expSearchType isEqualToString:@"LOCAL"] && [self.localExpList count] == 0) {
        [HUD showInView:self.view];
        [self fetchExpData:self.cityName completionHandler:^(NSMutableArray *expList) {
            [HUD dismissAfterDelay:0.3];
            [self.tableView reloadData];
            handler();
        }];
    } else if ([self.expSearchType isEqualToString:@"ITI"] && [self.itineraryExpList count] == 0) {
        [HUD showInView:self.view];
        [self fetchExpData:self.cityName completionHandler:^(NSMutableArray *expList) {
            [HUD dismissAfterDelay:0.3];
            [self.tableView reloadData];
            handler();
        }];
    } else {
        [self.tableView reloadData];
        handler();
    }
}

- (void)updateFilterView {
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        self.travelWithLocalsImageView.highlighted = YES;
        self.travelWithLocalsLabel.highlighted = YES;
        
        self.localExpImageView.highlighted = NO;
        self.localExpLabel.highlighted = NO;
        self.itinerariesImageView.highlighted = NO;
        self.itenarariesLabel.highlighted = NO;
        self.navigationItem.title = NSLocalizedString([self.cityName lowercaseString], nil);
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        self.localExpImageView.highlighted = YES;
        self.localExpLabel.highlighted = YES;
        
        self.travelWithLocalsImageView.highlighted = NO;
        self.travelWithLocalsLabel.highlighted = NO;
        self.itinerariesImageView.highlighted = NO;
        self.itenarariesLabel.highlighted = NO;
        self.navigationItem.title = NSLocalizedString([self.cityName lowercaseString], nil);
    } else {
        self.itinerariesImageView.highlighted = YES;
        self.itenarariesLabel.highlighted = YES;
        
        self.travelWithLocalsImageView.highlighted = NO;
        self.travelWithLocalsLabel.highlighted = NO;
        self.localExpImageView.highlighted = NO;
        self.localExpLabel.highlighted = NO;
        self.navigationItem.title = NSLocalizedString(@"itineraries", nil);
    }
}

- (IBAction)applyTravelWithLocals:(UIGestureRecognizer *)sender {
    self.expSearchType = @"PRIVATE";
    [self applyFilterWithHandler:^{
        [self updateFilterView];
    }];
}

- (IBAction)applyLocalExp:(UIGestureRecognizer *)sender {
    self.expSearchType = @"LOCAL";
    [self applyFilterWithHandler:^{
        [self updateFilterView];
    }];
}

- (IBAction)applyItinerary:(UIGestureRecognizer *)sender {
    self.expSearchType = @"ITI";
    [self applyFilterWithHandler:^{
        [self updateFilterView];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)saveToWishListClicked:(NSInteger)buttonTag {
    [self toggleWishList: buttonTag];
}

- (IBAction)toggleWishList:(NSInteger)buttonTag {
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    NSIndexPath * index = [NSIndexPath indexPathForRow:buttonTag inSection:0];
    
    if (token) {
        NSString *expIdString;
        if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
            expIdString = [[[self.normalExpList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
        } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
            expIdString = [[[self.localExpList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
        }
        
//        NSString *expIdString = [[[self.expList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SearchCell";
    static NSString *cellIdentifier2 = @"SearchCell2";
    static NSString *multiDayCellID = @"MultiDayCell";
    static NSString *multiDayCell2ID = @"MultiDayCell2";
    
    TLSearchTableViewCell *cell;
    MultidayTableViewCell *multiDayCell;
    MultidayTableViewCell2 *multiDayCell2;
    
    NSDictionary *expData;
    
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        expData = [self.normalExpList objectAtIndex:indexPath.row];
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if(!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell2" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        }
        expData = [self.localExpList objectAtIndex:indexPath.row];
    } else if (indexPath.row == 0) {
        [tableView registerNib:[UINib nibWithNibName:@"MultidayTableViewCell" bundle:nil] forCellReuseIdentifier:multiDayCellID];
        multiDayCell = [tableView dequeueReusableCellWithIdentifier:multiDayCellID];
        
        multiDayCell.check1NightMelbourneButton.tag = 1;
        multiDayCell.checkAllNightMelbourneButton.tag = 2;
        multiDayCell.check1NightSydneyButton.tag = 3;
        multiDayCell.checkAllNightSydneyButton.tag = 4;
        multiDayCell.oneNightMelbournePriceLabel.text = [[self getExpById:@"651" inArray:self.itineraryExpList][@"price"] stringValue];
        multiDayCell.allNightMelbournePriceLabel.text = [[self getExpById:@"701" inArray:self.itineraryExpList][@"price"] stringValue];
        multiDayCell.oneNightSydneyPriceLabel.text = [[self getExpById:@"661" inArray:self.itineraryExpList][@"price"] stringValue];
        multiDayCell.allNightSydneyPriceLabel.text = [[self getExpById:@"711" inArray:self.itineraryExpList][@"price"] stringValue];
        
        
        [multiDayCell.check1NightMelbourneButton addTarget:self
                                                    action:@selector(checkMultidayDetail:) forControlEvents:UIControlEventTouchDown];
        [multiDayCell.checkAllNightMelbourneButton addTarget:self
                                                    action:@selector(checkMultidayDetail:) forControlEvents:UIControlEventTouchDown];
        [multiDayCell.check1NightSydneyButton addTarget:self
                                                 action:@selector(checkMultidayDetail:) forControlEvents:UIControlEventTouchDown];
        [multiDayCell.checkAllNightSydneyButton addTarget:self
                                                 action:@selector(checkMultidayDetail:) forControlEvents:UIControlEventTouchDown];
        
        NSString *backgroundImageURL = [NSString stringWithFormat:@"%@img/homepage/travelling-01.jpg", [URLConfig staticServiceURLString]];
        multiDayCell.multidayImage.clipsToBounds = YES;
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = multiDayCell.multidayImage.center;
        activityIndicator.hidesWhenStopped = YES;
        [multiDayCell.multidayImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        [multiDayCell.multidayImage sd_setImageWithURL:[NSURL URLWithString:backgroundImageURL]
                                placeholderImage:nil
                                         options:0
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           multiDayCell.multidayImage.image = [Utility filledImageFrom:image withColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
                                           [activityIndicator removeFromSuperview];
                                       }];
        return multiDayCell;
    } else {
        [tableView registerNib:[UINib nibWithNibName:@"MultidayTableViewCell2" bundle:nil] forCellReuseIdentifier:multiDayCell2ID];
        multiDayCell2 = [tableView dequeueReusableCellWithIdentifier:multiDayCell2ID];
        NSString *backgroundImageURL = @"";
        
        if (indexPath.row == 1) {
            multiDayCell2.onNightCheckButton.tag = 5;
            multiDayCell2.allNightCheckButton.tag = 6;
            multiDayCell2.nDayTripLabel.text = NSLocalizedString(@"7_day_trip", nil);
            multiDayCell2.localtionLabel.text = NSLocalizedString(@"mel_syd", nil);
            
            multiDayCell2.oneNightPriceLabel.text = [[self getExpById:@"681" inArray:self.itineraryExpList][@"price"] stringValue];
            multiDayCell2.allNightPriceLabel.text = [[self getExpById:@"731" inArray:self.itineraryExpList][@"price"] stringValue];

            backgroundImageURL = [NSString stringWithFormat:@"%@city/Sydney.jpg", [URLConfig imageServiceURLString]];
        } else {
            multiDayCell2.onNightCheckButton.tag = 7;
            multiDayCell2.allNightCheckButton.tag = 8;
            multiDayCell2.nDayTripLabel.text = NSLocalizedString(@"10_day_trip", nil);
            multiDayCell2.localtionLabel.text = NSLocalizedString(@"mel_syd_gold", nil);
            
            multiDayCell2.oneNightPriceLabel.text = [[self getExpById:@"691" inArray:self.itineraryExpList][@"price"] stringValue];
            multiDayCell2.allNightPriceLabel.text = [[self getExpById:@"771" inArray:self.itineraryExpList][@"price"] stringValue];
            
            backgroundImageURL = [NSString stringWithFormat:@"%@city/Brisbane.jpg", [URLConfig imageServiceURLString]];
        }

        [multiDayCell2.onNightCheckButton addTarget:self
                                             action:@selector(checkMultidayDetail:) forControlEvents:UIControlEventTouchDown];
        [multiDayCell2.allNightCheckButton addTarget:self
                                              action:@selector(checkMultidayDetail:) forControlEvents:UIControlEventTouchDown];
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        multiDayCell2.backgroundImageView.clipsToBounds = YES;
        activityIndicator.center = multiDayCell2.backgroundImageView.center;
        activityIndicator.hidesWhenStopped = YES;
        [multiDayCell2.backgroundImageView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        [multiDayCell2.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:backgroundImageURL]
                                      placeholderImage:nil
                                               options:0
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                 multiDayCell2.backgroundImageView.image = [Utility filledImageFrom:image withColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
                                                 [activityIndicator removeFromSuperview];
                                             }];

        return multiDayCell2;
    }
    
    
    NSString *expIdString = [expData[@"id"] stringValue];
    
    NSString *duration = [expData[@"duration"] stringValue];
    NSString *handledDurationString = [duration stringByAppendingString:NSLocalizedString(@"Hours", nil)];
    cell.durationLabel.text = handledDurationString;
    cell.titleLabel.text = expData[@"title"];

    cell.languageLabel.text = [Utility transformLanugage:(NSString *)expData[@"language"]];
    cell.descriptionLabel.text = expData[@"description"];

    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        NSString *hostImageRelativeURL = expData[@"host_image"];
        if (hostImageRelativeURL != (id)[NSNull null] && hostImageRelativeURL.length > 0) {
            NSString *hostImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: hostImageRelativeURL];
            
            [cell.hostImage sd_setImageWithURL:[NSURL URLWithString:hostImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];
        } else {
            cell.hostImage.image = [UIImage imageNamed:@"default_profile_image.png"];
        }
    }

    
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
    NSString *priceString = [Utility decimalwithFormat:@"0" floatV:[expData[@"price"] floatValue]];
    cell.priceLabel.text = priceString;
    [dynamicPricingArray addObject:priceString];
    

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expSearchType isEqualToString:@"ITI"]) {
        if (indexPath.row == 0) {
            return 500.f;
        } else {
            return 340.f;
        }

    } else {
        return 340.f;
    }
}

-(void)checkMultidayDetail:(UIButton*)sender {
    switch (sender.tag) {
        case 1:
            self.exp = [self getExpById:@"651" inArray:self.itineraryExpList];
            break;
        case 2:
            self.exp = [self getExpById:@"701" inArray:self.itineraryExpList];
            break;
        case 3:
            self.exp = [self getExpById:@"661" inArray:self.itineraryExpList];
            break;
        case 4:
            self.exp = [self getExpById:@"711" inArray:self.itineraryExpList];
            break;
        case 5:
            self.exp = [self getExpById:@"681" inArray:self.itineraryExpList];
            break;
        case 6:
            self.exp = [self getExpById:@"731" inArray:self.itineraryExpList];
            break;
        case 7:
            self.exp = [self getExpById:@"691" inArray:self.itineraryExpList];
            break;
        case 8:
            self.exp = [self getExpById:@"771" inArray:self.itineraryExpList];
            break;
        default:
            break;
    }
    
    [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        return [self.normalExpList count];
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        return [self.localExpList count];
    } else {
        return 3;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.expList count] == 0) {
        [self fetchExpData:self.cityName completionHandler:^(NSMutableArray *expList) {
            self.expList = expList;
            [self.tableView reloadData];
        }];
    }
}

- (void) fetchExpData:(NSString *) cityName completionHandler:(void (^)(NSMutableArray *expList)) handler {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    NSString *post = nil;
    NSDate *today = [NSDate date];

    NSString *startDate = [dateFormatter stringFromDate:today];
    NSString *endDate = [dateFormatter stringFromDate:today];

    NSString *typeString = @"";
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        typeString = @"\"type\":\"experience\"";
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        typeString = @"\"type\":\"newproduct\"";
    } else {
        typeString = @"\"type\":\"itinerary\"";
    }
    
#ifdef CN_VERSION
        post = [NSString stringWithFormat:@"{%@, \"start_datetime\":\"%@\", \"end_datetime\":\"%@\", \"city\":\"%@\", \"guest_number\":\"2\", \"keywords\":\"\"}", typeString, startDate, endDate ,[cityName stringByReplacingOccurrencesOfString:@" " withString:@"" ]];
        [request setURL:[NSURL URLWithString:[URLConfig searchServiceURLString]]];
#else
        post = [NSString stringWithFormat:@"{%@, \"start_datetime\":\"%@\", \"end_datetime\":\"%@\", \"city\":\"%@\", \"guest_number\":\"2\", \"keywords\":\"\"}", typeString, startDate, endDate ,[cityName stringByReplacingOccurrencesOfString:@" " withString:@"" ]];
        [request setURL:[NSURL URLWithString:[URLConfig searchServiceURLString]]];
#endif
    
#ifdef DEBUG
    NSLog(@"Sending data = %@",post);
#endif
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
//    NSError *connectionError = nil;
//    NSURLResponse *response = nil;
    
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (connectionError == nil) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                NSMutableArray *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if ([httpResponse statusCode] == 200) {
                    NSDictionary *indexOfExperience = [allDataDictionary objectAtIndex:0];
                    NSMutableArray *expListCopy = [indexOfExperience objectForKey:@"experiences"];
                    for (NSDictionary *exp in expListCopy){
                        [expList addObject:exp];
                    }
                    
                    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
                        self.normalExpList = expList;
                    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
                        self.localExpList = expList;
                    } else {
                        self.itineraryExpList = expList;
                    }
                    
                    self.expList = expList;
                    
#ifdef DEBUG
                    NSLog(@"number of cells: %lu", (unsigned long)expList.count);
#endif
                    
                }
                else {
#ifdef DEBUG
                    NSLog(@"Sending data = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
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
            handler(expList);
        });
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        self.exp = self.normalExpList[indexPath.row];
        [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        self.exp = self.localExpList[indexPath.row];
        [self performSegueWithIdentifier:@"LocalSearchResultSegue" sender:self];
    } else {
        NSLog(@"Not implemented");
    }
}

-(NSDictionary *)getExpById:(NSString *)id inArray:(NSArray *)expList {
    for (NSDictionary *exp in expList) {
        if ([[exp[@"id"] stringValue] isEqualToString:id]) {
            return exp;
        }
    }
    return nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchResultSegue"]) {
        TLDetailViewController *vc = (TLDetailViewController *)segue.destinationViewController;
        vc.expType = self.exp[@"type"];
        vc.experience_id_string = [self.exp[@"id"] stringValue];
        vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[self.exp[@"price"] floatValue]];
        
    } else if ([segue.identifier isEqualToString:@"LocalSearchResultSegue"]) {
        LocalDetailViewController *vc = (LocalDetailViewController *) segue.destinationViewController;
        vc.expType = self.exp[@"type"];
        vc.experience_id_string = [self.exp[@"id"] stringValue];
        vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[self.exp[@"price"] floatValue]];

    }
}

@end
