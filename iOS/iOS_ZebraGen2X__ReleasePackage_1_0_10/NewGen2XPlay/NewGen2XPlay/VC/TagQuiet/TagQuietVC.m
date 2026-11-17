//
//  TagQuietVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import "TagQuietVC.h"
#import "ZebraServiceEngine.h"
#import "AlertViewHelper.h"


#define IMPINJ_SELECTIO_STORYBOARD_NAME   @"PickerSelectedStoryboard"
#define IMPINJ_SELECTION_BOARD_ID     @"IMPINJ_SELECTION_BOARD_ID"

#define ZT_RFID_APP_NAME                       @"ZebraGen2X Application"

// NSUserDefaults keys
#define kTagQuietMask1Key   @"TagQuiet_Mask1"
#define kTagQuietMask2Key   @"TagQuiet_Mask2"
#define kTagQuietMask3Key   @"TagQuiet_Mask3"
#define kActionKey          @"TagQuiet_Action"
#define kTargetKey          @"TagQuiet_Target"

@interface TagQuietVC ()

@end

@implementation TagQuietVC
//TagQuietStoryboard
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Custom Tag Quieting"];
    [self setupKeyboardDismissOnBackgroundTap];
    // Do any additional setup after loading the view.
    
    // Restore saved values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _txtTagQuietMask1.text = [defaults stringForKey:kTagQuietMask1Key] ?: @"";
    _txtTagQuietMask2.text = [defaults stringForKey:kTagQuietMask2Key] ?: @"";
    _txtTagQuietMask3.text = [defaults stringForKey:kTagQuietMask3Key] ?: @"";
    _txtAction.text        = [defaults stringForKey:kActionKey]        ?: @"";
    _txtTarget.text        = [defaults stringForKey:kTargetKey]        ?: @"";
    
}
- (IBAction)btnSaveTagQuietingFilterPressed:(id)sender {
    
    if (_txtTagQuietMask1.text.length == 0 && _txtTagQuietMask2.text.length == 0 && _txtTagQuietMask3.text.length == 0)
    {
           [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"No filter to add"];
           return; // Exit the method early
    }
    
    // Persist to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_txtTagQuietMask1.text ?: @"" forKey:kTagQuietMask1Key];
    [defaults setObject:_txtTagQuietMask2.text ?: @"" forKey:kTagQuietMask2Key];
    [defaults setObject:_txtTagQuietMask3.text ?: @"" forKey:kTagQuietMask3Key];
    [defaults setObject:_txtAction.text        ?: @"" forKey:kActionKey];
    [defaults setObject:_txtTarget.text        ?: @"" forKey:kTargetKey];
    [defaults synchronize];
    
    NSMutableArray<NSNumber *> *tagQuietMaskArray = [NSMutableArray array];
    if (_txtTagQuietMask1.text.length > 0) {
        [tagQuietMaskArray addObject:@(tagQuietMaskFromString(_txtTagQuietMask1.text))];
    }
    if (_txtTagQuietMask2.text.length > 0) {
        [tagQuietMaskArray addObject:@(tagQuietMaskFromString(_txtTagQuietMask2.text))];
    }
    if (_txtTagQuietMask3.text.length > 0) {
        [tagQuietMaskArray addObject:@(tagQuietMaskFromString(_txtTagQuietMask3.text))];
    }
    
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    result = [[ZebraServiceEngine sharedInstance]customTagQuiet:tagQuietMaskArray enumTarget:customSRFID_SELECTTARGETFromString(_txtTarget.text) action:customSRFID_SELECTACTIONFromString(_txtAction.text) meesage:&status];
    if (result == SRFID_RESULT_SUCCESS) {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Saved Custom Filter Successfully"];
    }else {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Saving Custom Filter Failure"];
    }
    
}

- (IBAction)btnDeleteAllPrefiltersPressed:(id)sender {
    
    if (_txtTagQuietMask1.text.length == 0 && _txtTagQuietMask2.text.length == 0 && _txtTagQuietMask3.text.length == 0)
    {
           [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"No filter to delete"];
           return; // Exit the method early
    }

    
    // Clear NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kTagQuietMask1Key];
    [defaults removeObjectForKey:kTagQuietMask2Key];
    [defaults removeObjectForKey:kTagQuietMask3Key];
    [defaults removeObjectForKey:kActionKey];
    [defaults removeObjectForKey:kTargetKey];
    [defaults synchronize];
    // Clear text fields
    _txtTagQuietMask1.text = @"";
    _txtTagQuietMask2.text = @"";
    _txtTagQuietMask3.text = @"";
    _txtAction.text        = @"";
    _txtTarget.text        = @"";
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = [[NSString alloc] init];
    result = [[ZebraServiceEngine sharedInstance] deleteAllPrefilter:&status];
    if (result == SRFID_RESULT_SUCCESS) {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Deleted All Custom Filters Successfully"];
    }
    else {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Delete All Custom Filters Successfully"];
    }
}

    


SRFID_ENUM_TAGQUIET_MASK tagQuietMaskFromString(NSString *maskString) {
    if ([maskString isEqualToString:@"SOB"]) {
        return ENUM_TAGQUIET_MASK_S0B;
    } else if ([maskString isEqualToString:@"S2B"]) {
        return ENUM_TAGQUIET_MASK_S2B;
    } else if ([maskString isEqualToString:@"S3B"]) {
        return ENUM_TAGQUIET_MASK_S3B;
    } else if ([maskString isEqualToString:@"SL_ASSERT"]) {
        return ENUM_TAGQUIET_MASK_SL_ASSERT;
    } else if ([maskString isEqualToString:@"SOA"]) {
        return ENUM_TAGQUIET_MASK_S0A;
    } else if ([maskString isEqualToString:@"S2A"]) {
        return ENUM_TAGQUIET_MASK_S2A;
    } else if ([maskString isEqualToString:@"S3A"]) {
        return ENUM_TAGQUIET_MASK_S3A;
    } else if ([maskString isEqualToString:@"SL_DEASSERT"]) {
        return ENUM_TAGQUIET_MASK_SL_DEASSERT;
    } else {
        // Return a default/unknown value if no match is found
        return ENUM_TAGQUIET_MASK_UNKNOWN;
    }
}

