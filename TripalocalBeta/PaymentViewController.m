//
//  PaymentViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 29/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()
@property (strong, nonatomic) IBOutlet UILabel *unitPriceField;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceField;
@property (strong, nonatomic) IBOutlet UITextField *cardNumberField;
@property (strong, nonatomic) IBOutlet UITextField *ccvField;
@property (strong, nonatomic) IBOutlet UITextField *monthField;
@property (strong, nonatomic) IBOutlet UITextField *yearField;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation PaymentViewController
- (IBAction)inputFiledChanged:(id)sender {
    if (self.cardNumberField.text && self.monthField.text && self.yearField && self.ccvField && self.cardNumberField.text.length > 0 && self.monthField.text.length > 0 && self.yearField.text.length > 0 && self.ccvField.text.length > 0) {
        [self.confirmButton setEnabled:YES];
    } else {
        [self.confirmButton setEnabled:NO];
    }
}

- (void)postPaymentInfo {
    
}

- (IBAction)confirmAndPay:(id)sender {
    NSLog(@"sfasdaf");
    [self postPaymentInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.confirmButton setEnabled:YES];
    self.cardNumberField.delegate = self;
    self.monthField.delegate = self;
    self.yearField.delegate = self;
    self.ccvField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 1;
    
    if (textField == self.cardNumberField) {
        maxLength = 16;
    } else if (textField == self.monthField) {
        maxLength = 2;
    } else if (textField == self.yearField) {
        maxLength = 4;
    } else if (textField == self.ccvField) {
        maxLength = 3;
    }
    
    if (range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= maxLength;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 5;
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
