//
//  ChatDetailViewController.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatDetailViewController : UIViewController
@property (nonatomic, weak) NSMutableArray *messageListFrom;
@property (nonatomic, weak) NSMutableArray *messageListTo;
@property (nonatomic, weak) NSMutableArray *timeListFrom;
@property (nonatomic, weak) NSMutableArray *timeListTo;
@property (weak, nonatomic) IBOutlet UITextView *textField;

@end
