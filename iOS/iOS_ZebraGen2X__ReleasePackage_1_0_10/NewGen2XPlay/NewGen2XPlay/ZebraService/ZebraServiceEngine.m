//
//  ZebraServiceEngine.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-24.
//

#import "ZebraServiceEngine.h"
#import <UIKit/UIKit.h>

#define ZT_MAX_RETRY                          2
@interface ZebraServiceEngine() {
    NSMutableArray *m_TriggerEventDelegates;
    zt_ActiveReader *m_ActiveReader;
    SledConfiguration *m_SledConfiguration;
    SledConfiguration *m_TemporarySledConfigurationCopy;
}
@end

@implementation ZebraServiceEngine

+ (instancetype)sharedInstance
{
    static ZebraServiceEngine *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ZebraServiceEngine alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Optional: initialize immediately here if you always want it ready.
        // Otherwise call initializeRfidSdkWithAppSettings explicitly from app startup.
        // [self initializeRfidSdkWithAppSettings];
        readerListInfoArray = [[NSMutableArray alloc] init];
        m_TriggerEventDelegates = [[NSMutableArray alloc] init];
        m_SledConfiguration = [[SledConfiguration alloc] init];
        [m_SledConfiguration setupInitialConfiguration];
        
        m_TemporarySledConfigurationCopy = [[SledConfiguration alloc] init];
        [m_TemporarySledConfigurationCopy setupInitialConfiguration];
        availableReaderID = -1;
        connectedReaderID = -1;
    }
    return self;
}

- (void)initializeRfidSdkWithAppSettings
{
    apiInstance = [srfidSdkFactory createRfidSdkApiInstance];
    [apiInstance srfidSetDelegate:self];
    [self subcribeForEvent];
}

#pragma mark - Get SDK Version
- (NSString*)getSDKVersion
{
    NSLog(@"Symbol RFID SDK version: %@", [apiInstance srfidGetSdkVersion]);
    return [apiInstance srfidGetSdkVersion];
}

#pragma mark - Events
- (void)subcribeForEvent
{
    int notifications_mask_reader_connection = SRFID_EVENT_READER_APPEARANCE |
                                              SRFID_EVENT_READER_DISAPPEARANCE |
                                              SRFID_EVENT_SESSION_ESTABLISHMENT |
                                              SRFID_EVENT_SESSION_TERMINATION;

    [apiInstance srfidSubsribeForEvents:notifications_mask_reader_connection];

    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_BATTERY |
                                         SRFID_EVENT_MASK_TRIGGER)];

    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_READ |
                                         SRFID_EVENT_MASK_STATUS |
                                         SRFID_EVENT_MASK_STATUS_OPERENDSUMMARY)];

    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_TEMPERATURE |
                                         SRFID_EVENT_MASK_POWER |
                                         SRFID_EVENT_MASK_DATABASE)];

    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_PROXIMITY)];
    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_TRIGGER)];
    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_BATTERY)];
    [apiInstance srfidSubsribeForEvents:(SRFID_EVENT_MASK_MULTI_PROXIMITY)];
    [apiInstance srfidEnableAvailableReadersDetection:true];
}

#pragma mark - Get Available Readers
- (NSArray<srfidReaderInfo *>  *)getAvialbleReaders
{
    return readerListInfoArray;
}

-(int)getAvailableReaderID{

    return availableReaderID;
}

#pragma mark - Connect Reader
- (void)connect:(int)reader_id
{
    if (apiInstance != nil)
    {
        SRFID_RESULT conn_result = [apiInstance srfidEstablishCommunicationSession:reader_id];
        

        if (SRFID_RESULT_SUCCESS != conn_result)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageBox:@"Connection failed"];
            });
        }else {
            [self showMessageBox:@"Reader Connected"];
            if (SRFID_RESULT_SUCCESS == conn_result)
            {
                conn_result = [self getStartTriggerConfiguration:nil];
                
                /* to be sure, that device has valid settings, we rewrite them */
                
                if (SRFID_RESULT_SUCCESS == conn_result)
                {
                    conn_result = [self setStartTriggerConfiguration:nil];
                }
            }
            
            if (SRFID_RESULT_SUCCESS == conn_result)
            {
                conn_result = [self getStopTriggerConfiguration:nil];
                
                /* to be sure, that device has valid settings, we rewrite them */
                
                if (SRFID_RESULT_SUCCESS == conn_result)
                {
                    conn_result = [self setStopTriggerConfiguration:nil];
                }
                
            }
            
        }
    }
}

#pragma mark - Disconnect
- (void)disconnect:(int)reader_id
{
    if (apiInstance != nil)
    {
        [apiInstance srfidTerminateCommunicationSession:reader_id];
    }
}

#pragma mark - data

