//
//  ReadAccessParams.h
//  SymbolRfidSdk
//
//  Created by Kakarlapudi, Prudhvi on 23/07/26.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RfidSdkDefs.h"

/**
 * Parameters for a tag read operation.
 *   memoryBank     — memory bank to read from (EPC / TID / USER / reserved)
 *   offset         — word offset within the bank (0-based)
 *   count          — number of words to read; 0 means read all available words
 *   accessPassword — access password (0 if tag is not password protected)
 */
@interface zt_ReadAccessParams : NSObject

@property (nonatomic, assign) SRFID_MEMORYBANK memoryBank;
@property (nonatomic, assign) short            offset;
@property (nonatomic, assign) short            count;
@property (nonatomic, assign) long             accessPassword;

@end
