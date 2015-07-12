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
#import "Constant.h"
#import "TLDetailViewController.h"
#import "JGProgressHUD.h"

@interface TLSearchViewController ()
@property (strong, nonatomic) NSMutableDictionary *cachedImages;
@end

@implementation TLSearchViewController{
    JGProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.expList = [self fetchExpData:self.cityName];
    
    [self.tableView reloadData];
}

- (void)saveToWishListClicked:(NSInteger)buttonTag {
    [self toggleWishList: buttonTag];
}

- (IBAction)toggleWishList:(NSInteger)buttonTag {
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    NSIndexPath * index = [NSIndexPath indexPathForRow:buttonTag inSection:0];
    
    if (token) {
        NSString *expIdString = [[[self.expList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
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
    
    TLSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if(!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    NSDictionary *exp = [self.expList objectAtIndex:indexPath.row];
    NSString *expIdString = [[exp objectForKey:@"id"] stringValue];
    
    NSString *duration = [[exp objectForKey:@"duration"] stringValue];
    NSString *handledDurationString = [duration stringByAppendingString:@" Hours"];
    cell.durationLabel.text = handledDurationString;
    cell.titleLabel.text = [exp objectForKey:@"title"];
    cell.hostImage.image = [UIImage imageNamed:@"default_profile_image.png"];
    cell.languageLabel.text = [exp objectForKey:@"language"];
    cell.descriptionLabel.text = [exp objectForKey:@"description"];
    cell.hostImage.image = [UIImage imageNamed:@"default_profile_image.png"];
    cell.experienceImage.image = nil;
    
    NSString *hostImageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfHostImage",(long)indexPath.row];
    NSString *expImageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfExpImage",(long)indexPath.row];
    
    if([self.cachedImages objectForKey:hostImageCachingIdentifier]!=nil){
        cell.hostImage.image = [self.cachedImages valueForKey:hostImageCachingIdentifier];
        cell.experienceImage.image = [self.cachedImages valueForKey:expImageCachingIdentifier];
    } else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *hostImageURL = [exp objectForKey:@"host_image"];
            
            NSData *hostImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[testServerImageURL stringByAppendingString: hostImageURL]]];
            
            NSString *backgroundImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", testServerImageURL, expIdString];
            
            NSData *experienceImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:backgroundImageURL]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.hostImage.image = [[UIImage alloc] initWithData:hostImageData];
                cell.experienceImage.image = [[UIImage alloc] initWithData:experienceImageData];
                [self.cachedImages setValue:cell.hostImage.image forKey:hostImageCachingIdentifier];
                [self.cachedImages setValue:cell.experienceImage.image forKey:expImageCachingIdentifier];
            });
            
        });
    }
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *wishList = [userDefaults objectForKey:@"wish_list"];
    
    if ([wishList containsObject:expIdString]) {
        [cell.wishListButton setBackgroundImage:[UIImage imageNamed:@"wishlisted.png"] forState:UIControlStateNormal];
    } else {
        [cell.wishListButton setBackgroundImage:[UIImage imageNamed:@"unwishlisted.png"] forState:UIControlStateNormal];
    }
    cell.delegate = self;
    cell.wishListButton.tag = indexPath.row;
    cell.priceLabel.text = [[[self.expList objectAtIndex:indexPath.row] objectForKey:@"price"] stringValue];

    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)fetchExpData:(NSString *) cityName {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    
    // fixed date?
    NSString *post = [NSString stringWithFormat:@"{\"start_datetime\":\"2015-05-08\", \"end_datetime\":\"2015-05-9\", \"city\":\"%@\", \"guest_number\":\"2\", \"keywords\":\"Food & wine, Education, History & culture, Architecture, For couples, Photography worthy, Livability research, Kids friendly, Outdoor & nature, Shopping, Sports & leisure, Host with car, Extreme fun, Events, Health & beauty, Private group\"}", cityName];
#ifdef DEBUG
    NSLog(@"Sending date = %@",post);
#endif
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://www.tripalocal.com/service_search/"]];
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
            expList = [indexOfExperience objectForKey:@"experiences"];
            
#ifdef DEBUG
            NSLog(@"number of cells: %lu", (unsigned long)expList.count);
#endif
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetching Data Failed"
                                                            message:@"Server Error"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return expList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchResultSegue"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        TLDetailViewController *vc = (TLDetailViewController *) navController.topViewController;
        NSIndexPath *index=[_tableView indexPathForSelectedRow];
        vc.experience_id_string = [[[self.expList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
    }
    
}

@end
