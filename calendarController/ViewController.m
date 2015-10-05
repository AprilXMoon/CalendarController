//
//  ViewController.m
//  CalenderController
//
//  Created by April Lee on 2015/7/1.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import "ViewController.h"
#import "CalendarManeger.h"
#import <EventKitUI/EventKitUI.h>
#import "editViewController.h"

@interface ViewController ()  <EKEventEditViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *EventUIButton;
@property (weak, nonatomic) IBOutlet UIButton *EventAPIButton;
@property (weak, nonatomic) IBOutlet UIButton *CustomUIButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Calender";
    
    [CalendarManeger shareCalendarManeger];
    [self setButtonAppearance];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setButtonAppearance
{
    self.EventAPIButton.layer.cornerRadius = 5.0;
    self.EventAPIButton.layer.borderWidth = 1.0;
    self.EventAPIButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.EventUIButton.layer.cornerRadius = 5.0;
    self.EventUIButton.layer.borderWidth = 1.0;
    self.EventUIButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.CustomUIButton.layer.cornerRadius = 5.0;
    self.CustomUIButton.layer.borderWidth = 1.0;
    self.CustomUIButton.layer.borderColor = [UIColor grayColor].CGColor;
}


#pragma mark - Button Action

- (IBAction)insertNewEventUseEventUI:(id)sender {
  
    EKEventEditViewController *editController = [[EKEventEditViewController alloc] init];
    editController.eventStore = [[CalendarManeger shareCalendarManeger] getEventStore];
    editController.editViewDelegate = self;
    
    [self presentViewController:editController animated:YES completion:nil];
}

- (IBAction)insertNewEventUseEventAPI:(id)sender{
    
    NSDictionary *newEventData = [self createNewEventData];
    
    [[CalendarManeger shareCalendarManeger] insertNewEventToCalendarWithData:newEventData];
}

- (IBAction)insertNewEventUseCustomUI:(id)sender {
    
    editViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editViewController"];
    
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - createNewEvent

- (NSDictionary *)createNewEventData
{
    NSDate *startDate = [self convertDateStringToNSDate:@"2015-08-06 18:00"];
    NSDate *endDate = [self convertDateStringToNSDate:@"2015-08-06 20:00"];
    
    NSMutableDictionary *newEventData = [[NSMutableDictionary alloc] init];
    
    [newEventData setObject:@"Dinner" forKey:@"title"];
    [newEventData setObject:@"Toy's House" forKey:@"location"];
    [newEventData setObject:@"with firends." forKey:@"notes"];
    
    [newEventData setObject:startDate forKey:@"startDate"];
    [newEventData setObject:endDate forKey:@"endDate"];
    
    return newEventData;
}

#pragma mark - converDate method

- (NSDate *)convertDateStringToNSDate:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    NSDate *date = [dateFormatter dateFromString:dateString];
    
    return date;
}

#pragma mark - EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
