//
//  MultidayTableViewCell2.h
//  
//
//  Created by Ye He on 20/10/2015.
//
//

#import <UIKit/UIKit.h>

@interface MultidayTableViewCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *nDayTripLabel;
@property (weak, nonatomic) IBOutlet UILabel *localtionLabel;
@property (weak, nonatomic) IBOutlet UILabel *oneNightPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *allNightPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *onNightCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *allNightCheckButton;

@end
