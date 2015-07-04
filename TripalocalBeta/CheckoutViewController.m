//
//  CheckoutViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "CheckoutViewController.h"

@interface CheckoutViewController ()
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (strong, nonatomic) IBOutlet UITextField *guestInput;
@property (strong, nonatomic) IBOutlet UITextField *hoursInput;

@end

@implementation CheckoutViewController
- (IBAction)datePickerChanged:(id)sender {
    NSDate *date = self.datePicker.date;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy/MM/dd";
    self.dateLabel.text = [format stringFromDate:date];
}

- (IBAction)hoursChanged:(id)sender {
    self.hours = self.hoursInput.text.integerValue;
}

- (IBAction)timePickerChanged:(id)sender {
    NSDate *date = self.timePicker.date;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH";
    NSString *hours = [format stringFromDate:date];
    self.timeLabel.text = [NSString stringWithFormat:@"%@:00",hours];
}

- (IBAction)guestValueChange:(id)sender {
    self.guestNumber = self.guestInput.text.integerValue;
    //todo:
    self.unitPrice = [NSNumber numberWithFloat:0.5];
    NSNumber *totalPrice = [NSNumber numberWithFloat: self.guestNumber * [self.unitPrice floatValue]];
    self.totalPrice = totalPrice;
    [self updatePriceLabels];
}

- (void)updatePriceLabels {
    self.unitPriceLabel.text = [self.unitPrice stringValue];
    self.totalPriceLabel.text = [self.totalPrice stringValue];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showPaymentOption"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PaymentOptionViewController *controller = (PaymentOptionViewController *)navController.topViewController;
        
        // hard code expID. should pass here from detail page.
        controller.expId = @"2";
        controller.guestNumber = self.guestNumber;
        controller.date = self.dateLabel.text;
        
        
        NSDate *startTime = self.timePicker.date;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"HH";
        
        NSString *startHour = [format stringFromDate:startTime];
        NSTimeInterval secondsIntHours = self.hours * 60 * 60;
        NSDate *endTime = [startTime dateByAddingTimeInterval: secondsIntHours];
        NSString *endHour = [format stringFromDate:endTime];
        
        controller.timePeriod = [NSString stringWithFormat:@"%@:00-%@:00", startHour, endHour];
        controller.unitPrice = self.unitPrice;
        controller.totalPrice = self.totalPrice;
    }
}


@end
