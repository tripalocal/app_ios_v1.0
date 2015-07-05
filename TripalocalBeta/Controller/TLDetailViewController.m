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

@interface TLDetailViewController ()
{
    NSURLConnection *connection;
    NSMutableData *jsonData;
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
}

@property (strong, nonatomic) NSMutableDictionary *cachedImages;
@end

@implementation TLDetailViewController

// Should login in first to access checkout page.
- (IBAction)checkout:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
    if (token) {
        [self performSegueWithIdentifier:@"checkoutSegue" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    connectionFinished=0;
    
    self.cachedImages = [[NSMutableDictionary alloc]init];
    
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

    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        if (jsonData==NULL) {
            jsonData=[[NSMutableData alloc]init];
        }
    }
    
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
    
    while (connectionFinished==0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    
    NSString *imageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfHostImage",(long)indexPath.row];
    switch (indexPath.row) {
        case 0:
            if(!cell)
            {
                cell=[[TLDetailTableViewCell0 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier0];
            }
            cell.coverImage.image = _coverImage;
            cell.hostImage.image = _hostImage;
            cell.reservationLabel.text = [cell.reservationLabel.text stringByAppendingFormat:@" %@", hostFirstName];
            cell.languageLabel.text = expLanguage;
            cell.priceLabel.text = [cell.priceLabel.text stringByAppendingFormat:@" %@",expPrice];
            cell.durationLabel.text = [cell.durationLabel.text stringByAppendingFormat:@"for %@ hours", expDuration];
            
            return cell;
        
        case 1:
            if(!cell1)
            {
                cell1=[[TLDetailTableViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            }
            cell1.expTitleLabel.text = expTitle;
            cell1.expDescriptionLabel.text = [expDescription stringByAppendingFormat:@" %@ %@", expActivity, expInteraction];
            
            return cell1;
        case 2:
            if(!cell2)
            {
                cell2=[[TLDetailTableViewCell2 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            }
            cell2.hostFirstNameLabel.text = hostFirstName;
            cell2.hostImage.image = _hostImage;
            cell2.hostBioLabel.text = hostBio;
            
            return cell2;
        case 3:
            if(!cell3)
            {
                cell3=[[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            }
            
            
            cell3.countLabel.text = numOfReviews;
            cell3.rateLabel.text = expRate;
            cell3.reviewerFirstName.text = reviewFirst;
            cell3.reviewerLastName.text = reviewLast;
            cell3.commentLabel.text = reviewComment;

            cell3.reviewerImage.image = [UIImage imageNamed:@"default_profile_image.png"];
            
            if([self.cachedImages objectForKey:imageCachingIdentifier]!=nil){
                cell3.reviewerImage.image = [self.cachedImages valueForKey:imageCachingIdentifier];
            }
            else if(PREreviewerImageURL.length <= 0){
                cell3.reviewerImage.image = [UIImage imageNamed:@"default_profile_image.png"];
            }
            else{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *hostImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:reviewerImageURL]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        cell3.reviewerImage.image = [[UIImage alloc]initWithData:hostImageData];
                        [self.cachedImages setValue:cell3.reviewerImage.image forKey:imageCachingIdentifier];
                    });
                
                });
                
            }
            //Reviewer Image
            
            
            return cell3;
        case 4:
            if(!cell4)
            {
                cell4=[[TLDetailTableViewCell4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
            }
            
            cell4.coverImage.image = _coverImage;
            return cell4;
        case 5:
            if(!cell5)
            {
                cell5=[[TLDetailTableViewCell5 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier5];
            }
            
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


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [jsonData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [jsonData appendData:data];
    
}



-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error:(Details)Failed with connection error.");
}



-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *allDataDictionary=[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    @try {
        hostImageURL=[allDataDictionary objectForKey:@"host_image"];
        expLanguage=[allDataDictionary objectForKey:@"experience_language"];
        NSNumber *expPriceNumber = [allDataDictionary objectForKey:@"experience_price"];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setRoundingMode: NSNumberFormatterRoundUp];
        expPrice = [formatter stringFromNumber:expPriceNumber];
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
        reviewFirst = [reviewDictionary0 objectForKey:@"reviewer_firstname"];
        reviewLast = [reviewDictionary0 objectForKey:@"reviewer_lastname"];
        PREreviewerImageURL =[reviewDictionary0 objectForKey:@"reviewer_image"];
        reviewerImageURL = [imageBaseURL stringByAppendingString: PREreviewerImageURL];
        reviewComment = [reviewDictionary0 objectForKey:@"review_comment"];
        connectionFinished=1;
    }
    @catch (NSException * e) {
        NSLog(@"Experience/(ID:%@/) Exception: %@", _experience_id_string, e);
    }
    [HUD dismissAfterDelay:3.0];
    
    
    NSLog(@"%@,%@,%@,%@",expTitle,expPrice,reviewerImageURL,reviewComment);
}

@end
