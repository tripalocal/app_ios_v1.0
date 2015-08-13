//
//  ChatDetailViewController.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatDetailViewController : UIViewController{
    UITextField *textField;
    UITableView *detailTableView;
    NSString *message;
    NSMutableArray *messageListFrom;
    NSMutableArray *messageListTo;
    NSMutableArray *timeListFrom;
    NSMutableArray *timeListTo;
}

@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
@property (nonatomic,retain) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIButton *sendButton;
@property (nonatomic,retain) IBOutlet UITableView *detailTableView;
- (IBAction)sendMessage:(id)sender;





@end
