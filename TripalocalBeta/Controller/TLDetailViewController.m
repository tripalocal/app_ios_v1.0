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
#import "Constant.h"

@interface TLDetailViewController ()
{
    NSString *hostImageURL;
    NSString *expLanguage;
    NSString *expPrice;
    NSString *expDuration;
    NSString *expTitle;
    NSString *expDescription;
    NSString *expActivity;
    NSString *expInteraction;
    NSMutableArray *expReviewsArray;
    NSString *hostFirstName;
    NSString *hostBio;
    NSString *numOfReviews;
    NSString *expRate;
    NSString *reviewFirst;
    NSString *reviewLast;
    NSString *PREreviewerImageURL;
    NSString *reviewerImageURL;
    NSString *reviewComment;
    JGProgressHUD *HUD;
    int connectionFinished;
    NSData *reviewerImageData;
    NSMutableArray *dynamicPriceArray;
    NSNumber *maxGuestNum;
    NSNumber *minGuestNum;
    NSString *foodString;
    NSString *ticketString;
    NSString *transportString;
    NSMutableArray *availableDateArray;
    NSArray *reviews;
}

@property (strong, nonatomic) NSMutableDictionary *cachedImages;
@end

@implementation TLDetailViewController

// Should login in first to access checkout page.
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
    self.isExpReadMoreOpen = NO;
    self.isHostReadMoreOpen = NO;

    self.cellHeights = [@[@306, @240, @320, @385, @106, @240] mutableCopy];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    connectionFinished=0;
    
    self.cachedImages = [[NSMutableDictionary alloc]init];
    reviews = [[NSArray alloc] init];
    
    //Indicator
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    NSString *post = [NSString stringWithFormat:@"{\"experience_id\":\"%@\"}",_experience_id_string];
    
    NSLog(@"(Detail)POST: %@", post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://www.tripalocal.com/service_experience/"]];
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
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *allDataDictionary=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            @try {
                hostImageURL = [imageBaseURL stringByAppendingString: [allDataDictionary objectForKey:@"host_image"]];
                expLanguage = [self transformLanugage:[allDataDictionary objectForKey:@"experience_language"]];
                NSNumber *expPriceNumber = [allDataDictionary objectForKey:@"experience_price"];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setMaximumFractionDigits:2];
                
                [formatter setRoundingMode: NSNumberFormatterRoundUp];
                expPrice = [self decimalwithFormat:@"0" floatV:[expPriceNumber floatValue]];
                NSNumber *expDurationNumber = [allDataDictionary objectForKey:@"experience_duration"];
                expDuration = [expDurationNumber stringValue];
                expTitle = [allDataDictionary objectForKey:@"experience_title"];
                expDescription = [allDataDictionary objectForKey:@"experience_description"];
                expActivity = [allDataDictionary objectForKey:@"experience_activity"];
                expInteraction = [allDataDictionary objectForKey:@"experience_interaction"];
                hostFirstName = [allDataDictionary objectForKey:@"host_firstname"];
                hostBio = [allDataDictionary objectForKey:@"host_bio"];
                expReviewsArray = [allDataDictionary objectForKey:@"experience_reviews"];
                NSUInteger numberOfReviews = expReviewsArray.count;
                numOfReviews = [NSString stringWithFormat:@"%lu",(unsigned long)numberOfReviews];
                NSNumber *rateNumber = [allDataDictionary objectForKey:@"experience_rate"];
                expRate = [rateNumber stringValue];
                NSDictionary *reviewDictionary0 = [expReviewsArray objectAtIndex:0];
                reviews = expReviewsArray;
                reviewFirst = [reviewDictionary0 objectForKey:@"reviewer_firstname"];
                reviewLast = [reviewDictionary0 objectForKey:@"reviewer_lastname"];
                PREreviewerImageURL =[reviewDictionary0 objectForKey:@"reviewer_image"];
                reviewerImageURL = [imageBaseURL stringByAppendingString: PREreviewerImageURL];
                reviewComment = [reviewDictionary0 objectForKey:@"review_comment"];
                
                ticketString = [allDataDictionary objectForKey:@"included_ticket_detail"];
                foodString = [allDataDictionary objectForKey:@"included_food_detail"];
                transportString = [allDataDictionary objectForKey:@"included_transport_detail"];
                availableDateArray = [allDataDictionary objectForKey:@"available_options"];
                NSLog(@"TEST:%lu DATE DATA",(unsigned long)availableDateArray.count);
                dynamicPriceArray = [allDataDictionary objectForKey:@"experience_dynamic_price"];
                maxGuestNum = [allDataDictionary objectForKey:@"experience_guest_number_max"];
                minGuestNum = [allDataDictionary objectForKey:@"experience_guest_number_min"];
            }
            @catch (NSException * e) {
                NSLog(@"Experience/(ID:%@/) Exception: %@", _experience_id_string, e);
            }
            [HUD dismissAfterDelay:1.5];
        } else {
            NSString *errorMsg = [result objectForKey:@"Server Error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                            message:errorMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
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

    NSLog(@"%@,%@,%@,%@",expTitle,expPrice,reviewerImageURL,reviewComment);
    
}

- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSString *hostImageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfHostImage",(long)indexPath.row];
    NSString *expImageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfExpImage",(long)indexPath.row];
    switch (indexPath.row) {
        case 0:
            if (!cell) {
                cell = [[TLDetailTableViewCell0 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier0];
            }
            
            if ([self.cachedImages objectForKey:hostImageCachingIdentifier]) {
                cell.hostImage.image = [self.cachedImages valueForKey:hostImageCachingIdentifier];
                cell.coverImage.image = [self.cachedImages valueForKey:expImageCachingIdentifier];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *hostImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:hostImageURL]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        cell.hostImage.image = [[UIImage alloc] initWithData:hostImageData];
                        [self.cachedImages setValue:cell.hostImage.image forKey:hostImageCachingIdentifier];
                    });
                    
                });
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *coverImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", testServerImageURL, _experience_id_string];
                    NSData *coverImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:coverImageURL]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        cell.coverImage.image = [[UIImage alloc] initWithData:coverImageData];
                        [self.cachedImages setValue:cell.coverImage.image forKey:expImageCachingIdentifier];
                    });
                    
                });
                
            }
            cell.reservationLabel.text = [cell.reservationLabel.text stringByAppendingFormat:@" %@", hostFirstName];
            // language
            cell.languageLabel.text = expLanguage;
            cell.priceLabel.text = [NSString stringWithFormat:@"$%@",expPrice];
            cell.durationLabel.text = [NSString stringWithFormat:@"for %@ hours", expDuration];
            
            return cell;
        
        case 1:
            if(!cell1)
            {
                cell1=[[TLDetailTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            }
            
            cell1.parentView = self.myTable;
            cell1.expTitleLabel.text = expTitle;
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
            
            if ([self.cachedImages objectForKey:hostImageCachingIdentifier]) {
                cell2.hostImage.image = [self.cachedImages valueForKey:hostImageCachingIdentifier];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *hostImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:hostImageURL]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        cell2.hostImage.image = [[UIImage alloc] initWithData:hostImageData];
                        [self.cachedImages setValue:cell2.hostImage.image forKey:hostImageCachingIdentifier];
                    });
                    
                });
            }
            cell2.hostFirstNameLabel.text = [@"About the host, " stringByAppendingString: hostFirstName];
            cell2.hostBioLabel.text = hostBio;
            
            return cell2;
        case 3:
            if(!cell3)
            {
                cell3=[[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            
            cell3.countLabel.text = [NSString stringWithFormat:@"%@ reviews", numOfReviews];
            cell3.rateLabel.text = [NSString stringWithFormat:@"%@ stars", expRate];
            cell3.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewFirst, reviewLast];
            cell3.commentLabel.text = reviewComment;

            cell3.reviewerImage.image = [UIImage imageNamed:@"default_profile_image.png"];
            
            if([self.cachedImages objectForKey:hostImageCachingIdentifier]!=nil){
                cell3.reviewerImage.image = [self.cachedImages valueForKey:hostImageCachingIdentifier];
            }
            else if(PREreviewerImageURL.length <= 0){
                cell3.reviewerImage.image = [UIImage imageNamed:@"default_profile_image.png"];
            }
            else{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *hostImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:reviewerImageURL]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        cell3.reviewerImage.image = [[UIImage alloc]initWithData:hostImageData];
                        [self.cachedImages setValue:cell3.reviewerImage.image forKey:hostImageCachingIdentifier];
                    });
                
                });
                
            }
            
            return cell3;
        case 4:
            if(!cell4) {
                cell4=[[TLDetailTableViewCell4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
            }
            
            if ([self.cachedImages objectForKey:expImageCachingIdentifier]) {
                cell4.coverImage.image = [self.cachedImages valueForKey:expImageCachingIdentifier];
            } else {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *backgroundImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", testServerImageURL, _experience_id_string];
                    
                    NSData *experienceImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:backgroundImageURL]];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        cell4.coverImage.image = [[UIImage alloc] initWithData:experienceImageData];
                        [self.cachedImages setValue:cell4.coverImage.image forKey:expImageCachingIdentifier];
                    });
                    
                });
            }
            
            return cell4;
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


-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error:(Details)Failed with connection error.");
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
    
    return [languages componentsJoinedByString:@"/"];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{

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
        vc.fixPriceString = expPrice;
        vc.dynamicPriceArray = dynamicPriceArray;
        vc.languageString = expLanguage;
        vc.durationString = expDuration;
        vc.maxGuestNum = maxGuestNum;
        vc.minGuestNum = minGuestNum;
    } else if ([segue.identifier isEqualToString:@"view_all_reviews"]) {
        ReviewTableViewController *vc=[segue destinationViewController];
        vc.reviews = reviews;
    }
    
}

@end
