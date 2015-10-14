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

@interface TLSearchViewController (){
    NSMutableArray *dynamicPricingArray;
}

@property (nonatomic, retain) NSMutableArray *normalExpList;
@property (nonatomic, retain) NSMutableArray *localExpList;
@property (nonatomic, retain) NSMutableArray *itineraryExpList;
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

- (void)applyFilter {
//    self.expList = [self fetchExpData:self.cityName];
    [self.tableView reloadData];
}

- (void)updateFilterView {
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        self.travelWithLocalsImageView.highlighted = YES;
        self.travelWithLocalsLabel.highlighted = YES;
        
        self.localExpImageView.highlighted = NO;
        self.localExpLabel.highlighted = NO;
        self.itinerariesImageView.highlighted = NO;
        self.itenarariesLabel.highlighted = NO;
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        self.localExpImageView.highlighted = YES;
        self.localExpLabel.highlighted = YES;
        
        self.travelWithLocalsImageView.highlighted = NO;
        self.travelWithLocalsLabel.highlighted = NO;
        self.itinerariesImageView.highlighted = NO;
        self.itenarariesLabel.highlighted = NO;
    } else {
        self.itinerariesImageView.highlighted = YES;
        self.itenarariesLabel.highlighted = YES;
        
        self.travelWithLocalsImageView.highlighted = NO;
        self.travelWithLocalsLabel.highlighted = NO;
        self.localExpImageView.highlighted = NO;
        self.localExpLabel.highlighted = NO;
    }
}

- (IBAction)applyTravelWithLocals:(UIGestureRecognizer *)sender {
    self.expSearchType = @"PRIVATE";
    [self applyFilter];
    [self updateFilterView];
}

- (IBAction)applyLocalExp:(UIGestureRecognizer *)sender {
    self.expSearchType = @"LOCAL";
    [self applyFilter];
    [self updateFilterView];
}

