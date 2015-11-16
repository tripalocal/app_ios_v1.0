//
//  SMChatDelegate.h
//  TripalocalBeta
//
//  Created by 嵩薛 on 13/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMChatDelegate <NSObject>

-(void)newPeopleOnline:(NSString *)userName;
-(void)peopleWentOffline:(NSString *)userName;
-(void)didDisconnect;

@end
