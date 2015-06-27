//
//  TLSearchViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLSearchViewController.h"
#import "TLSearchTableViewCell.h"
#import "Spinner.h"

@interface TLSearchViewController ()

@end

@implementation TLSearchViewController{
    NSURLConnection *connection;
    NSMutableData *jsonData;
    NSMutableArray *languageArray;
    NSMutableArray *durationArray;
    NSMutableArray *descriptionArray;
    NSMutableArray *titleArray;
    NSMutableArray *hostImageURLArray;
    NSMutableArray *experienceImageURLArray;
    int connectionFinished;
    Spinner *spinner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    
    //spinner
    spinner = [Spinner loadSpinnerIntoView:self.view];
    
    connectionFinished=0;
    
    //Init
    languageArray = [[NSMutableArray alloc]init];
    durationArray = [[NSMutableArray alloc]init];
    descriptionArray = [[NSMutableArray alloc]init];
    titleArray = [[NSMutableArray alloc]init];
    hostImageURLArray = [[NSMutableArray alloc]init];
    experienceImageURLArray = [[NSMutableArray alloc]init];


    
    //Request for network
    NSString *post = [NSString stringWithFormat:@"{\"start_datetime\":\"2015-05-08\", \"end_datetime\":\"2015-05-24\", \"city\":\"melbourne\", \"guest_number\":\"2\", \"keywords\":\"Food&Wine,Education,History&Culture\"}"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://www.tripalocal.com/service_search/"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request returningResponse:&requestResponse error:nil];
    
//    NSString *requestReply = [[NSString alloc] initWithBytes:[requestHandler bytes] length:[requestHandler length] encoding:NSASCIIStringEncoding];
//    NSLog(@"requestReply: %@", requestReply);
    if (request!=NULL) {
        NSLog(@"requestReply: YES");
    }
    
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
    NSLog(@"Error:(Search)Failed with connection error.");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *baseImageURLString = @"https://www.tripalocal.com/images/";
    NSLog(@"Connection Did Finish Loading.");
    NSMutableArray *allDataDictionary=[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    NSUInteger numOfData = allDataDictionary.count;
    
//    for ( int currentIndex = 0 ; currentIndex < numOfData ; currentIndex++){
        NSDictionary *indexOfExperience = [allDataDictionary objectAtIndex:0];
        NSString *cityString = [indexOfExperience objectForKey:@"city"];
        NSMutableArray *experiences = [indexOfExperience objectForKey:@"experiences"];
        
        for (int i=0; i<experiences.count; i++) {
            NSDictionary *experiencesArray = [experiences objectAtIndex:i];
            NSString *languageString = [experiencesArray objectForKey:@"language"];
            NSString *descriptionString = [experiencesArray objectForKey:@"description"];
            NSNumber *durationNumber = [experiencesArray objectForKey:@"duration"];
            NSString *durationString = [durationNumber stringValue];
            NSString *handledDurationString = [durationString stringByAppendingString:@" Hours"];
            NSString *titleString = [experiencesArray objectForKey:@"title"];
            NSString *retrivedHostImageURLString = [experiencesArray objectForKey:@"host_image"];
            NSString *finalHostImageURLString = [baseImageURLString stringByAppendingString:retrivedHostImageURLString];
            NSNumber *idNumber = [experiencesArray objectForKey:@"id"];
            NSString *idString = [idNumber stringValue];
            NSString *experienceImageURLString = [[[baseImageURLString stringByAppendingString:@"thumbnails/experiences/experience"] stringByAppendingString:idString] stringByAppendingString:@"_1.jpg"];
            
            [languageArray addObject:languageString];
            [descriptionArray addObject:descriptionString];
            [durationArray addObject:handledDurationString];
            [titleArray addObject:titleString];
            [hostImageURLArray addObject:finalHostImageURLString];
            [experienceImageURLArray addObject:experienceImageURLString];
        }
//    }
    
    
    //Finish Loading
    connectionFinished=1;
    NSLog(@"Loading: %@",languageArray);
    NSLog(@"number of cells: %lu",(unsigned long)languageArray.count);
    [spinner removeSpinner];

}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    while (connectionFinished==0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    static NSString *cellIdentifier=@"SearchCell";
    
    TLSearchTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[TLSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *hostImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[hostImageURLArray objectAtIndex:indexPath.row]]];
        NSData *experienceImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[experienceImageURLArray objectAtIndex:indexPath.row]]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.languageLabel.text=[languageArray objectAtIndex:indexPath.row];
            cell.durationLabel.text=[durationArray objectAtIndex:indexPath.row];
            cell.descriptionLabel.text=[descriptionArray objectAtIndex:indexPath.row];
            cell.titleLabel.text=[titleArray objectAtIndex:indexPath.row];
            cell.hostImage.image = [[UIImage alloc]initWithData:hostImageData];
            cell.experienceImage.image = [[UIImage alloc]initWithData:experienceImageData];
        });

    });
    
    
    
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    while (connectionFinished==0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    return [languageArray count];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
