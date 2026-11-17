//
//  BlockEraseAccessParams.h
//  SymbolRfidSdk
//
//  Created by Kakarlapudi, Prudhvi on 11/08/26.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RfidSdkDefs.h"
/**
 * Parameters for Block-Erase Access Operation, mirroring the Android SDK's BlockEraseAccessParams.
 */
@interface zt_BlockEraseAccessParams : NSObject
@property (nonatomic, assign) SRFID_MEMORYBANK memoryBank;
@property (nonatomic, assign) long accessPassword;
@property (nonatomic, assign) int offset;
@property (nonatomic, assign) int count;

@end
