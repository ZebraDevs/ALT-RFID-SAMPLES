//
//  ZebraServiceEngine.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-24.
//

#import <Foundation/Foundation.h>
#import <ZebraRfidSdkFramework/RfidSdkApiDelegate.h>
#import <ZebraRfidSdkFramework/RfidSdkApi.h>
#import <ZebraRfidSdkFramework/RfidSdkFactory.h>
#import <ZebraRfidSdkFramework/RfidTagData.h>
#import <ZebraRfidSdkFramework/RfidReaderInfo.h>
#import <ZebraRfidSdkFramework/RfidOperEndSummaryEvent.h>
#import <ZebraRfidSdkFramework/RfidDatabaseEvent.h>
#import <ZebraRfidSdkFramework/RfidTemperatureEvent.h>
#import <ZebraRfidSdkFramework/RfidPowerEvent.h>
#import "ActiveReader.h"
#import "SledConfiguration.h"

@class ZebraServiceEngine;
@protocol ReaderEventDelegate <NSObject>
- (void)didDeviceAppear:(ZebraServiceEngine *)zebraServiceEngine didFinishDeviceAppear:(srfidReaderInfo *)availableReader;
- (void)didConnected:(ZebraServiceEngine *)zebraServiceEngine didConnectedDevice:(srfidReaderInfo *)availableReader;
- (void)didDisconnect:(ZebraServiceEngine *)zebraServiceEngine didDisconnectedDevice:(NSString *)readerId;
- (void)didDisappear:(ZebraServiceEngine *)zebraServiceEngine didDeviceDisappear:(NSString *)readerId;
@end

@protocol TagDataEventDelegate <NSObject>
- (void)eventTagDataRecived:(ZebraServiceEngine *)zebraServiceEngine didFinishEventTagDataRecived:(srfidTagData *)tagData;
@end

@protocol zt_IZebraServiceEngineTriggerEventDelegate <NSObject>
- (BOOL)onNewTriggerEvent:(BOOL)pressed typeRFID:(BOOL)isRFID;
@end

@interface ZebraServiceEngine : NSObject <srfidISdkApiDelegate> {
    id <srfidISdkApi> apiInstance;
    NSMutableArray *readerListArray;
    NSMutableArray<srfidReaderInfo *> *readerListInfoArray;
    int availableReaderID;
    int connectedReaderID;
    srfidReportConfig *reportConfiguration;
    NSString *readerDetail;
    
    BOOL statusOfFastID;
    
}

@property (nonatomic, weak) id<ReaderEventDelegate> delegateReaderEvent;
@property (nonatomic, weak) id<TagDataEventDelegate> delegateTagDataEvent;

/// Singleton accessor
+ (instancetype)sharedInstance;

/// SDK setup
- (void)initializeRfidSdkWithAppSettings;
- (NSString*)getSDKVersion;
- (int)getConnectedReaderId;
- (void)setConnectedReaderId:(int)connectedId;
- (void)subcribeForEvent;

- (void)connect:(int)reader_id;
- (void)disconnect:(int)reader_id;

- (srfidSingulationConfig*)getSingulationConfiguration;
-(SRFID_RESULT)setSingulationConfiguration:(srfidSingulationConfig*)singulationConfig;

- (void)establishAsciiConnection;

-(int)getAvailableReaderID;

-(NSMutableArray*)getPrefilters;
-(SRFID_RESULT)setPrefilters:(NSMutableArray*)prefilterArray;
- (SRFID_RESULT)deleteAllPrefilter:(NSString**)statusMessage;

-(SRFID_RESULT) DeleteAllPrefilters_New;

-(void)resetPrefilters;

/// Readers
- (NSArray<srfidReaderInfo *>  *)getAvialbleReaders;

- (SRFID_RESULT) sdkStartInventory;

- (SRFID_RESULT) sdkStopInventory;

- (SRFID_RESULT)protectTag:(NSString*)tagID withTagData:(srfidTagData **)tagData   withPassword:(NSString*)password status:(NSString **)statusMessage;

- (SRFID_RESULT)unprotectTag:(NSString*)tagID
                   withTagData:(srfidTagData **)tagData
                withPassword:(NSString*)password
                      status:(NSString **)statusMessage;

- (SRFID_RESULT)enableVisibilityTag:(NSString*)password status:(NSString **)statusMessage;

- (SRFID_RESULT)disableVisibilityTag:(NSString*)password status:(NSString **)statusMessage;

- (SRFID_RESULT)enableTagFocus:(BOOL)enableTagFocus status:(NSString **)statusMessage;
- (SRFID_RESULT)setSingulationConfigurationTagFoucus: (srfidSingulationConfig*)singulationConfiguration status:(NSString **)statusMessage;

-(SRFID_RESULT)enableTagQuiet:(BOOL)status meesage:(NSString**)statusMessage;

-(SRFID_RESULT)customTagQuiet:(NSMutableArray *) tagQuietMaskArray enumTarget:(SRFID_SELECTTARGET)target action:(SRFID_SELECTACTION) action meesage:(NSString**)statusMessage;

- (SRFID_RESULT)readTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withLength:(short)length withPassword:(long)password aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)writeTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withData:(NSString*)data withPassword:(long)password doBlockWrite:(BOOL)blockWrite aStatusMessage:(NSString**)statusMessage;

- (void)restorePrefiltersForTagQuet;
-(SRFID_RESULT)setPreFilterForTagQuiet:(NSMutableArray *)prefilters status:(NSString **)statusMessage;

- (SRFID_RESULT) configureFastID:(BOOL)enableFastID status:(NSString **)statusMessage;

-(void)setFastIDEnableStatue:(BOOL)status;
-(BOOL)getFastIDEnableStatue;

#pragma mark - data
- (zt_ActiveReader *)activeReader;
- (SledConfiguration *)sledConfiguration;

#pragma mark - observers management
- (void)addTriggerEventDelegate:(id<zt_IZebraServiceEngineTriggerEventDelegate>)delegate;
- (void)removeTriggerEventDelegate:(id<zt_IZebraServiceEngineTriggerEventDelegate>)delegate;

#pragma mark - Inventory Protocol

- (SRFID_RESULT)getReaderInventoryProtocol:(SRFID_ENUM_INVENTORY_PROTOCOL*)protocol
                           aStatusMessage:(NSString**)statusMessage;

- (SRFID_RESULT)setReaderInventoryProtocol:(SRFID_ENUM_INVENTORY_PROTOCOL)protocol aStatusMessage:(NSString**)statusMessage;

@end


