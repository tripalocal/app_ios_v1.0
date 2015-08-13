//
//  AppDelegate.h
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XMPP.h"
#import "SMChatDelegate.h"
#import "SMMessageDelegate.h"

@class ChatOverviewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    ChatOverviewController *viewController;
    
    XMPPStream *xmppStream;
    
    NSString *password;
    BOOL isOpen;
    __weak NSObject <SMChatDelegate> *_chatDelegate;
    __weak NSObject <SMMessageDelegate> *_messageDelegate;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet ChatOverviewController *viewController;
@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, assign) id _chatDelegate;
@property (nonatomic, assign) id _messageDelegate;

-(BOOL)connect;
-(void)disconnect;


@end

