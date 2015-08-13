//
//  SMMessageDelegate.h
//  TripalocalBeta
//
//  Created by 嵩薛 on 13/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMMessageDelegate <NSObject>

-(void)newMessageReceived:(NSDictionary *)messageContent;

@end