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
#import "TLHomeViewController.h"

@interface MyTripTableViewController ()

@end

@implementation MyTripTableViewController {
    NSMutableArray *myTrips;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    myTrips = [[NSMutableArray alloc] init];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-LL-yyyy"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [self.view insertSubview:self.nomatchesView belowSubview:self.tableView];
}

- (void)fetchMyTrips:(NSString *) token {
    NSURL *url = [NSURL URLWithString:mytripService];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"MyTripsToExpList" sender:self];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath {
    MyTripTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTripTableViewCell"];
    if(!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"MyTripTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyTripTableViewCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"MyTripTableViewCell"];
    }
    
    cell.tag = indexPath.row;
    cell.parentView = self.tableView;
    NSDictionary *trip = [myTrips objectAtIndex:indexPath.row];
    NSString *imageURL = [trip objectForKey:@"host_image"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *hostImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString: [imageServiceURL stringByAppendingString: imageURL]]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.hostImage.image = [[UIImage alloc] initWithData:hostImageData];
        });
    });
    
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", imageServiceURL, [trip objectForKey:@"experience_id"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *backgroundImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:absoluteImageURL]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.backgroudImage.image = [[UIImage alloc] initWithData:backgroundImageData];
        });
    });
    
    NSString *datetimeString = [trip objectForKey:@"datetime"];
    // Convert string to date object
    NSDate *dateUTC = [self parseDateTimeString:datetimeString];
    
    // convert back
    NSDate *today = [NSDate date];
    NSDate *dateOnly = [self dateWithNoTime: dateUTC];
    if ([dateOnly compare:[self dateWithNoTime:today]] == NSOrderedSame) {
        cell.dateLabel.text = @"Today";
        [cell.dateLabel setTextColor:[UIColor redColor]];
    } else {
        cell.dateLabel.text = [dateFormatter stringFromDate:dateUTC];
        [cell.dateLabel setTextColor:[UIColor blackColor]];
    }
    
    cell.timeLabel.text = [timeFormatter stringFromDate:dateUTC];
    cell.hostNameLabel.text = [@"with " stringByAppendingString:[trip objectForKey:@"host_name"]];
    cell.guestNumberLabel.text = [[trip objectForKey:@"guest_number"] stringValue];
    cell.experienceTitle.text = [trip objectForKey:@"experience_title"];
    [cell.experienceTitle setTextColor:[UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f]];
    cell.telephoneLabel.text = [trip objectForKey:@"host_phone_number"];
    cell.instructionText.text = [trip objectForKey:@"meetup_spot"];
    NSString *status = [trip objectForKey:@"status"];
    if ([status isEqualToString:@"paid"]) {
        [cell.statusButton setTitle:@"Requested" forState:UIControlStateNormal];
        [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f]];
    } else {
        [cell.statusButton setTitle:@"Confirmed" forState:UIControlStateNormal];
        [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.51f green:0.82f blue:0.00f alpha:1.0f]];
    }
    
    return cell;
}

- (NSDate *)parseDateTimeString:(NSString *) datetimeString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormat setDateFormat:@"yyyy-LL-dd'T'HH:mm:ssZ"];
    NSRange lastColumn = [datetimeString rangeOfString:@":" options:NSBackwardsSearch];
    
    NSString *resultDateTimeString = [datetimeString stringByReplacingCharactersInRange:lastColumn
                                                                             withString: @""];
    return [dateFormat dateFromString:resultDateTimeString];
}

- (NSDate *)dateWithNoTime:(NSDate *)date {
    unsigned int flags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self fetchMyTrips:token];
            if([myTrips count] == 0 ){
                [self.view bringSubviewToFront:self.nomatchesView];
            } else {
                [self.view sendSubviewToBack:self.nomatchesView];
            }
    }
    
    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
    mytripController.segmentTitleView.hidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.tableView reloadData];
    
    [super viewWillAppear:animated];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
    mytripController.segmentTitleView.hidden = YES;

    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    TLDetailViewController *controller = (TLDetailViewController *)navController.topViewController;
    NSIndexPath *index = [self.tableView indexPathForSelectedRow];
    NSDictionary *trip = [myTrips objectAtIndex:index.row];
    
    controller.experience_id_string = [trip objectForKey:@"experience_id"];
}

- (UIImage *) fetchImage:(NSString *) imageURL {
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@%@", imageServiceURL, imageURL];
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
- (IBAction)startExploring:(id)sender {
    UINavigationController * first = [self.tabBarController.viewControllers objectAtIndex:0];
    [first performSelector:@selector(popToRootViewControllerAnimated:) withObject:nil];
    [self.tabBarController setSelectedIndex:0];
}

@end
