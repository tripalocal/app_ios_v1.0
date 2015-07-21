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

@interface TLDetailViewController ()
{
    NSString *hostImageURL;
    NSString *expLanguage;
    NSString *dynamicPriceString;
    NSString *expDuration;
    NSString *expTitle;
    NSString *expDescription;
    NSString *expActivity;
    NSString *expInteraction;
    NSMutableArray *expReviewsArray;
    NSString *hostFirstName;
    NSString *hostLastName;
    NSString *hostBio;
    NSString *numOfReviews;
    NSString *expRate;
    NSString *reviewFirst;
    NSString *reviewLast;
    NSString *PREreviewerImageURL;
    NSString *reviewerImageURL;
    NSString *reviewComment;
    JGProgressHUD *HUD;
    NSData *reviewerImageData;
    NSMutableArray *dynamicPriceArray;
    NSNumber *maxGuestNum;
    NSNumber *minGuestNum;
    NSString *foodString;
    NSString *ticketString;
    NSString *transportString;
    NSMutableArray *availableDateArray;
    NSArray *reviews;
    NSDictionary *expData;
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
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];

    self.isExpReadMoreOpen = NO;
    self.isHostReadMoreOpen = NO;

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
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];
#if DEBUG
        NSString *decodedData = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
        NSLog(@"Receiving data = %@", decodedData);
