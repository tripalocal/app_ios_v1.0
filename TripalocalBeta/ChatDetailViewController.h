//
//  ChatDetailViewController.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>
#import "SMMessageDelegate.h"
#import "AppDelegate.h"

@interface ChatDetailViewController : UIViewController<SMMessageDelegate>{
    UITextField *textField;
    UITableView *detailTableView;
    NSString *message;
    NSMutableArray *messageListFrom;
    NSMutableArray *messageListTo;
    NSMutableArray *timeListFrom;
    NSMutableArray *timeListTo;

}

@property (weak, nonatomic) IBOutlet UIView *sendBarView;
@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (nonatomic,retain) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIButton *sendButton;
@property (nonatomic,retain) IBOutlet UITableView *detailTableView;
@property (nonatomic,strong) NSString *chatWithUser;
- (IBAction)sendMessage:(id)sender;
- (id) initWithUser:(NSString *) userName;





@end
