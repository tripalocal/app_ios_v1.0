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
#import "URLConfig.h"
#import "JGProgressHUD.h"
#import "Constant.h"
#import "TLHomeViewController.h"
#import "ChatDetailViewController.h"
#import "LocalDetailViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>

@interface MyTripTableViewController () 

@end

@implementation MyTripTableViewController {
    JGProgressHUD *HUD;
    NSMutableArray *myTrips;
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
}
@synthesize host_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:1.0];
    
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
    NSURL *url = [NSURL URLWithString:[URLConfig myTripServiceURLString]];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
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
    NSDictionary *trip = [myTrips objectAtIndex:indexPath.row];
    if ([trip[@"experience_type"] isEqualToString:@"PRIVATE"] || [trip[@"experience_type"] isEqualToString:@"NONPRIVATE"]) {
        [self performSegueWithIdentifier:@"MyTripsToExpList" sender:self];
    } else {
        [self performSegueWithIdentifier:@"MyTripsToLocalExpList" sender:self];
    }
    
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
    
    if ([trip[@"experience_type"] isEqualToString:@"PRIVATE"] || [trip[@"experience_type"] isEqualToString:@"NONPRIVATE"]) {
        
        cell.hostImage.hidden = NO;
        cell.hostNameLabel.hidden = NO;
        NSString *imageURL = trip[@"host_image"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *hostImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString: [[URLConfig imageServiceURLString] stringByAppendingString: imageURL]]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.hostImage.image = [[UIImage alloc] initWithData:hostImageData];
            });
        });
        
        cell.hostNameLabel.text = [@"with " stringByAppendingString:trip[@"host_name"]];

    } else {
        cell.hostImage.hidden = YES;
        cell.hostNameLabel.hidden = YES;
    }
    
    
    cell.telephoneLabel.text = trip[@"host_phone_number"];
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], trip[@"experience_id"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *backgroundImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:absoluteImageURL]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            cell.backgroudImage.image = [[UIImage alloc] initWithData:backgroundImageData];
        });
    });
    
    NSString *datetimeString = trip[@"datetime"];
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

    cell.guestNumberLabel.text = [trip[@"guest_number"] stringValue];
    cell.experienceTitle.text = trip[@"experience_title"];
    [cell.experienceTitle setTextColor:[UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f]];

    cell.instructionText.text = trip[@"meetup_spot"];
    NSString *status = trip[@"status"];
    if ([status isEqualToString:@"paid"]) {
        [cell.statusButton setTitle:NSLocalizedString(@"booking_status_requested", nil) forState:UIControlStateNormal];
        [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f]];
    } else if ([status isEqualToString:@"rejected"]) {
        [cell.statusButton setTitle:NSLocalizedString(@"booking_status_cancelled", nil) forState:UIControlStateNormal];
        [cell.statusButton setBackgroundColor:[UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f]];
    } else {
        [cell.statusButton setTitle:NSLocalizedString(@"booking_status_confirmed", nil) forState:UIControlStateNormal];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    if (token && self.nomatchesView) {
        [self fetchMyTrips:token];
            if([myTrips count] == 0 ){
                [self.view bringSubviewToFront:self.nomatchesView];
            } else {
                [self.view sendSubviewToBack:self.nomatchesView];
            }
    }
    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
    mytripController.titleViewHeight.constant = 48.f;
    mytripController.segmentTitleView.hidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
    [self.tableView reloadData];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    
    MyTripViewController *mytripController = (MyTripViewController *)self.containerController;
    mytripController.segmentTitleView.hidden = YES;
    mytripController.titleViewHeight.constant = 0.f;

//    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;

    NSIndexPath *index = [self.tableView indexPathForSelectedRow];
    NSDictionary *trip = [myTrips objectAtIndex:index.row];

    
    if ([segue.identifier isEqualToString:@"myTripToChat"]){
        ChatDetailViewController *chatDetail = [segue destinationViewController];
        chatDetail.chatWithUser = host_id;
        NSLog(@"Passing the host id: %@",host_id);
    }  else if ([segue.identifier isEqualToString:@"MyTripsToExpList"]) {
//        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        TLDetailViewController *vc = (TLDetailViewController *)segue.destinationViewController;

        vc.expType = trip[@"type"];
        vc.experience_id_string = [trip[@"experience_id"] stringValue];

    } else if ([segue.identifier isEqualToString:@"MyTripsToLocalExpList"]) {
        LocalDetailViewController *vc = (LocalDetailViewController *)segue.destinationViewController;

        vc.expType = trip[@"type"];
        vc.experience_id_string = [trip[@"experience_id"] stringValue];
    }
}

- (UIImage *)fetchImage:(NSString *) imageURL {
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@%@", [URLConfig imageServiceURLString], imageURL];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
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
