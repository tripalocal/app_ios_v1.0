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
    NSMutableArray *datePickerData;
    NSMutableArray *timePickerData;
    NSMutableDictionary *wholePickerData;
    NSMutableArray *dynamicTimeArray;
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
    _datePicker.delegate = self;
    _datePicker.dataSource = self;
    _timePicker.delegate = self;
    _timePicker.dataSource = self;
    
    //Initialize guest data
    guestPickerData = [[NSMutableArray alloc]init];
    datePickerData = [[NSMutableArray alloc]init];
    timePickerData = [[NSMutableArray alloc]init];
    wholePickerData = [[NSMutableDictionary alloc]init];
    
    int i = [_minGuestNum intValue];
    int max = [_maxGuestNum intValue];
    for (; i<= max; i++) {
        NSNumber *currentIndexNumber = [NSNumber numberWithInt:i];
        [guestPickerData addObject:currentIndexNumber];
    }
    
    //Resolve
    int storedFlag = 0;
    int lastIndex = 0;
    
    for (int i = 0; i<_availbleDateArray.count; i++) {
        NSMutableDictionary *currentDic = [_availbleDateArray objectAtIndex:i];
        NSString *currentDateString = [currentDic objectForKey:@"date_string"];
        NSString *currentTimeString = [currentDic objectForKey:@"time_string"];
        
        if(storedFlag == 0)
        {
            [datePickerData addObject:currentDateString];
            storedFlag = 1;
            [timePickerData addObject:currentTimeString];
        }
        else if(datePickerData.count>0){
            if (![currentDateString isEqualToString:datePickerData[lastIndex]]) {
                [datePickerData addObject:currentDateString];
                [wholePickerData setValue:timePickerData forKey:datePickerData[lastIndex]];
                [timePickerData removeAllObjects];
                [timePickerData addObject:currentTimeString];
                lastIndex ++;
                storedFlag = 1;
            }
            else{
                [timePickerData addObject:currentTimeString];
            }
        }
        NSArray *array = [wholePickerData objectForKey:@"12/07/2015"];
        NSLog(@"WHOLE DATA:%lu",(unsigned long)array.count);
    }
    
    dynamicTimeArray = [wholePickerData objectForKey:[datePickerData objectAtIndex:0]];
}

#pragma mark - Picker View
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:_guestPicker]) {
        return guestPickerData.count;
    }
    
    if ([pickerView isEqual:_datePicker]) {
        return datePickerData.count;
    }
    
    if ([pickerView isEqual:_timePicker]) {
        return dynamicTimeArray.count;
    }
    
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:_guestPicker]) {
        return [guestPickerData[row] stringValue];
    }
    
    if ([pickerView isEqual:_datePicker]) {
        return datePickerData[row];
    }
    
    if ([pickerView isEqual:_timePicker]) {
        return dynamicTimeArray[row];
    }
    
    return nil;
}

#pragma mark - Picker Value
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerView isEqual:_datePicker]) {
        dynamicTimeArray = [wholePickerData objectForKey:[datePickerData objectAtIndex:row]];
        [_timePicker selectRow:0 inComponent:0 animated:YES];
        [_timePicker reloadAllComponents];
    }
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
