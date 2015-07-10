//
//  RequestController.h
//  
//
//  Created by Ye He on 3/07/2015.
//
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@interface RequestController : UIViewController

- (void)fetchProfileAndCache: (NSString*)token;

@end
