//
//  ActiveReader.h
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 01/04/26.
//
#import <Foundation/Foundation.h>

@interface zt_ActiveReader : NSObject

- (void)setIsActive:(BOOL)isActive withID:(NSNumber *)identiefier;
- (BOOL)isActive;
- (int)getReaderID;
- (void)setBatchModeStatus:(BOOL)status;
- (BOOL)getBatchModeStatus;
- (void)setBatchModeRepeat:(BOOL)status;
- (BOOL)getBatchModeRepeat;

@end
