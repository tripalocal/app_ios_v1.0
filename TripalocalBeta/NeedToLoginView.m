//
//  NeedToLoginView.m
//  TripalocalBeta
//
//  Created by Ye He on 10/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "NeedToLoginView.h"

@implementation NeedToLoginView

-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"NeedToLoginView" owner:self options:nil];
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:5.0f];
    // The following is to make sure content view, extends out all the way to fill whatever our view size is even as our view's size is changed by autolayout
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview: self.contentView];
    
    [[self class] addEdgeConstraint:NSLayoutAttributeLeft superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeRight superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeTop superview:self subview:self.contentView];
    [[self class] addEdgeConstraint:NSLayoutAttributeBottom superview:self subview:self.contentView];
    
}

+(void)addEdgeConstraint:(NSLayoutAttribute)edge superview:(UIView *)superview subview:(UIView *)subview {
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                          attribute:edge
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:superview
                                                          attribute:edge
                                                         multiplier:1
                                                           constant:0]];
}

- (IBAction)login:(id)sender {
    [self.delegate loginClicked];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