- (zt_ActiveReader *)activeReader
{
    return m_ActiveReader;
}

- (SledConfiguration *)sledConfiguration
{
    return m_SledConfiguration;
}

#pragma mark - Message Box
- (void)showMessageBox:(NSString*)message
{
    //Ensure we're always on the main thread for UI operations
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showMessageBox:message];
        });
        return;
    }
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"ZebraGen2X"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
        //Handle cancel button here
    }];
    
    [alert addAction:cancelButton];
    
    UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [topVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Get Singulation Configuration
- (srfidSingulationConfig*)getSingulationConfiguration
{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    srfidSingulationConfig *singulationCofiguration = [[srfidSingulationConfig alloc]init];
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidGetSingulationConfiguration:availableReaderID aSingulationConfig:&singulationCofiguration aStatusMessage:nil];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"srfidGetSingulationConfiguration Success");
        NSLog(@"singulationCofiguration %@", singulationCofiguration);

    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"srfidGetSingulationConfiguration Error");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return singulationCofiguration;
}

#pragma mark - Set Singulation Configuration
-(SRFID_RESULT)setSingulationConfiguration:(srfidSingulationConfig*)singulationConfig{
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidSetSingulationConfiguration:availableReaderID aSingulationConfig:singulationConfig aStatusMessage:nil];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"srfidSetSingulationConfiguration Success");
        

    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"srfidSetSingulationConfiguration Error");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return srfid_result;
}

#pragma mark - Establish ASCII Connection
- (void)establishAsciiConnection {
    SRFID_RESULT _conn_res = [apiInstance srfidEstablishAsciiConnection:availableReaderID];
    
    if (_conn_res == SRFID_RESULT_SUCCESS)
    {
        /* success -> we may continue */
        //[self postAsciiConnectionActions];
    }
    else if (_conn_res == SRFID_RESULT_WRONG_ASCII_PASSWORD)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"ZebraGen2X"
                                     message:@"Failed to establish connection with RFID reader"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            //Handle cancel button here
        }];
        
        [alert addAction:cancelButton];
        
        UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [topVC presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        /* unknown error -> show message box */
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"ZebraGen2X"
                                     message:@"Failed to establish connection with RFID reader"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            //Handle cancel button here
        }];
        
        [alert addAction:cancelButton];
        
        UIViewController * topVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [topVC presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Get Prefilters
-(NSMutableArray*)getPrefilters{
    NSMutableArray *prefilters = [[NSMutableArray alloc] init];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidGetPreFilters:availableReaderID aPreFilters:&prefilters aStatusMessage:nil];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"srfidGetPreFilters Success");
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"srfidGetPreFilters Error");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return prefilters;
}

#pragma mark - Set Prefilters
-(SRFID_RESULT)setPrefilters:(NSMutableArray*)prefilterArray{
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidSetPreFilters:availableReaderID aPreFilters:prefilterArray aStatusMessage:nil];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"srfidGetPreFilters Success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        NSLog(@"srfidGetPreFilters Error");
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    
    return srfid_result;
}

