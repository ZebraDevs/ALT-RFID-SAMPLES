//
//  LockAccessParams.h
//  SymbolRfidSdk
//
//  Created by Kakarlapudi, Prudhvi on 11/08/26.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RfidSdkDefs.h"

/**
 * Enumeration for the memory bank to be locked.
 */
typedef NS_ENUM(NSInteger, ZtLockDataField) {
    ZtLockDataFieldKillPassword,
    ZtLockDataFieldAccessPassword,
    ZtLockDataFieldEpcMemory,
    ZtLockDataFieldTidMemory,
    ZtLockDataFieldUserMemory
};

@interface zt_LockAccessParams : NSObject
@property (nonatomic, assign) long accessPassword;
- (instancetype)init;

/**
 * Sets the lock privilege for a specific memory bank (data field).
 * @param lockDataField The memory bank (e.g., EPC, User Memory) to apply the lock to.
 * @param lockPrivilege The type of lock to apply, using the SDK's native SRFID_ACCESSPERMISSION enum.
 */
- (void)setLockPrivilege:(ZtLockDataField)lockDataField withPrivilege:(SRFID_ACCESSPERMISSION)lockPrivilege;

/**
 * Retrieves the currently set lock privilege for a specific memory bank.
 * @param lockDataField The memory bank to query.
 * @return The currently configured lock privilege for that bank, or a special value (-1) if no privilege is set.
 */
- (SRFID_ACCESSPERMISSION)getLockPrivilegeForField:(ZtLockDataField)lockDataField;

@end
