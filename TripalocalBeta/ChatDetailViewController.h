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
    UITextView *textField;
    UITableView *tableview;
    NSString *messageContent;
    NSMutableArray *messageListFrom;
    NSMutableArray *messageListTo;
    CGFloat cellTextWidth;
    CGFloat cellHeightExceptText;
    long long currentFlag;
    NSMutableArray *updateMessage;
    NSDictionary *updateDict;
    __unsafe_unretained NSObject <SMChatDelegate> *_chatDelegate;
    __unsafe_unretained NSObject <SMMessageDelegate> *_messageDelegate;

}
//@property (strong) NSMutableArray *messageListFrom;
//@property (strong) NSMutableArray *messageListTo;
@property (nonatomic, assign) id _messageDelegate;
@property (weak, nonatomic) IBOutlet UIView *sendBarView;
@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (nonatomic,retain) IBOutlet UITextView *textField;
@property (nonatomic,weak) IBOutlet UIButton *sendButton;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSString *chatWithUser;
- (IBAction)sendMessage:(id)sender;
@property (strong) NSMutableArray *allMessage;
@property (strong) UIImage *userImage;
@property (strong) NSString *otherUserImageURL;
@property (nonatomic, strong) UITableViewCell *prototypeCell;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BOOL shouldScrollToLastRow;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
