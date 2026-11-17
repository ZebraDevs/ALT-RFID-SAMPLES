//
//  WriteAccessParams.h
//  SymbolRfidSdk
//
//  Created by Kakarlapudi, Prudhvi on 23/07/26.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RfidSdkDefs.h"

/**
 * Parameters for a tag write operation.

 *   memoryBank     — memory bank to write to (EPC / TID / USER / reserved)
 *   offset         — word offset within the bank (0-based)
 *   data           — hex string of words to write (e.g. @"AABB0011")
 *   accessPassword — access password (0 if tag is not password protected)
 *   doBlockWrite   — when YES uses block-write command (faster on supporting tags)
 */
@interface zt_WriteAccessParams : NSObject

@property (nonatomic, assign) SRFID_MEMORYBANK memoryBank;
@property (nonatomic, assign) short            offset;
@property (nonatomic, copy)   NSString        *data;
@property (nonatomic, assign) long             accessPassword;
@property (nonatomic, assign) BOOL             doBlockWrite;
@property (nonatomic, assign) int writeRetries; 

@end