-(SRFID_RESULT)setPreFilterForTagQuiet:(NSMutableArray *)prefilters status:(NSString **)statusMessage;
{
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidSetPreFilters:availableReaderID aPreFilters:prefilters aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"setPreFilterForTagQuiet Success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        srfid_result = [self getPrefiltersforTagQuiet:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getPrefiltersforTagQuiet:(NSString **)statusMessage
{
    NSMutableArray *prefilters = [[NSMutableArray alloc] init];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidGetPreFilters:availableReaderID aPreFilters:&prefilters aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        NSLog(@"getPrefiltersforTagQuiet Success");
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
       
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

#pragma mark - Reset Prefilters
-(void)resetPrefilters{
    NSMutableArray *prefilters = [[NSMutableArray alloc] init];
    
    NSString *statusMessage = @"";
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidSetPreFilters:availableReaderID aPreFilters:prefilters aStatusMessage:&statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        //srfid_result = [self getPrefilters:&statusMessage];
        NSLog(@"Prefilter reset SUCCESS");
    }
   else
    {
        NSLog(@"Prefilter reset Failed");
       // srfid_result = [self getPrefilters:&statusMessage];
    }
}

#pragma mark - Delete All Prefilters
- (SRFID_RESULT)deleteAllPrefilter:(NSString**)statusMessage
{
    if (apiInstance != nil)
    {
        srfidAntennaConfiguration *antenaCofiguration = [[srfidAntennaConfiguration alloc]init];
        
        SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
        
        for(int i = 0; i < 2; i++)
        {
            srfid_result = [apiInstance srfidGetAntennaConfiguration:availableReaderID aAntennaConfiguration:&antenaCofiguration aStatusMessage:statusMessage];
            
            if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
                break;
            }
        }
        NSString *response2 = @"";
      
        return [apiInstance srfidSetDefaultConfiguration:availableReaderID  aAntennaRconfig:antenaCofiguration aSingulationControl:nil aTagStorageSettings:nil aDeleteAllPrefilters:YES aDpoEnable:YES aSetAttributes:Nil aStatusMessage:&response2];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

//-(SRFID_RESULT)deleteAllPrefilterAppEngine {
//    
//  
//    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
//    
//    NSString *status_msg = nil;
//    int readerID = [m_ActiveReader getReaderID];
//
//    srfid_result = [m_RfidSdkApi deleteAllPreFilters:readerID aStatusMessage:&status_msg];
//     if (srfid_result == SRFID_RESULT_SUCCESS) {
//         NSLog(@"deleteAllPrefilterAppEngine Success");
//     }else{
//         NSLog(@"deleteAllPrefilterAppEngine Failed");
//     }
//    return srfid_result;
//    
//}
-(SRFID_RESULT) DeleteAllPrefilters_New {
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    NSString *status_msg = nil;
    
    srfid_result = [apiInstance deleteAllPreFilters:availableReaderID aStatusMessage:&status_msg];
    
    if (srfid_result == SRFID_RESULT_SUCCESS) {
        NSLog(@"DeleteAllPrefilters_New Success");
    }else{
        NSLog(@"DeleteAllPrefilters_New Failed");
    }
    
    return srfid_result;
}


#pragma mark - Restore All Prefilters for Tag Quiet
- (void)restorePrefiltersForTagQuet{
    
    NSMutableArray *prefilters = [[NSMutableArray alloc] init];
    
    NSString *statusMessage = @"";
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidSetPreFilters:availableReaderID aPreFilters:prefilters aStatusMessage:&statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {

        NSLog(@"Tag Quiet reset SUCCESS");
    }
   else
    {
        NSLog(@"Tag Quiet reset FAILED");
       
    }
    
}



#pragma mark - Tag Protect / Un-Protect
- (SRFID_RESULT)protectTag:(NSString*)tagID withTagData:(srfidTagData **)tagData   withPassword:(NSString*)password status:(NSString **)statusMessage
{
    if (apiInstance != nil)
    {

        //return [apiInstance srfidProtectTag:availableReaderID aTagID:tagID aAccessTagData:tagData aPassword:password aStatusMessage:statusMessage];
        return [apiInstance enableTagProtection:availableReaderID tagID:tagID tagData:tagData password:password statusMessage:statusMessage ];
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)unprotectTag:(NSString*)tagID
                   withTagData:(srfidTagData **)tagData
                withPassword:(NSString*)password
                      status:(NSString **)statusMessage
{
    
    if (apiInstance != nil)
    {
    
//        return [apiInstance srfidUnprotectTag:availableReaderID
//                                        aTagID:tagID
//                                aAccessTagData:tagData
//                                     aPassword:password
//                                aStatusMessage:statusMessage];
        return [apiInstance disableTagProtection:availableReaderID tagID:tagID tagData:tagData password:password statusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

#pragma mark - Tag Enable / Disable Visibility
- (SRFID_RESULT)enableVisibilityTag:(NSString*)password status:(NSString **)statusMessage
{
    
    if (apiInstance != nil)
    {
    
//        return [apiInstance srfidEnableTagVisibility:availableReaderID
//                                            aPassword:password
//                                       aStatusMessage:statusMessage];
        return [apiInstance enableTagVisibility:availableReaderID password:password statusMessage:statusMessage];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT)disableVisibilityTag:(NSString*)password status:(NSString **)statusMessage
{
    
    if (apiInstance != nil)
    {
    
//        return [apiInstance srfidDisableTagVisibility:availableReaderID
//                                            aPassword:password
//                                       aStatusMessage:statusMessage];
        return [apiInstance disableTagVisibility:availableReaderID aPassword:password statusMessage:statusMessage];
        
    }
    
    return SRFID_RESULT_FAILURE;
}

#pragma mark - Tag Focus
- (SRFID_RESULT)enableTagFocus:(BOOL)enableTagFocus status:(NSString **)statusMessage
{
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    
//    result = [apiInstance srfidSetTagFocus:availableReaderID isTagFocusEnable:enableTagFocus aStatusMessage:statusMessage];
    result = [apiInstance setTagFocus:availableReaderID enable:enableTagFocus statusMessage:statusMessage];
    
    if (result == SRFID_RESULT_SUCCESS) {
        NSLog(@"enableTagFocus Success");
    }else {
        NSLog(@"enableTagFocus Failed");
    }
    
    return result;
}

- (SRFID_RESULT)setSingulationConfigurationTagFoucus: (srfidSingulationConfig*)singulationConfiguration status:(NSString **)statusMessage
{
 
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidSetSingulationConfiguration:availableReaderID aSingulationConfig:singulationConfiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getSingulationConfigurationTagFocus:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getSingulationConfigurationTagFocus:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getSingulationConfigurationTagFocus:(NSString **)statusMessage
{
    srfidSingulationConfig *singulationCofiguration = [[srfidSingulationConfig alloc]init] ;
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < 2; i++)
    {
        srfid_result = [apiInstance srfidGetSingulationConfiguration:availableReaderID aSingulationConfig:&singulationCofiguration aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [self setSingulationConfiguration:singulationCofiguration];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

#pragma mark - Tag Quiet
-(SRFID_RESULT)enableTagQuiet:(BOOL)status meesage:(NSString**)statusMessage {
   
   if (apiInstance != nil)
   {
       NSMutableArray<NSNumber *> *tagQuietMaskArray = [NSMutableArray array];
       [tagQuietMaskArray addObject:@(ENUM_TAGQUIET_MASK_S3B)];
       NSLog(@"Tag Quiet Mask Array: %@", tagQuietMaskArray);
       SRFID_RESULT resultTagquit = SRFID_RESULT_FAILURE;
       srfidSingulationConfig *config = [[srfidSingulationConfig alloc] init];
       
       if (status) {
           // ── QUIET ON ──
           resultTagquit = [apiInstance setTagQuiet:availableReaderID
                                             masks:tagQuietMaskArray
                                        enumTarget:SRFID_SELECTTARGET_SL
                                            action:(SRFID_SELECTACTION)SRFID_SELECTACTION_INV_A__OR__ASRT_SL
                                     statusMessage:statusMessage];
           if (resultTagquit == SRFID_RESULT_SUCCESS){
               NSLog(@"resultTagquit SUCCESS");
           }else {
               NSLog(@"resultTagquit FAILED");
           }
           
           [config setSlFlag:SRFID_SLFLAG_DEASSERTED];
           [config setSession:SRFID_SESSION_S2];
           [config setInventoryState:SRFID_INVENTORYSTATE_AB_FLIP];
           [config setTagPopulation:200]; // FIX: Set tag population
           
           SRFID_RESULT resultSigulation = SRFID_RESULT_FAILURE;
           //NSString *response2 = @"";
           resultSigulation = [self setSingulationConfiguration:config];
           if (resultSigulation == SRFID_RESULT_SUCCESS) {
               NSLog(@"SRFID_RESULT_SUCCESS SingulationConfig (quiet ON)");
           } else {
               NSLog(@"SRFID_RESULT_Fail SingulationConfig (quiet ON)");
           }
       }
       else
       {
           // ── QUIET OFF ──
           // Step 1: Deassert SL flag (move tags back from asserted to deasserted)
           resultTagquit = [apiInstance setTagQuiet:availableReaderID
                                             masks:tagQuietMaskArray
                                        enumTarget:SRFID_SELECTTARGET_SL
                                            action:(SRFID_SELECTACTION)SRFID_SELECTACTION_INV_B__OR__DSRT_SL
                                     statusMessage:statusMessage];
           
           // Step 2: Reset S3 state back to A
           resultTagquit = [apiInstance setTagQuiet:availableReaderID
                                             masks:tagQuietMaskArray
                                        enumTarget:SRFID_SELECTTARGET_S3
                                            action:(SRFID_SELECTACTION)SRFID_SELECTACTION_INV_A__OR__ASRT_SL
                                     statusMessage:statusMessage];
           
           // Restore singulation to defaults
           [config setSlFlag:SRFID_SLFLAG_ALL];
           [config setSession:SRFID_SESSION_S1];
           [config setInventoryState:SRFID_INVENTORYSTATE_A];
           [config setTagPopulation:200];
           
           SRFID_RESULT resultSigulation = SRFID_RESULT_FAILURE;
           //NSString *response2 = @"";
           resultSigulation = [self setSingulationConfiguration:config];
           if (resultSigulation == SRFID_RESULT_SUCCESS) {
               NSLog(@"SRFID_RESULT_SUCCESS SingulationConfig restored to defaults (quiet OFF)");
           } else {
               NSLog(@"SRFID_RESULT_Fail SingulationConfig restore (quiet OFF)");
           }
       }
       
       return resultTagquit;
   }
   
   return SRFID_RESULT_FAILURE;
}

#pragma mark - Custom Tag Quiet
-(SRFID_RESULT)customTagQuiet:(NSMutableArray *) tagQuietMaskArray enumTarget:(SRFID_SELECTTARGET)target action:(SRFID_SELECTACTION) action meesage:(NSString**)statusMessage{
    if (apiInstance != nil)
    {
        SRFID_RESULT resultTagquit = SRFID_RESULT_FAILURE;
        srfidSingulationConfig *config = [[srfidSingulationConfig alloc] init] ;
        
        resultTagquit = [apiInstance setTagQuiet:availableReaderID masks:tagQuietMaskArray enumTarget:target action:action statusMessage:statusMessage];
        
        SRFID_SLFLAG sl_flag = SRFID_SLFLAG_DEASSERTED;
        SRFID_SESSION session = SRFID_SESSION_S2;
        SRFID_INVENTORYSTATE inv_state = SRFID_INVENTORYSTATE_AB_FLIP;
        
        [config setSlFlag:sl_flag];
        [config setSession:session];
        [config setInventoryState:inv_state];
        
        SRFID_RESULT resultSigulation = SRFID_RESULT_FAILURE;
        NSString *response2 = @"";
        resultSigulation = [self setSingulationConfigurationTagFoucus:config status:&response2];
        if (resultSigulation == SRFID_RESULT_SUCCESS)
        {
            NSLog(@"SRFID_RESULT_SUCCESS SingulationConfig");
        }else{
            NSLog(@"SRFID_RESULT_Fail SingulationConfig");
        }
       
        return resultTagquit;
    }
    
    return SRFID_RESULT_FAILURE;
}


#pragma mark - srfidISdkApiDelegate

- (void)srfidEventBatteryNotity:(int)readerID aBatteryEvent:(srfidBatteryEvent *)batteryEvent
{
}

- (void)srfidEventCommunicationSessionEstablished:(srfidReaderInfo *)activeReader
{
    
    [self setConnectedReaderId:[activeReader getReaderID]];

    [self.delegateReaderEvent didConnected:self didConnectedDevice:activeReader];
    
    [self establishAsciiConnection];
}

- (void)srfidEventCommunicationSessionTerminated:(int)readerID
{
    [self setConnectedReaderId:-1];
    [self.delegateReaderEvent didDisconnect:self didDisconnectedDevice:[NSString stringWithFormat:@"%d", readerID]];
}

- (void)srfidEventConnectedInterfaceNotity:(int)readerID aConnectedInterfaceEvent:(sfidConnectedInterfaceEvent *)connectedInterfaceEvent
{
}

- (void)srfidEventIOTSatusNotity:(int)readerID aIOTStatusEvent:(srfidIOTStatusEvent *)iotStatusEvent
{
}

- (void)srfidEventMultiProximityNotify:(int)readerID aTagData:(srfidTagData *)tagData
{
}

- (void)srfidEventProximityNotify:(int)readerID aProximityPercent:(int)proximityPercent
{
}

- (void)srfidEventReadNotify:(int)readerID aTagData:(srfidTagData *)tagData
{
    [self.delegateTagDataEvent eventTagDataRecived:self didFinishEventTagDataRecived:tagData];
}

- (void)srfidEventReaderAppeared:(srfidReaderInfo *)availableReader
{
    availableReaderID = [availableReader getReaderID];

    // Avoid duplicates by readerID
        BOOL exists = NO;
        for (srfidReaderInfo *r in readerListInfoArray) {
            if ([r getReaderID] == [availableReader getReaderID]) {
                exists = YES;
                break;
            }
        }
        if (!exists) {
            [readerListInfoArray addObject:availableReader];
        }

        NSLog(@"available Reader Appear %@ (%d)", [availableReader getReaderName], [availableReader getReaderID]);

        if ([self.delegateReaderEvent respondsToSelector:@selector(didDeviceAppear:didFinishDeviceAppear:)]) {
            [self.delegateReaderEvent didDeviceAppear:self didFinishDeviceAppear:availableReader];
        }
}

- (void)srfidEventReaderDisappeared:(int)readerID
{

    NSUInteger idx = NSNotFound;
    for (NSUInteger i = 0; i < readerListInfoArray.count; i++) {
        srfidReaderInfo *r = readerListInfoArray[i];
        if ([r getReaderID] == readerID) {
            idx = i;
            break;
        }
    }
    if (idx != NSNotFound) {
        [readerListInfoArray removeObjectAtIndex:idx];
    }
    
    if ([self.delegateReaderEvent respondsToSelector:@selector(didDisappear:didDeviceDisappear:)]) {
        [self.delegateReaderEvent didDisappear:self didDeviceDisappear:[NSString stringWithFormat:@"%d", readerID]];
    }
}


- (void)srfidEventStatusNotify:(int)readerID aEvent:(SRFID_EVENT_STATUS)event aNotification:(id)notificationData
{
}

- (void)srfidEventTriggerNotify:(int)readerID aTriggerEvent:(SRFID_TRIGGEREVENT)triggerEvent
{
    for (id<zt_IZebraServiceEngineTriggerEventDelegate> delegate in m_TriggerEventDelegates )
    {
        if (delegate != nil && ([[[ZebraServiceEngine sharedInstance] activeReader] getBatchModeRepeat] == NO))
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (SRFID_TRIGGEREVENT_SCAN_RELEASED == triggerEvent || SRFID_TRIGGEREVENT_SCAN_PRESSED == triggerEvent){
                    [delegate onNewTriggerEvent:SRFID_TRIGGEREVENT_PRESSED == triggerEvent typeRFID:NO];
                }else{
                    [delegate onNewTriggerEvent:SRFID_TRIGGEREVENT_PRESSED == triggerEvent typeRFID:YES];
                }
            });
        }
    }
}

- (void)srfidEventWifiScan:(int)readerID wlanSCanObject:(srfidWlanScanList *)wlanScanObject
{
}


- (int)getConnectedReaderId{
    return connectedReaderID;
}
- (void)setConnectedReaderId:(int)connectedId{
    connectedReaderID = connectedId;
}

- (void)readerProblem
{
    NSLog(@"%@", @"Problem with reader connection");
    //[self showMessageBox:@"Unknown error occured while communicating with RFID reader. Please reconnect it."];
}


#pragma mark - Inventory Start/Stop
- (SRFID_RESULT) sdkStartInventory
{
    NSString *statusMessage = nil;
    if (nil != apiInstance)
    {
        srfidAccessConfig *accessConfig = [[srfidAccessConfig alloc] init];
        
        BOOL isFastIDEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"FastIDEnabled"];
        
        [accessConfig setDoSelect:YES];
        
        if(isFastIDEnabled){
            if([self getFastIDEnableStatue]){
                [accessConfig setDoSelect:YES];
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FastIDEnabled"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [accessConfig setDoSelect:NO];
                [self srfidSetReaderDefaultConfiguration];
            }
        }
       
        srfidReportConfig *config = [[srfidReportConfig alloc] init];
        srfidTagReportConfig *reportConfiguration = [self rfidGetTagReportConfiguration];
               
        [config setIncFirstSeenTime:[reportConfiguration getIncFirstSeenTime]];
        [config setIncLastSeenTime:[reportConfiguration getIncLastSeenTime]];
        [config setIncPC:[reportConfiguration getIncPC]];
        [config setIncPhase:[reportConfiguration getIncPhase]];
        [config setIncRSSI:[reportConfiguration getIncRSSI]];
        [config setIncChannelIndex:[reportConfiguration getIncChannelIdx]];
        [config setIncTagSeenCount:[reportConfiguration getIncTagSeenCount]];

        SRFID_RESULT result = [apiInstance srfidStartInventory:availableReaderID aMemoryBank:SRFID_MEMORYBANK_NONE aReportConfig:config aAccessConfig:accessConfig aStatusMessage:&statusMessage];
        
        if (result == SRFID_RESULT_SUCCESS) {
            NSLog(@" srfidStartInventory : Success");
        } else if (result == SRFID_RESULT_RESPONSE_ERROR) {
            NSLog(@"srfidStartInventory ResponseError");
        } else if (result == SRFID_RESULT_FAILURE || result == SRFID_RESULT_RESPONSE_TIMEOUT) {
            NSLog(@"srfidStartInventory reader prob");
        }

        return result;
    
    }
    return SRFID_RESULT_FAILURE;
}

- (SRFID_RESULT) sdkStopInventory
{
    NSString *statusMessage = nil;
    if (nil != apiInstance)
    {
        return [apiInstance srfidStopInventory:availableReaderID aStatusMessage:&statusMessage];
    }
    return SRFID_RESULT_FAILURE;
}

#pragma mark - Get tag report Configure
- (srfidTagReportConfig *)rfidGetTagReportConfiguration {
    NSString *statusMessage = nil;
    srfidTagReportConfig *tagReportConfig = [[srfidTagReportConfig alloc] init];

    SRFID_RESULT tagsReportConfigResult = [apiInstance srfidGetTagReportConfiguration:availableReaderID
                    aTagReportConfig:&tagReportConfig
                      aStatusMessage:&statusMessage];

    if (tagsReportConfigResult == SRFID_RESULT_SUCCESS) {
        NSLog(@"Native tagsReportConfigResult : Success");
    } else if (tagsReportConfigResult == SRFID_RESULT_RESPONSE_ERROR) {
        NSLog(@"tagsReportConfigResult ResponseError");
    } else if (tagsReportConfigResult == SRFID_RESULT_FAILURE || tagsReportConfigResult == SRFID_RESULT_RESPONSE_TIMEOUT) {
        NSLog(@"tagsReportConfigResult reader prob");
    }

    return tagReportConfig;
}


#pragma mark - Read / Write Tag
- (SRFID_RESULT)readTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withLength:(short)length withPassword:(long)password aStatusMessage:(NSString**)statusMessage
{
    if (apiInstance != nil)
    {
        return [apiInstance srfidReadTag:availableReaderID aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBankID aOffset:offset aLength:length aPassword:password aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}


- (SRFID_RESULT)writeTag:(NSString*)tagID withTagData:(srfidTagData **)tagData withMemoryBankID:(SRFID_MEMORYBANK)memoryBankID withOffset:(short)offset withData:(NSString*)data withPassword:(long)password doBlockWrite:(BOOL)blockWrite aStatusMessage:(NSString**)statusMessage
{
    if (apiInstance != nil)
    {
        return [apiInstance srfidWriteTag:availableReaderID aTagID:tagID aAccessTagData:tagData aMemoryBank:memoryBankID aOffset:offset aData:data aPassword:password aDoBlockWrite:blockWrite aStatusMessage:statusMessage];
    }
    
    return SRFID_RESULT_FAILURE;
}

#pragma mark - Configure Fast ID
- (SRFID_RESULT) configureFastID:(BOOL)enableFastID status:(NSString **)statusMessage{
    
    if (apiInstance != nil)
    {
        NSLog(@"configureFastID Success");
//        return [apiInstance configureFastID:availableReaderID enableFastID:enableFastID];
        return [apiInstance setFastID:availableReaderID enable:YES statusMessage:statusMessage];
        
    }
    
    NSLog(@"configureFastID Failure");
    return SRFID_RESULT_FAILURE;
    
}

-(void)setFastIDEnableStatue:(BOOL)status{
    statusOfFastID = status;
}

-(BOOL)getFastIDEnableStatue {
    return statusOfFastID;
}


- (void)srfidSetReaderDefaultConfiguration {
    // Log the function entry
    //[self logText:@"Inside function srfidSetReaderDefaultConfiguration"];
    // Create and configure singulation settings
    srfidSingulationConfig *singulationConfig = [[srfidSingulationConfig alloc] init];
    [singulationConfig setSession:SRFID_SESSION_S0];
    [singulationConfig setInventoryState:SRFID_INVENTORYSTATE_A];
    [singulationConfig setSlFlag:SRFID_SLFLAG_ALL];
    [singulationConfig setTagPopulation:30];
    //[self dispSingulationConfig:singulationConfig];
    // Create and configure tag report settings
    srfidTagReportConfig *tagReportConfig = [[srfidTagReportConfig alloc] init];
    [tagReportConfig setIncTagSeenCount:YES];
    [tagReportConfig setIncChannelIdx:YES];
    [tagReportConfig setIncFirstSeenTime:YES];
    [tagReportConfig setIncLastSeenTime:YES];
    [tagReportConfig setIncRSSI:YES];
    [tagReportConfig setIncPhase:YES];
    [tagReportConfig setIncPC:YES];
    // Retrieve reader capabilities
    srfidReaderCapabilitiesInfo *readerCapabilitiesInfo = [[srfidReaderCapabilitiesInfo alloc] init];
    NSString *status = nil;
    SRFID_RESULT srfidResult = [apiInstance srfidGetReaderCapabilitiesInfo:availableReaderID
                                                aReaderCapabilitiesInfo:&readerCapabilitiesInfo
                                                         aStatusMessage:&status];
    //[self logAPIResult:srfidResult apiName:@"srfidGetReaderCapabilitiesInfo"];
    // Create and configure antenna settings
    srfidAntennaConfiguration *antennaConfig = [[srfidAntennaConfiguration alloc] init];
    [antennaConfig setPower:(int16_t)[readerCapabilitiesInfo getMaxPower]];
    [antennaConfig setTari:0];
    [antennaConfig setDoSelect:NO];
    [antennaConfig setLinkProfileIdx:0];
    // Prepare attributes array
    NSMutableArray *setAttributes = [[NSMutableArray alloc] init];
    // Set default configuration
    srfidResult = [apiInstance srfidSetDefaultConfiguration:availableReaderID
                                         aAntennaRconfig:antennaConfig
                                   aSingulationControl:singulationConfig
                                 aTagStorageSettings:tagReportConfig
                                  aDeleteAllPrefilters:YES
                                           aDpoEnable:NO
                                        aSetAttributes:setAttributes
                                       aStatusMessage:&status];
    //[self logAPIResult:srfidResult apiName:@"srfidSetDefaultConfiguration"];
    // Check for errors
    if (srfidResult != SRFID_RESULT_SUCCESS) {
        //NSString *errorMessage = [NSString stringWithFormat:@"srfidSetDefaultConfiguration ***** FAILED, ErrorCode: %@, Status: %@", LOG_RESULTCODE[@(srfidResult)], status];
        //[self logText:errorMessage];
        return;
    }
}

#pragma mark - Trigger Configuration

- (SRFID_RESULT)getStartTriggerConfiguration:(NSString **)statusMessage
{
    srfidStartTriggerConfig *config = [[srfidStartTriggerConfig alloc]init];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [apiInstance srfidGetStartTriggerConfiguration:[m_ActiveReader getReaderID] aStartTriggeConfig:&config aStatusMessage:statusMessage];
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setStartTriggerOptionWithConfig:config];
        [m_TemporarySledConfigurationCopy setStartTriggerOptionWithConfig:config];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setStartTriggerOptionWithConfig:[m_SledConfiguration getStartTriggerConfig]];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setStartTriggerConfiguration:(NSString **)statusMessage
{
    srfidStartTriggerConfig *config = [m_TemporarySledConfigurationCopy getStartTriggerConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [apiInstance srfidSetStartTriggerConfiguration:[m_ActiveReader getReaderID] aStartTriggeConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getStartTriggerConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getStartTriggerConfiguration:nil];
    }
    
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)getStopTriggerConfiguration:(NSString **)statusMessage
{
    srfidStopTriggerConfig *config = [[srfidStopTriggerConfig alloc]init];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [apiInstance srfidGetStopTriggerConfiguration:[m_ActiveReader getReaderID] aStopTriggeConfig:&config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        [m_SledConfiguration setStopTriggerOptionWithConfig:config];
        [m_TemporarySledConfigurationCopy setStopTriggerOptionWithConfig:config];
        
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [m_TemporarySledConfigurationCopy setStopTriggerOptionWithConfig:[m_SledConfiguration getStopTriggerConfig]];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

- (SRFID_RESULT)setStopTriggerConfiguration:(NSString **)statusMessage
{
    srfidStopTriggerConfig *config = [m_TemporarySledConfigurationCopy getStopTriggerConfig];
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    
    for(int i = 0; i < ZT_MAX_RETRY; i++)
    {
        srfid_result = [apiInstance srfidSetStopTriggerConfiguration:[m_ActiveReader getReaderID] aStopTriggeConfig:config aStatusMessage:statusMessage];
        
        if ((srfid_result != SRFID_RESULT_RESPONSE_TIMEOUT) && (srfid_result != SRFID_RESULT_FAILURE)) {
            break;
        }
    }
    
    if (srfid_result == SRFID_RESULT_SUCCESS)
    {
        srfid_result = [self getStopTriggerConfiguration:statusMessage];
    }
    else if(srfid_result == SRFID_RESULT_RESPONSE_ERROR)
    {
        [self getStopTriggerConfiguration:nil];
    }
    else if(srfid_result == SRFID_RESULT_FAILURE || srfid_result == SRFID_RESULT_RESPONSE_TIMEOUT)
    {
        [self readerProblem];
    }
    return srfid_result;
}

#pragma mark - observers management

- (void)addTriggerEventDelegate:(id<zt_IZebraServiceEngineTriggerEventDelegate>)delegate
{
    [m_TriggerEventDelegates addObject:delegate];
}

- (void)removeTriggerEventDelegate:(id<zt_IZebraServiceEngineTriggerEventDelegate>)delegate
{
    [m_TriggerEventDelegates removeObject:delegate];
}

#pragma mark - Inventory Protocol

-(SRFID_RESULT)getReaderInventoryProtocol:(SRFID_ENUM_INVENTORY_PROTOCOL *)protocol
                           aStatusMessage:(NSString **)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    SRFID_ENUM_INVENTORY_PROTOCOL protocolEnum;
    NSLog(@"[DEBUGG] connectedId in Service Engine  getReaderInventoryProtocol =%d", availableReaderID);
    srfid_result = [apiInstance getInventoryProtocol:availableReaderID
                                             protocol:&protocolEnum
                                        statusMessage:statusMessage];
    
    if (srfid_result == SRFID_RESULT_SUCCESS) {
        *protocol = protocolEnum;
    }
    
    return srfid_result;
}


-(SRFID_RESULT)setReaderInventoryProtocol:(SRFID_ENUM_INVENTORY_PROTOCOL)protocol aStatusMessage:(NSString**)statusMessage {
    
    SRFID_RESULT srfid_result = SRFID_RESULT_FAILURE;
    NSLog(@"[DEBUGG] connectedId in Service Engine =%d", availableReaderID);
    srfid_result = [apiInstance setInventoryprotocol:availableReaderID protocol:protocol statusMessage:statusMessage];
    NSLog(@"[DEBUGG]setReaderInventoryProtocol in Service Engine result=%ld", (long)srfid_result);
    return srfid_result;
    
}


@end
