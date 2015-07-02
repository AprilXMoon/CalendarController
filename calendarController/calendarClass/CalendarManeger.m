//
//  CalendarManeger.m
//  CalenderController
//
//  Created by April Lee on 2015/7/1.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import "CalendarManeger.h"

static CalendarManeger *shareCalendarManeger = nil;

@interface CalendarManeger()

@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) NSCalendar *calendar;

@end


@implementation CalendarManeger

+ (CalendarManeger *)shareCalendarManeger
{
    static dispatch_once_t one_token;
    
    dispatch_once(&one_token, ^{
        shareCalendarManeger = [[CalendarManeger alloc] init];
    });
    
    return shareCalendarManeger;
}

- (id)init
{
    if (self = [super init]) {
        
        self.store = [[EKEventStore alloc] init];
        [self requestCalendarAccess];
        
        self.calendar = [NSCalendar currentCalendar];
    }
    
    return self;
}

- (void)requestCalendarAccess
{
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        
        if (granted) {
            NSLog(@"User allow.");
        } else{
            NSLog(@"User don't allow.");
        }
        
    }];
}

- (EKEventStore *)getEventStore
{
    return _store;
}


//Fetch events
- (NSArray *)fetchAllEventsFromCalendar
{
    //Create the start date components
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.day = -1;
    NSDate *oneDayAgo = [self.calendar dateByAddingComponents:oneDayAgoComponents toDate:[NSDate date] options:0];
    
    //Create the end date components
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = -1;
    NSDate *oneYearFromNow  = [self.calendar dateByAddingComponents:oneYearFromNowComponents toDate:[NSDate date] options:0];
    
    //Create the predicate from the event store's instance method
    NSPredicate *predicate = [self.store predicateForEventsWithStartDate:oneDayAgo endDate:oneYearFromNow calendars:nil];
    
    //Fetch all events that match the predicate
    NSArray *events = [self.store eventsMatchingPredicate:predicate];
    
    return events;
}

//Insert events
- (void)insertNewEventToCalendar
{
    EKEvent *newEvent = [EKEvent eventWithEventStore:self.store];

    newEvent.calendar = self.store.defaultCalendarForNewEvents;
    newEvent.title = @"test";
    newEvent.location = @"Green's Home";
    newEvent.notes = @"This is test event";
    newEvent.startDate = [NSDate date];
    newEvent.endDate = [NSDate dateWithTimeIntervalSince1970:[newEvent.startDate timeIntervalSince1970] + 3600];
    newEvent.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Taipei"];
    
    NSError *error;
    
    BOOL action = [self.store saveEvent:newEvent span:EKSpanThisEvent commit:YES error:&error];
    
    if (action) {
        NSLog(@"save event success:eId:%@", newEvent.eventIdentifier);
    } else {
        NSLog(@"save event failure, error:%@", error);
    }
}

- (void)insertNewEventToCalendarWithData:(NSDictionary *)userEventData
{
    EKEvent *newEvent = [self createNewEventWithData:userEventData];
    NSError *error;
    
    BOOL action = [self.store saveEvent:newEvent span:EKSpanThisEvent commit:YES error:&error];
    
    if (action) {
        NSLog(@"save event success:eID:%@", newEvent.eventIdentifier);
    } else {
        NSLog(@"save event failure, error:%@", error);
    }
}

- (EKEvent *)createNewEventWithData:(NSDictionary *)userEventData
{
    NSString *title = [userEventData objectForKey:@"title"];
    NSString *location = [userEventData objectForKey:@"location"];
    NSString *notes = [userEventData objectForKey:@"notes"];
    
    NSDate *startDate = [userEventData objectForKey:@"startDate"];
    NSDate *endDate = [userEventData objectForKey:@"endDate"];
    
    EKEvent *newEvent = [EKEvent eventWithEventStore:self.store];
    newEvent.calendar = self.store.defaultCalendarForNewEvents;
    
    if(title){
        newEvent.title = title;
    }
    
    if (location) {
        newEvent.location = location;
    }
    
    if (notes) {
        newEvent.notes = notes;
    }
    
    if (startDate) {
        newEvent.startDate =  startDate;
    }
    
    if (endDate) {
        newEvent.endDate = endDate;
    }
    
    return newEvent;
}


@end
