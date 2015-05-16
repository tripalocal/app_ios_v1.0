//
//  AppDelegate.m
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"home_s.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.image = [[UIImage imageNamed:@"home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.title = nil;
    
    tabBarItem2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"search_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem2.image = [[UIImage imageNamed:@"search.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem2.title =nil;
    
    tabBarItem3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"mytrip_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.image = [[UIImage imageNamed:@"mytrip.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.title = nil;
    
    tabBarItem4.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem4.selectedImage = [[UIImage imageNamed:@"myprofile_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem4.image = [[UIImage imageNamed:@"myprofile.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem4.title = nil;
    
    
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

@end
