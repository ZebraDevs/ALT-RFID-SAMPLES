//
//  SRFID_ERROR_INFO.h
//  ZebraRfidSdkFramework
//
//  Created by Rajapaksha, Chamika on 2026-08-03.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRFID_SYSTEMTIME.h"

@interface SRFID_ERROR_INFO : NSObject

@property (nonatomic, strong) NSString *vendorMessage;
@property (nonatomic, strong) NSString *statusDesc;
@property (nonatomic, assign) int rfidStatusCode;
@property (nonatomic, assign) int enumRfidStatusCode;
@property (nonatomic, strong) SRFID_SYSTEMTIME *errorTimeStamp;

- (instancetype)init;

@end