- (IBAction)applyItinerary:(UIGestureRecognizer *)sender {
    self.expSearchType = @"ITI";
    [self applyFilter];
    [self updateFilterView];
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

-(NSString *) transformLanugage:(NSString *) languageString {
    NSMutableArray *languages = [[languageString componentsSeparatedByString:@";"] mutableCopy];
    [languages removeLastObject];
    for (NSUInteger i = 0; i < [languages count]; ++i) {
        NSString * language = [languages objectAtIndex:i];
        if ([language isEqualToString:@"mandarin"]) {
            [languages replaceObjectAtIndex:i withObject:@"中文"];
        } else {
            [languages replaceObjectAtIndex:i withObject:[language capitalizedString]];
        }
    }
    
    return [languages componentsJoinedByString:@" / "];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *exp;
    static NSString *cellIdentifier = @"SearchCell";
    static NSString *cellIdentifier2 = @"SearchCell2";
    static NSString *multiDayCellID = @"MultiDayCell";
    
    TLSearchTableViewCell *cell;
    MultidayTableViewCell *multiDayCell;
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        exp = [self.normalExpList objectAtIndex:indexPath.row];
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if(!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell2" bundle:nil] forCellReuseIdentifier:cellIdentifier2];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        }
        exp = [self.localExpList objectAtIndex:indexPath.row];
    } else {
        multiDayCell = [tableView dequeueReusableCellWithIdentifier:multiDayCellID];
        [tableView registerNib:[UINib nibWithNibName:@"MultidayTableViewCell" bundle:nil] forCellReuseIdentifier:multiDayCellID];
        multiDayCell = [tableView dequeueReusableCellWithIdentifier:multiDayCellID];
        exp = [self.itineraryExpList objectAtIndex:indexPath.row];
        return multiDayCell;
    }
    
    
    NSString *expIdString = [[exp objectForKey:@"id"] stringValue];
    
    NSString *duration = [[exp objectForKey:@"duration"] stringValue];
    NSString *handledDurationString = [duration stringByAppendingString:NSLocalizedString(@"Hours", nil)];
    cell.durationLabel.text = handledDurationString;
    cell.titleLabel.text = [exp objectForKey:@"title"];

    cell.languageLabel.text = [self transformLanugage:(NSString *)[exp objectForKey:@"language"]];
    cell.descriptionLabel.text = [exp objectForKey:@"description"];

    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        NSString *hostImageRelativeURL = [exp objectForKey:@"host_image"];
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
    NSString *priceString = [Utility decimalwithFormat:@"0" floatV:[exp[@"price"] floatValue]];
    cell.priceLabel.text = priceString;
    //???
    [dynamicPricingArray addObject:priceString];
    

    return cell;
}

- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [self.expList count];
    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
        return [self.normalExpList count];
    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
        return [self.localExpList count];
    } else {
        return [self.itineraryExpList count];
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
        self.expList = [self fetchExpData:self.cityName];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)fetchExpData:(NSString *) cityName {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    NSString *post = nil;
    NSDate *today = [NSDate date];

    NSString *startDate = [dateFormatter stringFromDate:today];
    NSString *endDate = [dateFormatter stringFromDate:today];
    NSString *typeString = @"\"type\":\"all\"";
//    if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
//        typeString = @"\"type\":\"experience\"";
//    } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
//        typeString = @"\"type\":\"newproduct\"";
//    } else {
//        typeString = @"\"type\":\"itinerary\"";
//    }
    
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
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSMutableArray *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *indexOfExperience = [allDataDictionary objectAtIndex:0];
            NSMutableArray *expListCopy = [indexOfExperience objectForKey:@"experiences"];
            for (NSDictionary *exp in expListCopy){
                [expList addObject:exp];
                NSPredicate *p = [NSPredicate predicateWithFormat:
                                  @"SELF['type'] CONTAINS [cd] %@", @"PRIVATE"];
                NSPredicate *p2 = [NSPredicate predicateWithFormat:
                                  @"SELF['type'] CONTAINS [cd] %@", @"NEWPRODUCT"];
                NSPredicate *p3 = [NSPredicate predicateWithFormat:
                                   @"SELF['type'] CONTAINS [cd] %@", @"ITINERARY"];
                self.normalExpList = [NSMutableArray arrayWithArray:[expList filteredArrayUsingPredicate:p]];
                
                self.localExpList = [NSMutableArray arrayWithArray:[expList filteredArrayUsingPredicate:p2]];
                
                self.itineraryExpList = [NSMutableArray arrayWithArray:[expList filteredArrayUsingPredicate:p3]];

            }
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
    
    return expList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchResultSegue"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.hidesBottomBarWhenPushed = YES;
        TLDetailViewController *vc = (TLDetailViewController *) navController.topViewController;
        NSIndexPath *index=[_tableView indexPathForSelectedRow];
//        vc.experience_id_string = [[[self.expList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
        if ([self.expSearchType isEqualToString:@"PRIVATE"]) {
            vc.experience_id_string = [[self.normalExpList objectAtIndex:index.row][@"id"] stringValue];
            vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[[[self.normalExpList objectAtIndex:index.row] objectForKey:@"price"] floatValue]];
        } else if ([self.expSearchType isEqualToString:@"LOCAL"]) {
            vc.experience_id_string = [[self.localExpList objectAtIndex:index.row][@"id"] stringValue];
            vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[[[self.localExpList objectAtIndex:index.row] objectForKey:@"price"] floatValue]];
        } else {
            vc.experience_id_string = [[self.itineraryExpList objectAtIndex:index.row][@"id"] stringValue];
            vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[[[self.itineraryExpList objectAtIndex:index.row] objectForKey:@"price"] floatValue]];
        }
//        vc.expPrice = [dynamicPricingArray objectAtIndex:index.row];
//        vc.expPrice = [Utility decimalwithFormat:@"0" floatV:[[[self.expList objectAtIndex:index.row] objectForKey:@"price"] floatValue]];
    }
    
}

@end
