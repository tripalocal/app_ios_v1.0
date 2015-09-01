//
//  Message.h
//  
//
//  Created by 嵩薛 on 1/09/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSNumber * local_id;
@property (nonatomic, retain) NSNumber * receiver_id;
@property (nonatomic, retain) NSNumber * sender_id;
@property (nonatomic, retain) NSNumber * global_id;
@property (nonatomic, retain) NSString * message_content;
@property (nonatomic, retain) NSString * message_time;

@end
