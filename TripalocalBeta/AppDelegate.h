//
//  AppDelegate.h
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPP.h"
#import "SMChatDelegate.h"
#import "SMMessageDelegate.h"


@class ChatOverviewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    ChatOverviewController *viewController;
    
    XMPPStream *xmppStream;
    
    NSString *password;
    BOOL isOpen;

}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet ChatOverviewController *viewController;
@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, assign) NSObject <SMChatDelegate> *chatDelegate;
@property (nonatomic, assign) NSObject <SMMessageDelegate> *messageDelegate;

-(BOOL)connect;
-(void)disconnect;
-(BOOL)isConnected;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

