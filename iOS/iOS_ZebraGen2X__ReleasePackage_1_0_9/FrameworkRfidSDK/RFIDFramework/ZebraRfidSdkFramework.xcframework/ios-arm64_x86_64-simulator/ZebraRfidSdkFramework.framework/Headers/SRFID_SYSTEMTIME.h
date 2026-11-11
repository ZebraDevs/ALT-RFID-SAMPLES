//
//  SRFID_SYSTEMTIME.h
//  ZebraRfidSdkFramework
//
//  Created by Rajapaksha, Chamika on 2026-08-03.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRFID_SYSTEMTIME : NSObject

@property (nonatomic, assign) short year;
@property (nonatomic, assign) short month;
@property (nonatomic, assign) short dayOfWeek;
@property (nonatomic, assign) short day;
@property (nonatomic, assign) short hour;
@property (nonatomic, assign) short minute;
@property (nonatomic, assign) short second;
@property (nonatomic, assign) short milliseconds;

- (void)populateWithCurrentTime;
- (NSString*)convertTimeToString;
- (NSString*)convertTimeToDate;

@end
