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
#import "DetailDescTableViewController.h"
#import "TitleDescCell.h"
#import "RelatedExpTableViewCell.h"
#import "SectionDescViewController.h"

@interface LocalDetailViewController () {
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
    JGProgressHUD *HUD;
    NSArray *dynamicPriceArray;
    NSNumber *maxGuestNum;
    NSNumber *minGuestNum;
    NSString *foodString;
    NSString *ticketString;
    NSString *transportString;
    NSArray *reviews;
    NSDictionary *expData;
    NSString *popularityText;
    UIImage *nextPageCoverImage;
    BOOL hideTip;
}

@property (strong, nonatomic) NSString *sectionDescription;
@property (strong, nonatomic) NSString *sectionTitle;
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
    hideTip = NO;
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
    
    self.cellHeights = [@[@400, @240, @385, @164, @55, @55, @55, @55, @55, @55, @55, @55, @90, @90] mutableCopy];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    
    reviews = [[NSArray alloc] init];
    expData = [[NSDictionary alloc] init];
    
    [self mpTrackViewExperience];
    
    if ([expData count] == 0) {
        [self fetchData];
    }
    
    float popularity = [expData[@"experience_popularity"] floatValue];
    if (popularity >= 80) {
        popularityText = NSLocalizedString(@"hurry_up_80", nil);
    } else if (popularity >= 50) {
        popularityText = NSLocalizedString(@"hurry_up_50", nil);
    } else {
        self.cellHeights[0] = @(320);
        hideTip = YES;
    }
    
    self.navigationItem.title = title;

    [HUD dismissAfterDelay:1];
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
                title = expData[@"title"];
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
    TLDetailTableViewCell3 *cell2=(TLDetailTableViewCell3 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    
    static NSString *cellIdentifier3=@"cell3";
    TLDetailTableViewCell4 *cell3=(TLDetailTableViewCell4 *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];

    static NSString *cellIdentifier4=@"cell4";
    TitleDescCell *sectionTitleCell=(TitleDescCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
    
    static NSString *cellIdentifier5=@"cell5";
    UITableViewCell *cell5=(TitleDescCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier5];
    
    static NSString *cellIdentifier6=@"cell6";
    RelatedExpTableViewCell *cell6=(TitleDescCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier6];
    
    NSString *schedule = expData[@"schedule"];
    NSString *tips = [expData[@"tips"] stringByAppendingString:expData[@"notice"]];
    NSString *whatsincluded = expData[@"whatsincluded"];
    NSString *pickupDetail = expData[@"pickup_detail"];
    NSString *disclaimer = expData[@"disclaimer"];
    NSString *refundPolicy = expData[@"refund_policy"];
    NSString *insurance = expData[@"insurance"];
    
    switch (indexPath.row) {
        case 0: {
            if (!cell) {
                cell = [[TLDetailTableViewCell0 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier0];
            }
            
            if (hideTip == YES) {
                cell.tipView.hidden = YES;
            } else {
                cell.tipView.hidden = NO;
                cell.descLabel.text = popularityText;
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
            cell.currencyLabel.text = [expData[@"experience_dollarsign"] stringByAppendingString:expData[@"experience_currency"]];
            cell.priceLabel.text = _expPrice;
            cell.cityLabel.text = expData[@"experience_city"];
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
            cell1.expDescriptionLabel.text = expData[@"description"];
            return cell1;
        case 2:
        {
            if(!cell2)
            {
                cell2=[[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            }
            
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([nReviews intValue] > 0) {
                cell2.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"n_reviews", nil), nReviews];
                cell2.reviewStars.rating = [rate floatValue];
                cell2.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewerFirstName, reviewerLastName];
                cell2.commentLabel.text = reviewComment;
                
                [cell2.reviewerImage sd_setImageWithURL:[NSURL URLWithString:reviewerImageURL]
                                       placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                                options:SDWebImageRefreshCached];
            }else{
                cell2.hidden = YES;
            }
            return cell2;
        }
        case 3:
        {
            if(!cell3) {
                cell3=[[TLDetailTableViewCell4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            NSString *coverImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], _experience_id_string];
            __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = cell3.coverImage.center;
            activityIndicator.hidesWhenStopped = YES;
            
            [cell3.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]
                                placeholderImage:nil
                                         options:SDWebImageRefreshCached
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [activityIndicator removeFromSuperview];
                                       }];
            
            [cell3.coverImage addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            return cell3;
        }
        case 4: {
            if ([schedule length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[4] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"schedule_title", nil);
                sectionTitleCell.sectionButton.tag = 4;
            }

            return sectionTitleCell;
        }
        case 5: {
            if ([tips length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[5] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"tips_title", nil);
                sectionTitleCell.sectionButton.tag = 5;
            }
            
            return sectionTitleCell;
        }
        case 6: {
            if ([whatsincluded length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[6] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"whatsincluded_title", nil);
                sectionTitleCell.sectionButton.tag = 6;
            }
            
            return sectionTitleCell;
        }
        case 7: {
            if ([pickupDetail length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[7] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"pickup_title", nil);
                sectionTitleCell.sectionButton.tag = 7;
            }
            
            return sectionTitleCell;
        }
        case 8: {
            if ([disclaimer length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[8] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"disclaimer_title", nil);
                sectionTitleCell.sectionButton.tag = 8;
            }
            
            return sectionTitleCell;
        }
        case 9: {
            if ([refundPolicy length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[9] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"refund_title", nil);
                sectionTitleCell.sectionButton.tag = 9;
            }
            
            return sectionTitleCell;
        }
        case 10: {
            if ([insurance length] == 0) {
                sectionTitleCell.hidden = YES;
                self.cellHeights[10] = @(0);
            } else {
                sectionTitleCell.hidden = NO;
                sectionTitleCell.sectionTitleLabel.text = NSLocalizedString(@"insurance_title", nil);
                sectionTitleCell.sectionButton.tag = 10;
            }

            return sectionTitleCell;
        }
        case 11: {
            return cell5;
        }
        case 12: {
            if ([expData[@"related_experiences"] count] >= 1) {
                cell6.hidden = NO;
                NSDictionary *exp1 = expData[@"related_experiences"][0];
                cell6.expTitle.text = exp1[@"title"];
                cell6.dollarsign.text = exp1[@"dollarsign"];
                cell6.durationLabel.text = [[exp1[@"duration"] stringValue] stringByAppendingString:NSLocalizedString(@"Hours", nil)];
                cell6.priceLabel.text = [Utility decimalwithFormat:@"0" floatV:[exp1[@"price"] floatValue]];
                cell6.languageLabel.text = [Utility transformLanugage:exp1[@"language"]];
                
                
                NSString *expImageURL = [NSString stringWithFormat:@"%@%@", [URLConfig imageServiceURLString], exp1[@"image"]];
                
                [cell6.expImageView sd_setImageWithURL:[NSURL URLWithString:expImageURL]
                                    placeholderImage:nil
                                             options:SDWebImageRefreshCached
                                           completed:nil];

            } else {
                cell6.hidden = YES;
                self.cellHeights[12] = @(0);
            }
            
            return cell6;
        }
        case 13: {
            if ([expData[@"related_experiences"] count] >= 2) {
                cell6.hidden = NO;
                NSDictionary *exp1 = expData[@"related_experiences"][1];
                cell6.expTitle.text = exp1[@"title"];
                cell6.dollarsign.text = exp1[@"dollarsign"];
                cell6.durationLabel.text = [[exp1[@"duration"] stringValue] stringByAppendingString:@"hrs"];
                cell6.priceLabel.text = [Utility decimalwithFormat:@"0" floatV:[exp1[@"price"] floatValue]];
                cell6.languageLabel.text = [Utility transformLanugage:exp1[@"language"]];
                
                NSString *expImageURL = [NSString stringWithFormat:@"%@%@", [URLConfig imageServiceURLString], exp1[@"image"]];
                
                [cell6.expImageView sd_setImageWithURL:[NSURL URLWithString:expImageURL]
                                      placeholderImage:nil
                                               options:SDWebImageRefreshCached
                                             completed:nil];
            } else {
                cell6.hidden = YES;
                self.cellHeights[13] = @(0);
            }
            
            return cell6;
        }
        
        default:
            return cell;
    }
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cellHeights count];
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


- (IBAction)viewSectionDescription:(UIButton *)sender {
    switch (sender.tag) {
        case 4:
            self.sectionTitle = NSLocalizedString(@"schedule_title", nil);;
            self.sectionDescription = expData[@"schedule"];
            break;
        case 5:
            self.sectionTitle = NSLocalizedString(@"tips_title", nil);
            self.sectionDescription = expData[@"tips"];
            break;
        case 6:
            self.sectionTitle = NSLocalizedString(@"whatsincluded_title", nil);
            self.sectionDescription = expData[@"whatsincluded"];
            break;
        case 7:
            self.sectionTitle = NSLocalizedString(@"pickup_title", nil);
            self.sectionDescription = expData[@"pickup_detail"];
            break;
        case 8:
            self.sectionTitle = NSLocalizedString(@"disclaimer_title", nil);
            self.sectionDescription = expData[@"disclaimer"];
            break;
        case 9:
            self.sectionTitle = NSLocalizedString(@"refund_title", nil);
            self.sectionDescription = expData[@"refund_policy"];
            break;
        case 10:
            self.sectionTitle = NSLocalizedString(@"insurance_title", nil);
            self.sectionDescription = expData[@"insurance"];
            break;
        default:
            break;
    }
    
    [self performSegueWithIdentifier:@"view_section_desc" sender:self];
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
        vc.expType = self.expType;

    } else if ([segue.identifier isEqualToString:@"view_all_reviews"]) {
        ReviewTableViewController *vc = [segue destinationViewController];
        vc.reviews = reviews;
    } else if ([segue.identifier isEqualToString:@"view_detail_description"]) {
        DetailDescTableViewController *vc = [segue destinationViewController];
        vc.description_detail = expData[@"description"];
        vc.service = expData[@"service"];
        vc.highlights = expData[@"highlights"];
    } else if ([segue.identifier isEqualToString:@"view_section_desc"]) {
        SectionDescViewController *vc = [segue destinationViewController];
        vc.sectionDescription = self.sectionDescription;
        vc.sectionTitle = self.sectionTitle;
    }
    
}


@end
