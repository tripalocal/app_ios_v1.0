//
//  ChatDetailViewController.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatDetailViewController : UIViewController
@property (nonatomic, weak) IBOutlet NSMutableArray *messageListFrom;
@property (nonatomic, weak) IBOutlet NSMutableArray *messageListTo;
@property (nonatomic, weak) IBOutlet NSMutableArray *timeListFrom;
@property (nonatomic, weak) IBOutlet NSMutableArray *timeListTo;

@end
