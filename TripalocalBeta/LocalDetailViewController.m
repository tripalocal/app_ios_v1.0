//
//  LocalDetailViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 15/10/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "LocalDetailViewController.h"
#import "TLDetailTableViewCell0.h"
#import "TLDetailTableViewCell1.h"
#import "TLDetailTableViewCell2.h"
#import "TLDetailTableViewCell3.h"
#import "TLDetailTableViewCell4.h"
#import "TLDetailTableViewCell5.h"
#import "JGProgressHUD.h"
#import "Constant.h"
#import "CheckoutViewController.h"
#import "ReviewTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "URLConfig.h"
#import "Utility.h"
#import "Mixpanel.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>

@interface LocalDetailViewController ()
{
    NSString *language;
    NSString *duration;
    NSString *title;
    NSString *description;
    NSString *nReviews;
    NSString *rate;
    NSString *reviewerFirstName;
    NSString *reviewerLastName;
    NSString *PREreviewerImageURL;
    NSString *reviewerImageURL;
    NSString *reviewComment;
    NSString *highlights;
    NSString *tips;
    NSString *dollarsign;
    NSString *currency;
    NSString *city;
    JGProgressHUD *HUD;
    NSArray *dynamicPriceArray;
    NSNumber *maxGuestNum;
    NSNumber *minGuestNum;
    NSString *foodString;
    NSString *ticketString;
    NSString *transportString;
    NSArray *reviews;
    NSDictionary *expData;
    UIImage *nextPageCoverImage;
}

@end

@implementation LocalDetailViewController

- (IBAction)checkout:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    
    if (!token) {
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"checkoutSegue" sender:nil];
    }
}

- (void)mpTrackViewExperience {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *localLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    
    if (token) {
        NSString * userEmail = [userDefaults stringForKey:@"user_email"];
        [mixpanel identify:userEmail];
        [mixpanel.people set:@{}];
    }
    
    [mixpanel track:mpTrackViewExperience properties:@{@"language":localLanguage}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    [HUD showInView:self.view];
    reviewerFirstName = @"";
    reviewerLastName = @"";
    reviewComment = @"";
    reviewerImageURL = @"";
    
    self.cellHeights = [@[@320, @240, @385, @164, @320] mutableCopy];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    
    reviews = [[NSArray alloc] init];
    expData = [[NSDictionary alloc] init];
    [_myTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self mpTrackViewExperience];
    
}

- (void)fetchData
{
    NSString *queryString = [NSString stringWithFormat:@"%@?experience_id=%@",[URLConfig expDetailServiceURLString],_experience_id_string];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:queryString]];
    [request setHTTPMethod:@"GET"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];
#ifdef DEBUG
        NSString *decodedData = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
        NSLog(@"(Detail)Receiving: %@", decodedData);
#endif
        if ([httpResponse statusCode] == 200) {
            expData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            @try {
                language = [self transformLanugage:expData[@"experience_language"]];
                duration = [expData[@"experience_duration"] stringValue];
                title = expData[@"experience_title"];
                currency = expData[@"experience_currency"];
                dollarsign = expData[@"experience_dollarsign"];
                city = expData[@"experience_city"];
                highlights = expData[@"highlights"];
                tips = expData[@"tips"];
                description = expData[@"description"];

                reviews = expData[@"experience_reviews"];
                nReviews = [@([reviews count]) stringValue];
                rate = [expData[@"experience_rate"] stringValue];
                ticketString = expData[@"included_ticket_detail"];
                foodString = expData[@"included_food_detail"];
                transportString = expData[@"included_transport_detail"];
                dynamicPriceArray = expData[@"experience_dynamic_price"];
                maxGuestNum = expData[@"experience_guest_number_max"];
                minGuestNum = expData[@"experience_guest_number_min"];
                
                [self setMinimalPrice];
                
                if ([nReviews intValue] > 0) {
                    NSDictionary *firstReview = reviews[0];
                    reviewerFirstName = firstReview[@"reviewer_firstname"];
                    reviewerLastName = firstReview[@"reviewer_lastname"];
                    PREreviewerImageURL = firstReview[@"reviewer_image"];
                    reviewerImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: PREreviewerImageURL];
                    reviewComment = firstReview[@"review_comment"];
                }
            }
            @catch (NSException * e) {
                NSLog(@"Experience/(ID:%@/) Exception: %@", _experience_id_string, e);
            }
        } else {
            NSString *errorMsg = result[@"Server Error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error", nil)
                                                            message:errorMsg
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
    
    
#ifdef DEBUG
    NSLog(@"%@,%@,%@,%@", title,_expPrice,reviewerImageURL,reviewComment);
#endif
    [_myTable reloadData];
}

