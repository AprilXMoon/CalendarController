//
//  editViewController.m
//  CalenderController
//
//  Created by April Lee on 2015/7/1.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import "editViewController.h"
#import "CalendarManeger.h"

@interface editViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (nonatomic) BOOL isStartDate;

@end

@implementation editViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.notesTextView.delegate = self;
    [self initialNavigateBar];
    
    [self initialDatePicker];
    
    [self initialDateTextField];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialDatePicker
{
    NSLocale *datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.locale = datelocale;
    self.datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    [self.datePicker addTarget:self action:@selector(changeDatePickerValue:) forControlEvents:UIControlEventValueChanged];
}

- (void)initialNavigateBar
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAddNewEvent)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.title = @"Edit";
}

- (void)initialDateTextField
{
    self.startDateTextField.inputView = self.datePicker;
    self.endDateTextField.inputView = self.datePicker;
    
    self.startDateTextField.delegate = self;
    self.endDateTextField.delegate = self;
    
    [self settingStartEndDate];
}

- (void)settingStartEndDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *date = [NSDate date];
    NSDate *endDate = [date dateByAddingTimeInterval:60*60];
    
    NSString *startDateString = [dateFormatter stringFromDate:date];
    NSString *endDateString = [dateFormatter stringFromDate:endDate];
    
    self.startDateTextField.text = startDateString;
    self.endDateTextField.text = endDateString;
}


#pragma mark - Events method

- (void)doneAddNewEvent
{
    NSLog(@"doneAddNewEvent");
    
    if ([self checkTitleIsEmpty]) {
        [self showAlertViewWithTitle:@"No Title" Message:@"Please enter the event title."];
        
    } else if ([self checkEndDate]) {
        [self showAlertViewWithTitle:@"Date Fail" Message:@"The start date must be before the end date."];
        
    } else {
        [self insertEventToCalendar];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)insertEventToCalendar
{
    NSDictionary *newEvent = [self createNewEventData];
    [[CalendarManeger shareCalendarManeger] insertNewEventToCalendarWithData:newEvent];
}

- (NSDictionary *)createNewEventData
{
    NSDate *startDate = [self convertDateStringToNSDate:self.startDateTextField.text];
    NSDate *endDate = [self convertDateStringToNSDate:self.endDateTextField.text];
    
    if (!startDate) {
        startDate = [NSDate date];
    }
    
    if (!endDate) {
        endDate = [[NSDate alloc] initWithTimeIntervalSince1970:[startDate timeIntervalSince1970] + 3600];
    }
    
    NSMutableDictionary *newEventData = [[NSMutableDictionary alloc] init];
    
    [newEventData setObject:self.titleTextField.text forKey:@"title"];
    [newEventData setObject:self.locationTextField.text forKey:@"location"];
    [newEventData setObject:self.notesTextView.text forKey:@"notes"];
    
    [newEventData setObject:startDate forKey:@"startDate"];
    [newEventData setObject:endDate forKey:@"endDate"];
    
    return newEventData;
}

#pragma mark - textView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.notesTextView.text rangeOfString:@"Xcode 7 UITextView fail."].location != NSNotFound) {
        self.notesTextView.text = @"";
        self.notesTextView.textColor = [UIColor blackColor];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.notesTextView.text.length == 0) {
        self.notesTextView.textColor = [UIColor lightGrayColor];
        self.notesTextView.text = @"Notes";
        [self.notesTextView resignFirstResponder];
    }
}


#pragma mark - textField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.startDateTextField) {
        self.isStartDate = YES;
        
        NSDate *currentDate = [self convertDateStringToNSDate:self.startDateTextField.text];
        [self.datePicker setDate:currentDate];
    } else {
        
        NSDate *currentEndDate = [self convertDateStringToNSDate:self.endDateTextField.text];
        [self.datePicker setDate:currentEndDate];
    }
    
    textField.textColor = [UIColor redColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.startDateTextField) {
        self.isStartDate = NO;
    }
    
    textField.textColor = [UIColor blackColor];
}

#pragma mark - check method

- (BOOL)checkTitleIsEmpty
{
    NSString *EventTitle = self.titleTextField.text;
    if (EventTitle.length == 0) {
        return true;
    }
    return false;
}

- (BOOL)checkEndDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    NSDate *startDate = [dateFormatter dateFromString:self.startDateTextField.text];
    NSDate *endDate = [dateFormatter dateFromString:self.endDateTextField.text];
    
    if ([endDate compare:startDate] == NSOrderedAscending) {
        self.endDateTextField.textColor = [UIColor redColor];
        return true;
    }
    
    return false;
}

#pragma mark - Date Picker

- (void)changeDatePickerValue:(id)sender
{
    NSString *date = [self converNSDateToString:self.datePicker.date];
    
    if (self.isStartDate) {
        self.startDateTextField.text = date;
    } else {
        self.endDateTextField.text = date;
    }
}

#pragma mark - converDate

- (NSDate *)convertDateStringToNSDate:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return date;
}

- (NSString *)converNSDateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
    
    return dateString;
}

#pragma mark - AlertView

- (void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message
{
    UIAlertView *AlertMsg = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [AlertMsg show];
}

@end
