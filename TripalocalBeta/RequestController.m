//
//  RequestController.m
//  
//
//  Created by Ye He on 3/07/2015.
//
//

#import "RequestController.h"

@implementation RequestController

- (UIImage *) fetchImage:(NSString *) token :(NSString *) imageURL {
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@%@", NSLocalizedString(imageServiceURL, nil), imageURL];
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

- (void) fetchProfileAndCache:(NSString *) token {
    NSURL *url = [NSURL URLWithString:NSLocalizedString(myprofileServiceURL, nil)];
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
            NSString *imageURL = [result objectForKey:@"image"];
            UIImage *image = [self fetchImage:token :imageURL];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:lastName forKey:@"user_last_name"];
            [userDefaults setObject:firstName forKey:@"user_first_name"];
            [userDefaults setObject:email forKey:@"user_email"];
            [userDefaults setObject:bio forKey:@"user_bio"];
            [userDefaults setObject:phoneNumber forKey:@"user_phone_number"];
            NSMutableArray *wishList = [[NSMutableArray alloc] init];
            [userDefaults setObject:wishList forKey:@"wish_list"];
            
            [userDefaults setObject:UIImagePNGRepresentation(image) forKey:@"user_image"];
            NSString *hostName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
            [userDefaults setObject:hostName forKey:@"host_name"];
            [userDefaults synchronize];
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
