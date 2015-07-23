//
//  TLDetailViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 25/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLDetailViewController.h"
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

@interface TLDetailViewController ()
{
    NSString *hostImageURL;
    NSString *language;
    NSString *duration;
    NSString *title;
    NSString *description;
    NSString *activity;
    NSString *interaction;
    NSString *hostFirstName;
    NSString *hostLastName;
    NSString *hostBio;
    NSString *nReviews;
    NSString *rate;
    NSString *reviewerFirstName;
    NSString *reviewerLastName;
    NSString *PREreviewerImageURL;
    NSString *reviewerImageURL;
    NSString *reviewComment;
    JGProgressHUD *HUD;
    NSArray *dynamicPriceArray;
    NSNumber *maxGuestNum;
    NSNumber *minGuestNum;
    NSString *foodString;
    NSString *ticketString;
    NSString *transportString;
    NSArray *availableDateArray;
    NSArray *reviews;
    NSDictionary *expData;
    UIImage *nextPageCoverImage;
}

@end

@implementation TLDetailViewController

- (IBAction)checkout:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
    if (!token) {
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"checkoutSegue" sender:nil];
    }
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

    self.cellHeights = [@[@306, @240, @320, @385, @164, @240] mutableCopy];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    
    reviews = [[NSArray alloc] init];
    expData = [[NSDictionary alloc] init];
}

- (void)fetchData
{
    NSString *post = [NSString stringWithFormat:@"{\"experience_id\":\"%@\"}",_experience_id_string];
#if DEBUG
    NSLog(@"(Detail)POST: %@", post);
#endif
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[URLConfig expDetailhServiceURLString]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
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
                NSString *hostImageURLRelative = expData[@"host_image"];
                // improve: why this stupid json lib returns "<null>" for ""
                if (hostImageURLRelative != (id)[NSNull null]) {
                    hostImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: hostImageURLRelative];
                } else {
                    hostImageURL = nil;
                }

                language = [self transformLanugage:expData[@"experience_language"]];
                duration = [expData[@"experience_duration"] stringValue];
                title = expData[@"experience_title"];
                description = expData[@"experience_description"];
                activity = expData[@"experience_activity"];
                interaction = expData[@"experience_interaction"];
                hostFirstName = expData[@"host_firstname"];
                if (hostFirstName == (id)[NSNull null]) {
                    hostFirstName = @"";
                }
                hostLastName = expData[@"host_lastname"];
                hostBio = expData[@"host_bio"];
                reviews = expData[@"experience_reviews"];
                nReviews = [@([reviews count]) stringValue];
                rate = [expData[@"experience_rate"] stringValue];
                ticketString = expData[@"included_ticket_detail"];
                foodString = expData[@"included_food_detail"];
                transportString = expData[@"included_transport_detail"];
                availableDateArray = expData[@"available_options"];
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
            
            [cell.hostImage sd_setImageWithURL:[NSURL URLWithString:hostImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];
            
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
            
            
            cell.reservationLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"reservationPrefix", nil), hostFirstName, NSLocalizedString(@"reservationSuffix",nil)];
            
            // language
            cell.languageLabel.text = language;
            cell.priceLabel.text = [NSString stringWithFormat:@"$%@",_expPrice];
            cell.durationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"exp_detail_per_person_for", nil), duration];
            
            return cell;
        }
        case 1:
            if(!cell1)
            {
                cell1=[[TLDetailTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            }
            
            cell1.parentView = self.myTable;
            cell1.expTitleLabel.text = title;
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.expDescriptionLabel.text = [description stringByAppendingFormat:@" %@ %@", activity, interaction];
            if (self.isExpReadMoreOpen) {
                [cell1.readMoreButton setTitle:NSLocalizedString(@"read_less", nil) forState:UIControlStateNormal];
                cell1.expDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell1.expDescriptionLabel.numberOfLines = 0;
                [cell1.expDescriptionLabel sizeToFit];
            } else {
                [cell1.readMoreButton setTitle:NSLocalizedString(@"read_more", nil) forState:UIControlStateNormal];
                cell1.expDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                cell1.expDescriptionLabel.numberOfLines = 5;
            }

            return cell1;
        case 2:
            if(!cell2)
            {
                cell2=[[TLDetailTableViewCell2 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            }
            cell2.parentView = self.myTable;
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            if (self.isHostReadMoreOpen) {
                [cell2.readMoreButton setTitle:NSLocalizedString(@"read_less", nil) forState:UIControlStateNormal];
                cell2.hostBioLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell2.hostBioLabel.numberOfLines = 0;
                [cell2.hostBioLabel sizeToFit];
            } else {
                [cell2.readMoreButton setTitle:NSLocalizedString(@"read_more", nil) forState:UIControlStateNormal];
                cell2.hostBioLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                cell2.hostBioLabel.numberOfLines = 5;
            }
            
            [cell2.hostImage sd_setImageWithURL:[NSURL URLWithString:hostImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];
            if (hostFirstName) {
                cell2.hostFirstNameLabel.text = [NSLocalizedString(@"about_the_host", nil) stringByAppendingString: hostFirstName];
            }
            cell2.hostBioLabel.text = hostBio;
            
            return cell2;
        case 3:
            if(!cell3)
            {
                cell3=[[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            cell3.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([nReviews intValue] > 0) {
                cell3.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"n_reviews", nil), nReviews];
            } else {
                cell3.countLabel.text = NSLocalizedString(@"no_reviews", nil);
            }
            
            cell3.reviewStars.rating = [rate floatValue];
            cell3.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewerFirstName, reviewerLastName];
            cell3.commentLabel.text = reviewComment;
            
            [cell3.reviewerImage sd_setImageWithURL:[NSURL URLWithString:reviewerImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];
            
            return cell3;
        case 4:
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
        case 5:
            if(!cell5)
            {
                cell5=[[TLDetailTableViewCell5 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier5];
            }
            
            cell5.foodLabel.text = [cell5.foodLabel.text stringByAppendingFormat:@": %@", foodString];
            cell5.ticketLabel.text = [cell5.ticketLabel.text stringByAppendingFormat:@": %@", ticketString];
            cell5.transportLabel.text = [cell5.transportLabel.text stringByAppendingFormat:@": %@", transportString];

            return cell5;
        
        default:
            break;
    }
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *) transformLanugage:(NSString *) languageString {
    NSMutableArray *languages = [[languageString componentsSeparatedByString:@";"] mutableCopy];
    [languages removeLastObject];
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
    return [self.cellHeights[indexPath.row] floatValue];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"checkoutSegue"]) {
        CheckoutViewController *vc=[segue destinationViewController];
        vc.exp_ID_string = _experience_id_string;
        vc.expImage = nextPageCoverImage;

        vc.availbleDateArray = availableDateArray;
        vc.expTitleString = title;
        vc.fixPriceString = _expPrice;
        vc.dynamicPriceArray = dynamicPriceArray;
        vc.languageString = language;
        vc.durationString = duration;
        vc.maxGuestNum = maxGuestNum;
        vc.minGuestNum = minGuestNum;
        NSString *lastNameInitial = [[hostLastName substringWithRange:NSMakeRange(0, 1)] stringByAppendingString:@"."];
        vc.hostName = [@[hostFirstName, lastNameInitial] componentsJoinedByString:@" "];

    } else if ([segue.identifier isEqualToString:@"view_all_reviews"]) {
        ReviewTableViewController *vc = [segue destinationViewController];
        vc.reviews = reviews;
    }
    
}

@end