#endif
        
        if ([httpResponse statusCode] == 200) {
            expData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            @try {
                hostImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: [expData objectForKey:@"host_image"]];
                expLanguage = [self transformLanugage:[expData objectForKey:@"experience_language"]];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setMaximumFractionDigits:2];
                
                [formatter setRoundingMode: NSNumberFormatterRoundUp];
                NSNumber *expDurationNumber = [expData objectForKey:@"experience_duration"];
                expDuration = [expDurationNumber stringValue];
                expTitle = [expData objectForKey:@"experience_title"];
                expDescription = [expData objectForKey:@"experience_description"];
                expActivity = [expData objectForKey:@"experience_activity"];
                expInteraction = [expData objectForKey:@"experience_interaction"];
                hostFirstName = [expData objectForKey:@"host_firstname"];
                hostLastName = [expData objectForKey:@"host_lastname"];
                hostBio = [expData objectForKey:@"host_bio"];
                expReviewsArray = [expData objectForKey:@"experience_reviews"];
                NSUInteger numberOfReviews = expReviewsArray.count;
                numOfReviews = [NSString stringWithFormat:@"%lu",(unsigned long)numberOfReviews];
                NSNumber *rateNumber = [expData objectForKey:@"experience_rate"];
                expRate = [rateNumber stringValue];
                NSDictionary *reviewDictionary0 = [expReviewsArray objectAtIndex:0];
                reviews = expReviewsArray;
                reviewFirst = [reviewDictionary0 objectForKey:@"reviewer_firstname"];
                reviewLast = [reviewDictionary0 objectForKey:@"reviewer_lastname"];
                PREreviewerImageURL =[reviewDictionary0 objectForKey:@"reviewer_image"];
                reviewerImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: PREreviewerImageURL];
                
                reviewComment = [reviewDictionary0 objectForKey:@"review_comment"];
                ticketString = [expData objectForKey:@"included_ticket_detail"];
                foodString = [expData objectForKey:@"included_food_detail"];
                transportString = [expData objectForKey:@"included_transport_detail"];
                availableDateArray = [expData objectForKey:@"available_options"];
                NSLog(@"TEST:%lu DATE DATA",(unsigned long)availableDateArray.count);
                dynamicPriceArray = [expData objectForKey:@"experience_dynamic_price"];
                maxGuestNum = [expData objectForKey:@"experience_guest_number_max"];
                minGuestNum = [expData objectForKey:@"experience_guest_number_min"];
            }
            @catch (NSException * e) {
                NSLog(@"Experience/(ID:%@/) Exception: %@", _experience_id_string, e);
            }
        } else {
            NSString *errorMsg = [result objectForKey:@"Server Error"];
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
    NSLog(@"%@,%@,%@,%@",expTitle,_expPrice,reviewerImageURL,reviewComment);
#endif
    [_myTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([expData count] == 0) {
        [self fetchData];
    }

    [HUD dismissAfterDelay:1];
}

// todo: move to utility file
- (NSString *) decimalwithFormat:(NSString *)format floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
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
                                       options:SDWebImageAvoidAutoSetImage];
            
            NSString *coverImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], _experience_id_string];
            
            __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.center = cell.coverImage.center;
            activityIndicator.hidesWhenStopped = YES;

            [cell.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]
                              placeholderImage:nil
                                        options:SDWebImageAvoidAutoSetImage
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          [activityIndicator removeFromSuperview];
                                          if (image) {
                                              cell.coverImage.image = [self croppIngimageByImageName:image toRect:cell.coverImage.frame];
                                          }
                                      }];
            
            [cell.coverImage addSubview:activityIndicator];
            [activityIndicator startAnimating];
            
            cell.reservationLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"reservationPrefix", nil), hostFirstName, NSLocalizedString(@"reservationSuffix",nil)];
            
            // language
            cell.languageLabel.text = expLanguage;
            cell.priceLabel.text = [NSString stringWithFormat:@"$%@",_expPrice];
            cell.durationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"exp_detail_per_person_for", nil), expDuration];
            
            return cell;
        }
        case 1:
            if(!cell1)
            {
                cell1=[[TLDetailTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            }
            
            cell1.parentView = self.myTable;
            cell1.expTitleLabel.text = expTitle;
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            cell1.expDescriptionLabel.text = [expDescription stringByAppendingFormat:@" %@ %@", expActivity, expInteraction];
            if (self.isExpReadMoreOpen) {
                [cell1.readMoreButton setTitle:@"Read Less" forState:UIControlStateNormal];
                cell1.expDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell1.expDescriptionLabel.numberOfLines = 0;
                [cell1.expDescriptionLabel sizeToFit];
            } else {
                [cell1.readMoreButton setTitle:@"Read More" forState:UIControlStateNormal];
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
                [cell2.readMoreButton setTitle:@"Read Less" forState:UIControlStateNormal];
                cell2.hostBioLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell2.hostBioLabel.numberOfLines = 0;
                [cell2.hostBioLabel sizeToFit];
            } else {
                [cell2.readMoreButton setTitle:@"Read More" forState:UIControlStateNormal];
                cell2.hostBioLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                cell2.hostBioLabel.numberOfLines = 5;
            }
            
            [cell2.hostImage sd_setImageWithURL:[NSURL URLWithString:hostImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];

            cell2.hostFirstNameLabel.text = [NSLocalizedString(@"about_the_host", nil) stringByAppendingString: hostFirstName];
            cell2.hostBioLabel.text = hostBio;
            
            return cell2;
        case 3:
            if(!cell3)
            {
                cell3=[[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            cell3.selectionStyle = UITableViewCellSelectionStyleNone;
            if (numOfReviews > 0) {
                cell3.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"n_reviews", nil), numOfReviews];
            } else {
                cell3.countLabel.text = NSLocalizedString(@"no_reviews", nil);
            }
            
            cell3.reviewStars.rating = [expRate floatValue];
            cell3.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewFirst, reviewLast];
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
                                        options:SDWebImageAvoidAutoSetImage
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          [activityIndicator removeFromSuperview];
                                          if (image) {
                                              cell4.coverImage.image = [self croppIngimageByImageName:image toRect:cell4.coverImage.frame];
                                          }
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
        NSString * language = [languages objectAtIndex:i];
        if ([language isEqualToString:@"mandarin"]) {
            [languages replaceObjectAtIndex:i withObject:@"中文"];
        } else {
            [languages replaceObjectAtIndex:i withObject:[language capitalizedString]];
        }
    }
    
    return [languages componentsJoinedByString:@" / "];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.cellHeights objectAtIndex:indexPath.row] floatValue];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"checkoutSegue"]) {
        CheckoutViewController *vc=[segue destinationViewController];
        vc.exp_ID_string = _experience_id_string;
        vc.expImage = self.coverImage;
        vc.availbleDateArray = availableDateArray;
        vc.expTitleString = expTitle;
        vc.fixPriceString = _expPrice;
        vc.dynamicPriceArray = dynamicPriceArray;
        vc.languageString = expLanguage;
        vc.durationString = expDuration;
        vc.maxGuestNum = maxGuestNum;
        vc.minGuestNum = minGuestNum;
        NSString *lastNameInitial = [[hostLastName substringWithRange:NSMakeRange(0, 1)] stringByAppendingString:@"."];
        vc.hostName = [[NSArray arrayWithObjects:hostFirstName, lastNameInitial, nil] componentsJoinedByString:@" "];
    } else if ([segue.identifier isEqualToString:@"view_all_reviews"]) {
        ReviewTableViewController *vc=[segue destinationViewController];
        vc.reviews = reviews;
    }
    
}

@end
