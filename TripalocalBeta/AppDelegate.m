//
//  AppDelegate.m
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Constant.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    int imageSize = 27; //REPLACE WITH YOUR IMAGE WIDTH
    
    UIImage *barBackBtnImg = [[UIImage imageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, imageSize, 0, 0)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
#if DEBUG
                                             NSLog(@"reslut = %@",resultDic);
#endif
                                             if ([self paymentSuccess:resultDic]) {
#if DEBUG
                                                 NSLog(@"Payment status = %@", @"success");
#endif
                                                 // parse complex string from alipay
                                                 NSString *resultString = [resultDic objectForKey:@"result"];
                                                 resultString = [resultString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                                 resultString = [resultString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                                                 
                                                 for (NSString *pairString in [resultString componentsSeparatedByString:@"&"]) {
                                                     NSArray *pair = [pairString componentsSeparatedByString:@"="];
                                                     
                                                     if ([pair count] == 2) {
                                                         NSString *keyString = (NSString *)[pair objectAtIndex:0];
                                                         if ([keyString containsString:@"out_trade_no"]) {
                                                             NSString *orderNumber = (NSString *)[pair objectAtIndex:1];
                                                             
                                                             NSDictionary *aDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                          orderNumber, @"orderNumber",
                                                                                          nil];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"alipayNotification" object:nil userInfo:aDictionary];
                                                         }
                                                     }
                                                 }
                                             } else {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alipay Failed"
                                                                                                 message:@"Occured an error during payment."
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:@"OK"
                                                                                       otherButtonTitles:nil];
                                                 [alert show];
                                             }
                                         }];
        
    }
    
    return YES;
}

- (BOOL)paymentSuccess:(NSDictionary *)resultDict {
    NSDictionary *resultObject = [resultDict objectForKey:@"result"];
    if ([[resultDict objectForKey:@"resultStatus"] intValue] == 9000 && resultObject) {
        if ([[resultDict objectForKey:@"success"] isEqual: @"true"]) {
            return YES;
        }
    }
    
    return NO;
}

@end