// SRFID_SELECTACTION Mapper : NSString --> SRFID_SELECTACTION
SRFID_SELECTACTION customSRFID_SELECTACTIONFromString(NSString *string) {
    static NSDictionary<NSString *, NSNumber *> *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL": @(SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL),
            @"SRFID_SELECTACTION_INV_A__OR__ASRT_SL":                       @(SRFID_SELECTACTION_INV_A__OR__ASRT_SL),
            @"SRFID_SELECTACTION_NOT_INV_B__OR__NOT_DSRT_SL":               @(SRFID_SELECTACTION_NOT_INV_B__OR__NOT_DSRT_SL),
            @"SRFID_SELECTACTION_INV_A2BB2A_NOT_INV_A__OR__NEG_SL_NOT_ASRT_SL": @(SRFID_SELECTACTION_INV_A2BB2A_NOT_INV_A__OR__NEG_SL_NOT_ASRT_SL),
            @"SRFID_SELECTACTION_INV_B_NOT_INV_A__OR__DSRT_SL_NOT_ASRT_SL": @(SRFID_SELECTACTION_INV_B_NOT_INV_A__OR__DSRT_SL_NOT_ASRT_SL),
            @"SRFID_SELECTACTION_INV_B__OR__DSRT_SL":                       @(SRFID_SELECTACTION_INV_B__OR__DSRT_SL),
            @"SRFID_SELECTACTION_NOT_INV_A__OR__NOT_ASRT_SL":               @(SRFID_SELECTACTION_NOT_INV_A__OR__NOT_ASRT_SL),
            @"SRFID_SELECTACTION_NOT_INV_A2BB2A__OR__NOT_NEG_SL":           @(SRFID_SELECTACTION_NOT_INV_A2BB2A__OR__NOT_NEG_SL),
        };
    });

    NSNumber *value = map[string];
    if (value) {
        return (SRFID_SELECTACTION)value.integerValue;
    }

    // Fallback / default (adjust if you prefer some other default)
    return SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL;
}

// SRFID_SELECTTARGET Mapper : NSString --> SRFID_SELECTTARGET
SRFID_SELECTTARGET customSRFID_SELECTTARGETFromString(NSString *string) {
    static NSDictionary<NSString *, NSNumber *> *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"SRFID_SELECTTARGET_S0": @(SRFID_SELECTTARGET_S0),
            @"SRFID_SELECTTARGET_S1": @(SRFID_SELECTTARGET_S1),
            @"SRFID_SELECTTARGET_S2": @(SRFID_SELECTTARGET_S2),
            @"SRFID_SELECTTARGET_S3": @(SRFID_SELECTTARGET_S3),
            @"SRFID_SELECTTARGET_SL": @(SRFID_SELECTTARGET_SL),
        };
    });

    NSNumber *value = map[string];
    if (value) {
        return (SRFID_SELECTTARGET)value.integerValue;
    }

    // Fallback / default value
    return SRFID_SELECTTARGET_S0;
}

-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae {

    [AlertViewHelper showAlertOn:self
                       title: title
                     message: messgae];
}

#pragma mark - Text Field Delegate 
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
    SelectionVC *selectionVC = nil;
    // textField was tapped / became active
    if (textField == self.txtTagQuietMask1) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegateTagQuiet = self;
        selectionVC.singulationSettingData = @"TAG_MASK_1";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
    else if (textField == self.txtTagQuietMask2) {
        
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegateTagQuiet = self;
        selectionVC.singulationSettingData = @"TAG_MASK_2";

        [self.navigationController pushViewController:selectionVC animated:YES];
        
    }
    else if (textField == self.txtTagQuietMask3) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegateTagQuiet = self;
        selectionVC.singulationSettingData = @"TAG_MASK_3";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
    else if (textField == self.txtAction) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegateTagQuiet = self;
        selectionVC.singulationSettingData = @"ACTION";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
    else if (textField == self.txtTarget) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegateTagQuiet = self;
        selectionVC.singulationSettingData = @"TARGET";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
    
    
}



#pragma mark - Protocol
- (void)tagQuietMask1:(SelectionVC *)controller didFinishSelectTagQuietMask:(NSString *)text{
    _txtTagQuietMask1.text = text;
}

- (void)tagQuietMask2:(SelectionVC *)controller didFinishSelectTagQuietMask:(NSString *)text{
    _txtTagQuietMask2.text = text;
}

- (void)tagQuietMask3:(SelectionVC *)controller didFinishSelectTagQuietMask:(NSString *)text{
    _txtTagQuietMask3.text = text;
}

- (void)action:(SelectionVC *)controller didFinishSelectAction:(NSString *)text{
    _txtAction.text = text;
    
}
- (void)target:(SelectionVC *)controller didFinishSelectTarget:(NSString *)text{
    _txtTarget.text = text;
}



#pragma mark - Hide keyboard
 // Call this once (e.g., in viewDidLoad)
 - (void)setupKeyboardDismissOnBackgroundTap
 {
     UITapGestureRecognizer *tap =
     [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
     tap.cancelsTouchesInView = NO; // so buttons/table selections still work
     [self.view addGestureRecognizer:tap];
 }

 - (void)dismissKeyboard
 {
     [self.view endEditing:YES];
 }

@end
