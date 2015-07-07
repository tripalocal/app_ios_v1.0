//
//  MyTripTableViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 7/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MyTripTableViewController.h"
#import "MyTripTableViewCell.h"
#import "TLDetailViewController.h"
#import "MyTripViewController.h"
#import "Constant.h"

@interface MyTripTableViewController ()

@end

@implementation MyTripTableViewController {
    NSMutableArray *myTrips;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myTrips = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self fetchMyTrips:token];
    }
    
    if ([myTrips count] == 0) {
// todo
    }
}

- (void)fetchMyTrips:(NSString *) token {
    NSURL *url = [NSURL URLWithString:testServerMyTrip];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        if ([httpResponse statusCode] == 200) {
            NSArray *allTrips = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:nil];
            myTrips = [self abstractTripsFilter:allTrips];
            
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
}

- (NSMutableArray *)abstractTripsFilter:(NSArray *) allTrips {
    [NSException raise:@"Invoked abstract method" format:@"Invoked abstract method"];
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [myTrips count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    MyTripTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTripTableViewCell"];
    if(!cell) {
        cell = [[MyTripTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyTripTableViewCell"];
    }
    
    cell.tag = indexPath.row;
    cell.parentView = self.tableView;
    NSDictionary *trip = [myTrips objectAtIndex:indexPath.row];
    NSString *imageURL = [trip objectForKey:@"host_image"];
    NSString *datetimeString = [trip objectForKey:@"datetime"];
    // Convert string to date object
    NSDate *date = [self parseDateTimeString:datetimeString];
    
    // convert back
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-LL-yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    UIImage *hostImage = [self fetchImage:imageURL];
    cell.hostImage.image = hostImage;
    
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", testServerImageURL, [trip objectForKey:@"experience_id"]];
    NSData *experienceImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:absoluteImageURL]];
    cell.backgroudImage.image = [[UIImage alloc]initWithData:experienceImageData];
    
    NSDate *today = [NSDate date];
    NSDate *dateOnly = [self dateWithNoTime: date];
    if ([dateOnly compare:[self dateWithNoTime:today]] == NSOrderedSame) {
        cell.dateLabel.text = @"Today";
        [cell.dateLabel setTextColor:[UIColor redColor]];
    } else {
        cell.dateLabel.text = [dateFormatter stringFromDate:date];
    }
    
    cell.timeLabel.text = [timeFormatter stringFromDate:date];
    cell.hostNameLabel.text = [trip objectForKey:@"host_name"];
    cell.guestNumberLabel.text = [[trip objectForKey:@"guest_number"] stringValue];
    cell.experienceTitle.text = [trip objectForKey:@"experience_title"];
    [cell.experienceTitle setTextColor:[UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f]];
    cell.telephoneLabel.text = [trip objectForKey:@"host_phone_number"];
    cell.instructionText.text = [trip objectForKey:@"meetup_spot"];
    NSString *status = [trip objectForKey:@"status"];
    if ([status isEqualToString:@"paid"]) {
        cell.statusLabel.text = @"Requested";
    } else {
        cell.statusLabel.text = @"Confirmed";
    }
    
    return cell;
}

- (NSDate *)parseDateTimeString:(NSString *) datetimeString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormat setDateFormat:@"yyyy-LL-dd'T'HH:mm:ss'Z'"];
    NSRange needleRange = NSMakeRange(0, 19);
    NSString *dateStringUTC = [[datetimeString substringWithRange:needleRange] stringByAppendingString: @"Z"];
    return [dateFormat dateFromString:dateStringUTC];
}

- (NSDate *)dateWithNoTime:(NSDate *)date {
    unsigned int flags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

- (void)viewWillAppear:(BOOL)animated {
    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
    mytripController.segmentTitleView.hidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    //    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
//    //    mytripController.segmentTitleView.hidden = YES;
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//    [super viewWillDisappear:animated];
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
    mytripController.segmentTitleView.hidden = YES;

    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    TLDetailViewController *controller = (TLDetailViewController *)navController.topViewController;
    NSIndexPath *index = [self.tableView indexPathForSelectedRow];
    NSDictionary *trip = [myTrips objectAtIndex:index.row];
    
    controller.experience_id_string = [trip objectForKey:@"experience_id"];
    
    //        NSString *hostImageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfHostImage",(long)index.row];
    //        NSString *expImageCachingIdentifier = [NSString stringWithFormat:@"Cell%ldOfExpImage",(long)index.row];
    //        vc.hostImage = [self.cachedImages valueForKey:hostImageCachingIdentifier];
    //        vc.coverImage = [self.cachedImages valueForKey:expImageCachingIdentifier];
    
}

- (UIImage *) fetchImage:(NSString *) imageURL {
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@%@", testServerImageURL, imageURL];
    NSURL *url = [NSURL URLWithString:absoluteImageURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    UIImage *image = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        image = [UIImage imageWithData:data];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return image;
}

@end
