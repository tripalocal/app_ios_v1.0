//
//  ChatDetailViewController.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SMMessageDelegate.h"
#import "AppDelegate.h"

@interface ChatDetailViewController : UIViewController<SMMessageDelegate, UITableViewDelegate, UITableViewDataSource>{
    UITextField *textField;
    UITableView *tableview;
    NSString *messageContent;
    NSMutableArray *messageListFrom;
    NSMutableArray *messageListTo;
    NSMutableArray *timeListFrom;
    NSMutableArray *timeListTo;

}

@property (weak, nonatomic) IBOutlet UIView *sendBarView;
@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (nonatomic,retain) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIButton *sendButton;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSString *chatWithUser;
- (IBAction)sendMessage:(id)sender;
@property (strong) NSMutableArray *allMessage;
@property (strong) UIImage *userImage;
@property (strong) NSString *otherUserImageURL;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
