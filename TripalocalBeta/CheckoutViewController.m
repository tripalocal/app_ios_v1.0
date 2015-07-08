//
//  CheckoutViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "CheckoutViewController.h"

@interface CheckoutViewController (){
    NSMutableArray *guestPickerData;
}

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UITextField *hoursInput;

@end

@implementation CheckoutViewController

//


- (void)updatePriceLabels {
    self.unitPriceLabel.text = [self.unitPrice stringValue];
    self.totalPriceLabel.text = [self.totalPrice stringValue];
}



//
- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    _coverImage.image = _expImage;
    
    _guestPicker.delegate = self;
    _guestPicker.dataSource = self;
    
    //Initialize guest dat
    guestPickerData = [[NSMutableArray alloc]init];
    int i = [_minGuestNum intValue];
    int max = [_maxGuestNum intValue];
    for (; i<= max; i++) {
        NSNumber *currentIndexNumber = [NSNumber numberWithInt:i];
        [guestPickerData addObject:currentIndexNumber];
    }
}

#pragma mark - Picker View
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return guestPickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [guestPickerData[row] stringValue];
}

#pragma mark - Picker Value
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
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
        
        controller.expId = _exp_ID_string ;
        controller.guestNumber = self.guestNumber;
        controller.date = self.dateLabel.text;
        
        
//        NSDate *startTime = self.timePicker.date;
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"HH";
        
//        NSString *startHour = [format stringFromDate:startTime];
        NSTimeInterval secondsIntHours = self.hours * 60 * 60;
//        NSDate *endTime = [startTime dateByAddingTimeInterval: secondsIntHours];
//        NSString *endHour = [format stringFromDate:endTime];
        
//        controller.timePeriod = [NSString stringWithFormat:@"%@:00-%@:00", startHour, endHour];
        controller.unitPrice = self.unitPrice;
        controller.totalPrice = self.totalPrice;
    }
}


@end
