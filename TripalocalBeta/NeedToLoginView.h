//
//  NeedToLoginView.h
//  TripalocalBeta
//
//  Created by Ye He on 10/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NeedToLoginViewDelegate <NSObject>

- (void)loginClicked;

@end

@interface NeedToLoginView : UIView
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UILabel *needToLoginTitle;
@property (strong, nonatomic) IBOutlet UILabel *needToLoginContent;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) id <NeedToLoginViewDelegate> delegate;
@end
