//
//  RequestController.m
//  
//
//  Created by Ye He on 3/07/2015.
//
//

#import "RequestController.h"

@implementation RequestController

- (void) fetchProfileAndCache:(NSString *) token {
    NSURL *url = [NSURL URLWithString:myprofileServiceTestServerURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];
        //            {
        //                "last_name": "He",
        //                "image": "",
        //                "id": 455,
        //                "first_name": "Ye",
        //                "phone_number": "",
        //                "bio": "",
        //                "rate": null,
        //                "email": "yehe01@gmail.com"
        //            }
        
        if ([httpResponse statusCode] == 200) {
            NSString *lastName = [result objectForKey:@"last_name"];
            NSString *firstName = [result objectForKey:@"first_name"];
            NSString *email = [result objectForKey:@"email"];
            NSString *bio = [result objectForKey:@"bio"];
            NSString *phoneNumber = [result objectForKey:@"phone_number"];
            NSString *encodedString = [result objectForKey:@"phone_number"];
            
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
            UIImage *image = [UIImage imageWithData:decodedData];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:lastName forKey:@"user_last_name"];
            [userDefaults setObject:firstName forKey:@"user_first_name"];
            [userDefaults setObject:email forKey:@"user_email"];
            [userDefaults setObject:bio forKey:@"user_bio"];
            [userDefaults setObject:phoneNumber forKey:@"user_phone_number"];
            [userDefaults setObject:image forKey:@"user_image"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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

@end
