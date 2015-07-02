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

    
    self.startDateTextField.inputView = self.datePicker;
    self.endDateTextField.inputView = self.datePicker;
    
    self.startDateTextField.delegate = self;
    self.endDateTextField.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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


#pragma mark - Events method

- (void)doneAddNewEvent
{
    NSLog(@"doneAddNewEvent");
    
    [self insertEventToCalendar];
    
    [self.navigationController popViewControllerAnimated:YES];
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
    if ([self.notesTextView.text isEqualToString:@"Notes"]) {
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
    }
    
    NSString *nowTime = [self converNSDateToString:self.datePicker.date];
    textField.text = nowTime;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.startDateTextField) {
        self.isStartDate = NO;
    } else {
        [self checkEndDate];
    }
}

- (void)checkEndDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    NSDate *startDate = [dateFormatter dateFromString:self.startDateTextField.text];
    NSDate *endDate = [dateFormatter dateFromString:self.endDateTextField.text];
    
    if ([endDate compare:startDate] == NSOrderedAscending) {
        self.endDateTextField.textColor = [UIColor redColor];
    }
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

@end
