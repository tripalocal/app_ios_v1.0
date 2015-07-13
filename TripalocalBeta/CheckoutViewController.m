//
//  CheckoutViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "CheckoutViewController.h"
#import "InstantBookingTableViewCell.h"

@interface CheckoutViewController (){
    NSMutableArray *guestPickerData;
    NSMutableArray *datePickerData;
    NSMutableArray *timePickerData;
    NSMutableDictionary *wholePickerData;
    NSMutableArray *dynamicTimeArray;
    NSMutableArray *timeArray;
    NSMutableArray *instantDateArray;
    NSMutableArray *instantTimeArray;
    BOOL isInstant;
    NSString *selectedTimeString;
    NSString *selectedDateString;
    NSString *selectedGuestString;
}



@end

@implementation CheckoutViewController

//


//- (void)updatePriceLabels {
//    self.unitPriceLabel.text = [self.unitPrice stringValue];
//    self.totalPriceLabel.text = [self.totalPrice stringValue];
//}



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
    _instantTable.dataSource = self;
    _instantTable.delegate = self;
    [_instantTable allowsSelection];
    [_instantTable setAllowsSelection:YES];
    
    //Initialize guest data
    guestPickerData = [[NSMutableArray alloc]init];
    datePickerData = [[NSMutableArray alloc]init];
    timePickerData = [[NSMutableArray alloc]init];
    wholePickerData = [[NSMutableDictionary alloc]init];
    timeArray = [[NSMutableArray alloc]init];
    instantDateArray = [[NSMutableArray alloc]init];
    instantTimeArray = [[NSMutableArray alloc]init];
    
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
        
        isInstant = [[currentDic objectForKey:@"instant_booking"]boolValue];
        if(isInstant){
            [instantDateArray addObject:currentDateString];
            [instantTimeArray addObject:currentTimeString];
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
    // todo: default value not equal to picker view
    _unitPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD x %@ pp",_fixPriceString,selectedGuestString];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.unitPrice = [f numberFromString:_fixPriceString];
    self.guestNumber = [selectedGuestString intValue];
    self.totalPrice =@([self.unitPrice floatValue]* self.guestNumber);
    _totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD",[self.totalPrice stringValue]];
    _totalPriceLabel.textColor = [UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f];
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
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        self.unitPrice = [f numberFromString:_fixPriceString];
        
        self.guestNumber = [selectedGuestString intValue];
        self.totalPrice =@([self.unitPrice floatValue] * self.guestNumber);
        
        self.unitPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD x %@ pp",_fixPriceString, selectedGuestString];

        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setPositiveFormat:@"0.##"];
        self.totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD", [fmt stringFromNumber: self.totalPrice]];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(instantTimeArray.count == 0)
    {
        _instantTable.hidden = YES;
    }
    return instantTimeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"instantCell";
    InstantBookingTableViewCell *cell = (InstantBookingTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];;
    if(!cell){
        cell=[[InstantBookingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(instantTimeArray.count == 0){
        cell.tempView.hidden = YES;
        cell.instantDateLabel.text = @"No instant booking available";
        cell.instantTimeLabel.text = @"";
    }
    else{
        cell.tempView.hidden = NO;
        cell.instantDateLabel.text = [instantDateArray objectAtIndex:indexPath.row];
        cell.instantTimeLabel.text = [instantTimeArray objectAtIndex:indexPath.row];
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.tempImage.image = [UIImage imageNamed:@"flash.png"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"TABLE SELECTED");
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showPaymentOption"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PaymentOptionViewController *controller = (PaymentOptionViewController *)navController.topViewController;
        
        controller.coupon = self.couponField.text;
        controller.expId = _exp_ID_string ;
        controller.guestNumber = self.guestNumber;
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"HH:mm";
        
        NSDate *date = [dateFormatter dateFromString:selectedDateString];
        NSDate *startTime = [timeFormatter dateFromString:selectedTimeString];
        NSTimeInterval secondsIntHours = [self.durationString integerValue] * 60 * 60;
        NSDate *endTime = [startTime dateByAddingTimeInterval: secondsIntHours];
        NSString *endTimeString = [timeFormatter stringFromDate:endTime];

        // output format
        dateFormatter.dateFormat = @"yyyy/MM/dd";
        
        controller.date = [dateFormatter stringFromDate:date];
        controller.timePeriod = [NSString stringWithFormat:@"%@-%@", selectedTimeString, endTimeString];

        controller.unitPrice = self.unitPrice;
        controller.totalPrice = self.totalPrice;
//        controller.coupon = self
    }
}


@end
