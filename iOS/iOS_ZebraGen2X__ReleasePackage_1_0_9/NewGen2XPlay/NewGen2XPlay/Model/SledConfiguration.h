//
//  SledConfiguration.h
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 01/04/26.
//

#import <Foundation/Foundation.h>
#import <ZebraRfidSdkFramework/RfidStartTriggerConfig.h>
#import <ZebraRfidSdkFramework/RfidStopTriggerConfig.h>

/* trigger settings  */
#define ZT_TRIGGER_MIN                                      0
#define ZT_TRIGGER_MAX                                      4294967295
#define ZT_TRIGGER_EMPTY_FIELD                              -1

#define ZT_START_TRIGGER_PERIODIC_DEFAULT                   10000
#define ZT_START_TRIGGER_HANDHELD_DEFAULT                   SRFID_TRIGGERTYPE_PRESS
#define ZT_STOP_TRIGGER_DURATION_DEFAULT                    10000
#define ZT_STOP_TRIGGER_TAG_OBSERVATION_DEFAULT             100
#define ZT_STOP_TRIGGER_ATTEMPTS_DEFAULT                    10
#define ZT_STOP_TRIGGER_TIMEOUT_DEFAULT                     10000
#define ZT_STOP_TRIGGER_HADHELD_DEFAULT                     SRFID_TRIGGERTYPE_RELEASE

#define ZT_SLED_CFG_TRIGGER_START_IMMEDIATE                    0
#define ZT_SLED_CFG_TRIGGER_START_HANDHELD                     1
#define ZT_SLED_CFG_TRIGGER_START_PERIODIC                     2
#define ZT_SLED_CFG_TRIGGER_START_COUNT                        3

#define ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE                     0
#define ZT_SLED_CFG_TRIGGER_STOP_HANDHELD                      1
#define ZT_SLED_CFG_TRIGGER_STOP_DURATION                      2
#define ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION               3
#define ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS                    4
#define ZT_SLED_CFG_TRIGGER_STOP_COUNT                         5

@interface SledConfiguration : NSObject
{
}

#pragma mark - triggers
@property (nonatomic, readonly) NSMutableArray *triggerStartOptions;
@property (nonatomic, readonly) NSMutableArray *triggerStopOptions;

@property (nonatomic) int currentStartTriggerOption;
@property (nonatomic) SRFID_TRIGGERTYPE currentStartTriggerType;
@property (nonatomic) long long currentStartDelay;

@property (nonatomic) int currentStopTriggerOption;
@property (nonatomic) SRFID_TRIGGERTYPE currentStopTriggerType;
@property (nonatomic) long long currentStopTagCount;
@property (nonatomic) long long currentStopInventoryCount;
@property (nonatomic) long long currentStopTimeout;

- (void)setupInitialConfiguration;
- (void)setStartTriggerOptionWithConfig:(srfidStartTriggerConfig *)config;
- (void)setStopTriggerOptionWithConfig:(srfidStopTriggerConfig *)config;
- (srfidStartTriggerConfig *)getStartTriggerConfig;
- (srfidStopTriggerConfig *)getStopTriggerConfig;
- (BOOL)isStartTriggerRepeatMonitoring;
- (BOOL)isStartTriggerPeriodic;
- (BOOL)isStartTriggerImmediate;
- (BOOL)isStartTriggerHandheld;
- (BOOL)isStopTriggerHandheld;
- (BOOL)isStopTriggerImmediate;

@end
