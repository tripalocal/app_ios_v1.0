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
    NSMutableArray *timeArray;
    
    NSString *selectedTimeString;
    NSString *selectedDateString;
    NSString *selectedGuestString;
}



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
    timeArray = [[NSMutableArray alloc]init];
    
    int i = [_minGuestNum intValue];
    int max = [_maxGuestNum intValue];
    for (; i<= max; i++) {
        NSNumber *currentIndexNumber = [NSNumber numberWithInt:i];
        [guestPickerData addObject:currentIndexNumber];
    }
    
    //Resolve
    int storedFlag = 0;
    int lastIndex = 0;
    [timeArray addObject:timePickerData];
    for (int i = 0; i<_availbleDateArray.count; i++) {
        NSMutableDictionary *currentDic = [_availbleDateArray objectAtIndex:i];
        NSString *currentDateString = [currentDic objectForKey:@"date_string"];
        NSString *currentTimeString = [currentDic objectForKey:@"time_string"];
        
        if(storedFlag == 0)
        {
            [datePickerData addObject:currentDateString];
            [timeArray[0] addObject:currentTimeString];
            storedFlag = 1;
        }
        else if(datePickerData.count>0){
            if (![currentDateString isEqualToString:datePickerData[lastIndex]]) {
                [datePickerData addObject:currentDateString];
                [wholePickerData setValue:timeArray[lastIndex] forKey:datePickerData[lastIndex]];
                lastIndex ++;
                storedFlag = 1;
                NSMutableArray *newTimePickerData = [[NSMutableArray alloc]init];
                [timeArray addObject:newTimePickerData];
                [timeArray[lastIndex] addObject:currentTimeString];
            }
            else{
                [timeArray[lastIndex] addObject:currentTimeString];
            }
        }
        
    }
    [wholePickerData setValue:timeArray[lastIndex] forKey:datePickerData[lastIndex]];
    dynamicTimeArray = [wholePickerData objectForKey:[datePickerData objectAtIndex:0]];
    
    [_timePicker selectRow:3 inComponent:0 animated:NO];
    [_datePicker selectRow:3 inComponent:0 animated:NO];
    [_guestPicker selectRow:3 inComponent:0 animated:NO];

    selectedDateString = datePickerData[0];
    selectedTimeString = dynamicTimeArray[0];
    selectedGuestString = guestPickerData[0];
    
    _durationLangLabel.text = [_durationString stringByAppendingFormat:@"hrs • %@", _languageString];
    _expTitleLabel.text = _expTitleString;
    _unitPriceLabel.text = [@"$" stringByAppendingFormat:@"%@ AUD x %@ pp",_fixPriceString,selectedGuestString];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *priceNumber = [f numberFromString:_fixPriceString];
    NSNumber *guestNumber = @([selectedGuestString intValue]);
    NSNumber *totalPriceNumber =@([priceNumber floatValue]* [guestNumber intValue]);
    _totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@",[totalPriceNumber stringValue]];
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
        [_timePicker selectRow:3 inComponent:0 animated:YES];
        [_timePicker reloadAllComponents];
        selectedDateString = datePickerData[row];

    }
    if ([pickerView isEqual:_timePicker]) {
        selectedTimeString = dynamicTimeArray[row];

    }
    if ([pickerView isEqual:_guestPicker]) {
        selectedGuestString = guestPickerData[row];
        _unitPriceLabel.text = [@"$" stringByAppendingFormat:@"%@ AUD x %@ pp",_fixPriceString,selectedGuestString];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *priceNumber = [f numberFromString:_fixPriceString];
        NSNumber *guestNumber = @([selectedGuestString intValue]);
        NSNumber *totalPriceNumber =@([priceNumber floatValue]* [guestNumber intValue]);
        _totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@",[totalPriceNumber stringValue]];
    }
    
    NSLog(@"Selected Date:%@ Time:%@ Guest:%@",selectedDateString,selectedTimeString,selectedGuestString);
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
