//
//  SledConfiguration.m
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 01/04/26.
//

#import "ZebraServiceEngine.h"
#import "SledConfiguration.h"

/* trigger */
#define ZT_SLED_CFG_NAME_TRIGGER_START_IMMEDIATE               @"Immediate"
#define ZT_SLED_CFG_NAME_TRIGGER_START_PERIODIC                @"Periodic"
#define ZT_SLED_CFG_NAME_TRIGGER_START_HANDHELD                @"Handheld"

#define ZT_SLED_CFG_NAME_TRIGGER_STOP_IMMEDIATE                @"Immediate"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_DURATION                 @"Duration"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_TAG_OBSERVATION          @"Tag Observation"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_N_ATTEMPTS               @"N Attempts"
#define ZT_SLED_CFG_NAME_TRIGGER_STOP_HANDHELD                 @"Handheld"

@implementation SledConfiguration

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _triggerStartOptions = [[NSMutableArray alloc] init];
        _triggerStopOptions = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)setupInitialConfiguration
{
    for (int i = 0; i < ZT_SLED_CFG_TRIGGER_START_COUNT; i++)
    {
        [_triggerStartOptions addObject:@""];
    }
    
    [_triggerStartOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_START_HANDHELD withObject:ZT_SLED_CFG_NAME_TRIGGER_START_HANDHELD];
    [_triggerStartOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_START_IMMEDIATE withObject:ZT_SLED_CFG_NAME_TRIGGER_START_IMMEDIATE];
    [_triggerStartOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_START_PERIODIC withObject:ZT_SLED_CFG_NAME_TRIGGER_START_PERIODIC];
    
    for (int i = 0; i < ZT_SLED_CFG_TRIGGER_STOP_COUNT; i++)
    {
        [_triggerStopOptions addObject:@""];
    }
    
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_DURATION withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_DURATION];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_HANDHELD withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_HANDHELD];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_IMMEDIATE];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_N_ATTEMPTS];
    [_triggerStopOptions replaceObjectAtIndex:ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION withObject:ZT_SLED_CFG_NAME_TRIGGER_STOP_TAG_OBSERVATION];
    
}
#pragma mark - trigger settings
- (void)setStartTriggerOptionWithConfig:(srfidStartTriggerConfig *)config
{
    BOOL onHandheldTrigger = [config getStartOnHandheldTrigger];
    _currentStartTriggerType = [config getTriggerType];
    BOOL repeat = [config getRepeatMonitoring];
    
    if (onHandheldTrigger)
    {
        _currentStartTriggerOption = ZT_SLED_CFG_TRIGGER_START_HANDHELD;
        _currentStartDelay = 0;
    }
    else if (repeat)
    {
        _currentStartTriggerOption = ZT_SLED_CFG_TRIGGER_START_PERIODIC;
        _currentStartDelay = [config getStartDelay];
    }
    else
    {
        _currentStartTriggerOption = ZT_SLED_CFG_TRIGGER_START_IMMEDIATE;
        _currentStartDelay = 0;
        
    }
}

- (void)setStopTriggerOptionWithConfig:(srfidStopTriggerConfig *)config
{
    BOOL onHanheldTrigger = [config getStopOnHandheldTrigger];
    _currentStopTriggerType = [config getTriggerType];
    BOOL onTagCount = [config getStopOnTagCount];
    BOOL onTimeout = [config getStopOnTimeout];
    BOOL onInventoryCount = [config getStopOnInventoryCount];
    _currentStopInventoryCount =[config getStopInventoryCount];
    
    int timeout = 0;
    if (YES == onTimeout)
    {
        timeout = [config getStopTimeout];
    }
    
    if (YES == onHanheldTrigger)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_HANDHELD;
        _currentStopTagCount = 0;
        _currentStopTimeout = timeout;
        _currentStopInventoryCount = 0;
    }
    else if (YES == onTagCount)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION;
        _currentStopTagCount = [config getStopTagCount];
        _currentStopTimeout = timeout;
        _currentStopInventoryCount = 0;
    }
    else if (YES == onInventoryCount)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS;
        _currentStopTagCount = 0;
        _currentStopTimeout = timeout;
        _currentStopInventoryCount =[config getStopInventoryCount];
    }
    else if (YES == onTimeout)
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_DURATION;
        _currentStopTagCount = 0;
        _currentStopTimeout = timeout;
        _currentStopInventoryCount = 0;
    }
    else
    {
        _currentStopTriggerOption = ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE;
        _currentStopTagCount = 0;
        _currentStopTimeout = 0;
        _currentStopInventoryCount = 0;
    }
}

