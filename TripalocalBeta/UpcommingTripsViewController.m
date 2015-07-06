//
//  UpcommingViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "UpcommingTripsViewController.h"
#import "MyTripTableViewCell.h"
#import "TLDetailViewController.h"
#import "Constant.h"

@interface UpcommingTripsViewController ()

@end

@implementation UpcommingTripsViewController {
    NSArray *myTrips;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    myTrips = [[NSArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        [self fetchMyTrips:token];
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
            myTrips = [NSJSONSerialization JSONObjectWithData:data
                                                      options:0
                                                        error:nil];
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
    
    NSDictionary *trip = [myTrips objectAtIndex:indexPath.row];
//    {
//        "datetime": "2015-07-08T22:00:00+10:00",
//        "experience_title": "Hidden Contemporary Art Galleries",
//        "guest_number": 1,
//        "host_phone_number": "0424563037",
//        "experience_id": 20,
//        "status": "paid",
//        "meetup_spot": "We will start the walk at Flinder St Station, and depends on time we can finish in the city or end in Fitzroy. I can also take you back to your hotel or wherever that's convenient for you.",
//        "host_image": "hosts/8/host8_1_YeokW.jpg",
//        "host_name": "Yeok W."
//    }
    NSString *imageURL = [trip objectForKey:@"host_image"];
    // get image and background image
    NSString *datetimeSring = [trip objectForKey:@"datetime"];
    
    cell.dateLabel.text = @"blahs";
    cell.timeLabel.text = @"ahs";
    cell.hostNameLabel.text = [trip objectForKey:@"host_name"];
    cell.guestNumberLabel.text = [[trip objectForKey:@"guest_number"] stringValue];
    cell.experienceTitle.text = [trip objectForKey:@"experience_title"];
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

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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

@end
