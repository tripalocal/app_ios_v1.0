//
//  WishLishViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 9/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "WishLishViewController.h"
#import "TLSearchViewController.h"

@interface WishLishViewController ()

@end

@implementation WishLishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSMutableArray *)fetchExpData:(NSString *) cityName {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *wishList = [userDefaults objectForKey:@"wish_list"];
    for (NSString *expID in wishList) {
        NSString *post = [NSString stringWithFormat:@"{\"experience_id\":\"%@\"}",expID];
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
            NSDictionary *exp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([httpResponse statusCode] == 200) {
                NSMutableDictionary *resultExp = [[NSMutableDictionary alloc] init];
                [resultExp setObject:[exp objectForKey:@"experience_duration"] forKey:@"duration"];
                [resultExp setObject:[exp objectForKey:@"experience_title"] forKey:@"title"];
                [resultExp setObject:[exp objectForKey:@"experience_language"] forKey:@"language"];
                [resultExp setObject:[exp objectForKey:@"experience_description"] forKey:@"description"];
                [resultExp setObject:[exp objectForKey:@"host_image"]forKey:@"host_image"];
                [resultExp setObject:[NSNumber numberWithInt:[expID intValue]]forKey:@"id"];
                [expList addObject:resultExp];
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
    }
    
    return expList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
