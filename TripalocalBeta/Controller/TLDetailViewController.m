//
//  TLDetailViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 25/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLDetailViewController.h"

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
    NSString *reviewerImageURL;
    NSString *reviewComment;
}

@end

@implementation TLDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _myTable.delegate = self;
    _myTable.dataSource = self;
    
    
    
    
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
    
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    
    NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
//    NSLog(@"requestReply: %@", requestReply);
    
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
    static NSString *cellIdentifier=@"cell";
    
    UITableViewCell *cell=(UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
    hostImageURL=[allDataDictionary objectForKey:@"host_image"];
    expLanguage=[allDataDictionary objectForKey:@"experience_language"];
    NSNumber *expPriceNumber = [allDataDictionary objectForKey:@"experience_price"];
    expPrice = [expPriceNumber stringValue];
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
    reviewerImageURL = [reviewDictionary0 objectForKey:@"reviewer_image"];
    reviewComment = [reviewDictionary0 objectForKey:@"review_comment"];
    
    NSLog(@"%@,%@,%@,%@",expTitle,expPrice,reviewerImageURL,reviewComment);
}

@end