- (void)setMinimalPrice {
    NSNumber *priceNumber = nil;
    if ([dynamicPriceArray count] == 0) {
        priceNumber = expData[@"experience_price"];
    } else if ([minGuestNum intValue] <= 4 && [maxGuestNum intValue] >= 4) {
        priceNumber = dynamicPriceArray[4 - [minGuestNum intValue]];
    } else if ([minGuestNum intValue] > 4) {
        priceNumber = dynamicPriceArray[0];
    } else if ([maxGuestNum intValue] < 4) {
        priceNumber = [dynamicPriceArray lastObject];
    }
    self.expPrice = [Utility decimalwithFormat:@"0" floatV:[priceNumber floatValue]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([expData count] == 0) {
        [self fetchData];
    }
    
    [HUD dismissAfterDelay:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier0=@"cell0";
    TLDetailTableViewCell0 *cell=(TLDetailTableViewCell0 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier0];
    static NSString *cellIdentifier1=@"cell1";
    TLDetailTableViewCell1 *cell1=(TLDetailTableViewCell1 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    
    static NSString *cellIdentifier2=@"cell2";
    TLDetailTableViewCell2 *cell2=(TLDetailTableViewCell2 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    
    static NSString *cellIdentifier3=@"cell3";
    TLDetailTableViewCell3 *cell3=(TLDetailTableViewCell3 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
    
    static NSString *cellIdentifier4=@"cell4";
    TLDetailTableViewCell4 *cell4=(TLDetailTableViewCell4 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
    
    static NSString *cellIdentifier5=@"cell5";
    TLDetailTableViewCell5 *cell5=(TLDetailTableViewCell5 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier5];
    
    switch (indexPath.row) {
        case 0: {
            if (!cell) {
                cell = [[TLDetailTableViewCell0 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier0];
            }
            
            NSString *coverImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], _experience_id_string];
            
            __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = cell.coverImage.center;
            activityIndicator.hidesWhenStopped = YES;
            
            [cell.coverImage addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            [cell.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]
                               placeholderImage:nil
                                        options:SDWebImageRefreshCached
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          [activityIndicator removeFromSuperview];
                                          if (image) {
                                              nextPageCoverImage = image;
                                          }
                                      }];
            
            cell.languageLabel.text = language;
            cell.currencyLabel.text = [dollarsign stringByAppendingString:currency];
            cell.priceLabel.text = _expPrice;
            cell.cityLabel.text = city;
            cell.durationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"local_exp_detail_per_person_for", nil), duration];
            
            return cell;
        }
        case 1:
            if(!cell1)
            {
                cell1=[[TLDetailTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            }
            
            cell1.parentView = self.myTable;
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.expDescriptionLabel.text = description;
            return cell1;
        case 2:
        {
            if(!cell3)
            {
                cell3=[[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            cell3.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([nReviews intValue] > 0) {
                cell3.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"n_reviews", nil), nReviews];
                cell3.reviewStars.rating = [rate floatValue];
                cell3.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewerFirstName, reviewerLastName];
                cell3.commentLabel.text = reviewComment;
                
                [cell3.reviewerImage sd_setImageWithURL:[NSURL URLWithString:reviewerImageURL]
                                       placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                                options:SDWebImageRefreshCached];
            }else{
                cell3.hidden = YES;
            }
            return cell3;
        }
        case 3:
        {
            if(!cell4) {
                cell4=[[TLDetailTableViewCell4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
            }
            
            NSString *coverImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], _experience_id_string];
            __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = cell4.coverImage.center;
            activityIndicator.hidesWhenStopped = YES;
            
            [cell4.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]
                                placeholderImage:nil
                                         options:SDWebImageRefreshCached
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [activityIndicator removeFromSuperview];
                                       }];
            
            [cell4.coverImage addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            return cell4;
        }
        case 4: {
            if(!cell5)
            {
                cell5=[[TLDetailTableViewCell5 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier5];
            }
            
            cell5.foodLabel.text = [cell5.foodLabel.text stringByAppendingFormat:@": %@", foodString];
            cell5.ticketLabel.text = [cell5.ticketLabel.text stringByAppendingFormat:@": %@", ticketString];
            cell5.transportLabel.text = [cell5.transportLabel.text stringByAppendingFormat:@": %@", transportString];
            
            return cell5;
        }
        default:
            return cell;
    }
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *) transformLanugage:(NSString *) languageString {
    NSMutableArray *languages = [[languageString componentsSeparatedByString:@";"] mutableCopy];
    [languages removeLastObject];
    if ([languages count] == 0) {
        return @"English";
    }
    
    for (NSUInteger i = 0; i < [languages count]; ++i) {
        NSString * oneLanguage = languages[i];
        if ([oneLanguage isEqualToString:@"mandarin"]) {
            languages[i] = @"中文";
        } else {
            languages[i] = [oneLanguage capitalizedString];
        }
    }
    
    return [languages componentsJoinedByString:@" / "];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row){
        case 2:
            if ([nReviews intValue] <= 0) {
                return 0.0;
            }
        default:
            return [self.cellHeights[indexPath.row] floatValue];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"checkoutSegue"]) {
        CheckoutViewController *vc=[segue destinationViewController];
        vc.exp_ID_string = _experience_id_string;
        vc.expImage = nextPageCoverImage;
        
        vc.expTitleString = title;
        vc.fixPriceString = _expPrice;
        vc.dynamicPriceArray = dynamicPriceArray;
        vc.languageString = language;
        vc.durationString = duration;
        vc.maxGuestNum = maxGuestNum;
        vc.minGuestNum = minGuestNum;

    } else if ([segue.identifier isEqualToString:@"view_all_reviews"]) {
        ReviewTableViewController *vc = [segue destinationViewController];
        vc.reviews = reviews;
    } else if ([segue.identifier isEqualToString:@"view_detail_description"]) {
  
    }
    
}


@end