- (srfidStartTriggerConfig *)getStartTriggerConfig
{
    srfidStartTriggerConfig *config = [[srfidStartTriggerConfig alloc] init];
    [config setTriggerType:_currentStartTriggerType];
    
    switch (_currentStartTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_START_IMMEDIATE:
            [config setStartOnHandheldTrigger:NO];
            [config setRepeatMonitoring:NO];
            [config setStartDelay:0];
            break;
            
        case ZT_SLED_CFG_TRIGGER_START_PERIODIC:
            [config setStartOnHandheldTrigger:NO];
            [config setRepeatMonitoring:YES];
            [config setStartDelay:(unsigned int)_currentStartDelay];
            break;
            
        case ZT_SLED_CFG_TRIGGER_START_HANDHELD:
            [config setStartOnHandheldTrigger:YES];
            [config setRepeatMonitoring:YES]; /* nrv364 */
            [config setStartDelay:0];
            break;
        default:
            break;
    }
    return config;
}

- (srfidStopTriggerConfig *)getStopTriggerConfig
{
    srfidStopTriggerConfig *config = [[srfidStopTriggerConfig alloc] init];
    [config setTriggerType:_currentStopTriggerType];
    
    
    switch (_currentStopTriggerOption) {
        case ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:NO];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:0];
            [config setStopTimout:0];
            [config setStopInventoryCount:0];
            break;
        case ZT_SLED_CFG_TRIGGER_STOP_HANDHELD:
            [config setStopOnHandheldTrigger:YES];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:0];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:0];
            
            break;
        case ZT_SLED_CFG_TRIGGER_STOP_DURATION:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:0];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:0];
            
            break;
        case ZT_SLED_CFG_TRIGGER_STOP_TAG_OBSERVATION:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:YES];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:NO];
            [config setStopTagCount:(unsigned int)_currentStopTagCount];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:0];
            break;
            
        case ZT_SLED_CFG_TRIGGER_STOP_N_ATTEMPTS:
            [config setStopOnHandheldTrigger:NO];
            [config setStopOnTagCount:NO];
            [config setStopOnTimeout:YES];
            [config setStopOnInventoryCount:YES];
            [config setStopTagCount:0];
            [config setStopTimout:(unsigned int)_currentStopTimeout];
            [config setStopInventoryCount:(unsigned int)_currentStopInventoryCount];
            break;
            
        default:
            break;
    }
    return config;
}

- (BOOL)isStartTriggerRepeatMonitoring;
{
    return (ZT_SLED_CFG_TRIGGER_START_IMMEDIATE != _currentStartTriggerOption);
}

- (BOOL)isStartTriggerPeriodic
{
    return (ZT_SLED_CFG_TRIGGER_START_PERIODIC == _currentStartTriggerOption);
}

- (BOOL)isStartTriggerImmediate
{
    return (ZT_SLED_CFG_TRIGGER_START_IMMEDIATE == _currentStartTriggerOption);
}

- (BOOL)isStartTriggerHandheld
{
    return (ZT_SLED_CFG_TRIGGER_START_HANDHELD == _currentStartTriggerOption);
}

- (BOOL)isStopTriggerHandheld
{
    return (ZT_SLED_CFG_TRIGGER_STOP_HANDHELD == _currentStopTriggerOption);
}

- (BOOL)isStopTriggerImmediate
{
    return (ZT_SLED_CFG_TRIGGER_STOP_IMMEDIATE == _currentStopTriggerOption);
}

@end
