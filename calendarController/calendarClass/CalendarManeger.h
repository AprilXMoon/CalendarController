//
//  CalendarManeger.h
//  CalenderController
//
//  Created by April Lee on 2015/7/1.
//  Copyright (c) 2015年 april. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface CalendarManeger : NSObject

+ (CalendarManeger *)shareCalendarManeger;

- (EKEventStore *)getEventStore;

- (NSArray *)fetchAllEventsFromCalendar;

- (void)insertNewEventToCalendar;
- (void)insertNewEventToCalendarWithData:(NSDictionary *)userEventData;

@end
