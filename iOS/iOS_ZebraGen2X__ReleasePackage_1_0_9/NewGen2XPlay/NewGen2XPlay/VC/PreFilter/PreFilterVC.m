//
//  PreFilterVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-19.
//

#import "PreFilterVC.h"
#import "ZebraServiceEngine.h"
#import "AlertViewHelper.h"
//PRE_FILTER_S_BOARD_ID
#define IMPINJ_SELECTIO_STORYBOARD_NAME   @"PickerSelectedStoryboard"
#define IMPINJ_SELECTION_BOARD_ID     @"IMPINJ_SELECTION_BOARD_ID"
@interface PreFilterVC ()

@end

@implementation PreFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupKeyboardDismissOnBackgroundTap];
    [self setTitle:@"Prefilter"];
    _txtTagPattern.delegate = self;
    _txtPreFilterList.text = @"1";
   

    // Initialize prefilterArray with 4 empty slots if it's not already set
    _prefilterArray = [[[ZebraServiceEngine sharedInstance] getPrefilters] mutableCopy];
    if (!_prefilterArray) {
        _prefilterArray = [NSMutableArray array];
    }

    // Ensure it has exactly 4 elements (NSNull for empty)
    while (_prefilterArray.count < 4) {
        [_prefilterArray addObject:[NSNull null]];
    }
    if (_prefilterArray.count > 4) {
        // If there are more than 4, optionally trim or keep; here we trim:
        [_prefilterArray removeObjectsInRange:NSMakeRange(4, _prefilterArray.count - 4)];
    }
    
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreFilterListValue"];
    if (savedValue) {
        _txtPreFilterList.text = savedValue;
    }
    
    [self getFilterOnIndex:[savedValue intValue]]; // show first slot when view loads
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (self.didNavigateToSelectionVC)
    {
        int index = [_txtPreFilterList.text intValue];
        [self getFilterOnIndex:index];

        // Optionally reset if you only want this once
        self.didNavigateToSelectionVC = NO;
    }
    NSLog(@"prefilterArray %@", _prefilterArray);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selectedTagID = [defaults objectForKey:@"SelectedTagID"];
    
    if ([self filterHasTagID:[_txtPreFilterList.text intValue]]){
        
    }else{
        if (selectedTagID != nil) {
            _txtTagPattern.text = selectedTagID;
            NSLog(@"ProtectedVC text field text (from defaults): %@", selectedTagID);

            // Clear the stored value so it doesn't keep applying
//            [defaults removeObjectForKey:@"SelectedTagID"];
//            [defaults synchronize];
        } else {
            NSLog(@"No SelectedTagID found in NSUserDefaults");
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Save the value to NSUserDefaults
    NSString *inputText = _txtPreFilterList.text;
    [[NSUserDefaults standardUserDefaults] setObject:inputText forKey:@"PreFilterListValue"];
    [[NSUserDefaults standardUserDefaults] synchronize]; // Optional (not strictly needed in modern iOS)
}

-(void)getAllFilters{
    NSMutableArray *prefilters = [[NSMutableArray alloc] init];
    prefilters =  [[ZebraServiceEngine sharedInstance] getPrefilters];
    
    NSLog(@"%@", prefilters);
    
    srfidPreFilter *filter =  [[srfidPreFilter alloc] init];
    int currentFilter = [_txtPreFilterList.text intValue] - 1;
    
    @try {
        filter = prefilters[currentFilter];
        NSLog(@"Filter getAction %u", [filter getAction]);
        NSLog(@"Filter getTarget %u", [filter getTarget]);
        NSLog(@"Filter getMemoryBank %u", [filter getMemoryBank]);
        NSLog(@"Filter getMatchLength %d", [filter getMatchLength]);
        NSLog(@"Filter getMatchPattern %@", [filter getMatchPattern]);
        
    }@catch(NSException *ex) {
        NSLog(@"Filter Not Found");
    }
   
}

-(BOOL)filterHasTagID:(int)filterIndex{
    srfidPreFilter *filter = nil;
    NSInteger actualIndex = filterIndex - 1; // 1-based → 0-based
    NSString *filterTagID = @"";
    if (actualIndex >= 0 && actualIndex < _prefilterArray.count) {
        id obj = _prefilterArray[actualIndex];
        if (obj != [NSNull null]) {
            filter = (srfidPreFilter *)obj;
        }
    }
    if (filter) {
        filterTagID  = [filter getMatchPattern];
        if (filterTagID != nil){
            return YES;
        }else{
            return NO;
        }
    }else {
        return NO;
    }
   
}

- (void)getFilterOnIndex:(int)index {
    srfidPreFilter *filter = nil;
    NSInteger actualIndex = index - 1; // 1-based → 0-based

    if (actualIndex >= 0 && actualIndex < _prefilterArray.count) {
        id obj = _prefilterArray[actualIndex];
        if (obj != [NSNull null]) {
            filter = (srfidPreFilter *)obj;
        }
    }

    if (filter) {
        _txtTagPattern.text  = [[filter getMatchPattern] uppercaseString];
        _txtTagPointer.text  = [NSString stringWithFormat:@"%d", [filter getMaskStartPos]];
        _txtTagLength.text   = [NSString stringWithFormat:@"%d", [filter getMatchLength]];
        _txtTarget.text      = NSStringFromSRFID_SELECTTARGET([filter getTarget]);
        _txtAction.text      = NSStringFromSRFID_SELECTACTION([filter getAction]);
        _txtMemoryBank.text  = NSStringFromSRFID_MEMORYBANK([filter getMemoryBank]);
        
        NSLog(@"Filter getAction %u", [filter getAction]);
        NSLog(@"Filter getTarget %u", [filter getTarget]);
        NSLog(@"Filter getMemoryBank %u", [filter getMemoryBank]);
        NSLog(@"Filter getMatchLength %d", [filter getMatchLength]);
        NSLog(@"Filter getMatchPattern %@", [filter getMatchPattern]);
    } else {
        _txtTagPattern.text  = @"";
        _txtTagPointer.text  = @"";
        _txtTagLength.text   = @"";
        _txtTarget.text      = @"";
        _txtAction.text      = @"";
        _txtMemoryBank.text  = @"";
    }
}

- (NSArray *)validPrefiltersFromArray:(NSArray *)array
{
    NSMutableArray *valid = [NSMutableArray array];

    for (id obj in array) {
        if (obj != [NSNull null] && [obj isKindOfClass:[srfidPreFilter class]]) {
            [valid addObject:obj];
        }
    }

    return [valid copy];
}

- (void)setFilter:(int)index {
    NSInteger actualIndex = index - 1;
    if (actualIndex < 0 || actualIndex >= 4) {
        NSLog(@"Invalid index %d for prefilterArray", index);
        return;
    }

    srfidPreFilter *filter = [[srfidPreFilter alloc] init];
    [filter setMatchPattern:_txtTagPattern.text];
    [filter setTarget:SRFID_SELECTTARGETFromString(_txtTarget.text)];
    [filter setMemoryBank:SRFID_MEMORYBANKFromString(_txtMemoryBank.text)];
    [filter setAction:SRFID_SELECTACTIONFromString(_txtAction.text)];
    [filter setMatchLength:[_txtTagLength.text intValue]];
    [filter setMaskStartPos:[_txtTagPointer.text intValue]];

    // Ensure array has 4 elements
    while (_prefilterArray.count < 4) {
        [_prefilterArray addObject:[NSNull null]];
    }

    // Replace the slot instead of inserting
    [_prefilterArray replaceObjectAtIndex:actualIndex withObject:filter];

    NSArray *validPrefilters = [self validPrefiltersFromArray:_prefilterArray];
    SRFID_RESULT result = [[ZebraServiceEngine sharedInstance] setPrefilters:[validPrefilters mutableCopy]];
    if (result == SRFID_RESULT_SUCCESS) {
        [self showAlert:@"Set Prefilter Successfully"];
    }else {
        [self showAlert:@"Set Prefilter Failed"];
    }
    NSLog(@"prefilterArray %@", _prefilterArray);
}


- (IBAction)btnSavePressed:(id)sender {
    [self setFilter:[_txtPreFilterList.text intValue]];
    
}

- (IBAction)btnDeletePressed:(id)sender {
    int indexToRemove = [_txtPreFilterList.text intValue];
    NSInteger actualIndex = indexToRemove - 1;
    
    if (_txtTagPattern.text.length == 0)
    {
           [self showAlert:@"No filter to delete"];
           return; // Exit the method early
    }

    if (actualIndex >= 0 && actualIndex < _prefilterArray.count)
    {
        _prefilterArray[actualIndex] = [NSNull null];
        NSArray *validPrefilters = [self validPrefiltersFromArray:_prefilterArray];
        SRFID_RESULT result = [[ZebraServiceEngine sharedInstance] setPrefilters:[validPrefilters mutableCopy]];
        if (result == SRFID_RESULT_SUCCESS) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"SelectedTagID"];
            
            [self showAlert:@"Filter Deleted: Successfully"];
            _txtTagPattern.text  = @"";
            _txtTagPointer.text  = @"";
            _txtTagLength.text   = @"";
            _txtTarget.text      = @"";
            _txtAction.text      = @"";
            _txtMemoryBank.text  = @"";
        }else {
            [self showAlert:@"Filter Deleted: Failed"];
        }
    } else
    {
        NSLog(@"Error: Index is beyond the bounds of the array.");
    }

    NSLog(@"Array after removal: %@", _prefilterArray);
}


- (IBAction)btnDeleteAllPrefiltersPressed:(id)sender {
    // First, check if there are any active (non-NSNull) prefilters
        BOOL hasActiveFilters = NO;
        for (NSInteger i = 0; i < _prefilterArray.count; i++) {
            if (_prefilterArray[i] != [NSNull null] &&
                [_prefilterArray[i] isKindOfClass:[srfidPreFilter class]]) {
                hasActiveFilters = YES;
                break;
            }
        }

        // If no active filters exist, inform the user and return early
        if (!hasActiveFilters) {
            [self showAlert:@"No active prefilters to delete."];
            return;
        }

        NSString *status = [[NSString alloc] init];

        // Only reset slots that contain an actual saved prefilter
        for (NSInteger i = 0; i < _prefilterArray.count; i++) {
            if (_prefilterArray[i] != [NSNull null] &&
                [_prefilterArray[i] isKindOfClass:[srfidPreFilter class]]) {
                _prefilterArray[i] = [NSNull null];
            }
        }

        [[ZebraServiceEngine sharedInstance] deleteAllPrefilter:&status];
    
        NSArray *validPrefilters = [self validPrefiltersFromArray:_prefilterArray];
        [[ZebraServiceEngine sharedInstance] setPrefilters:[validPrefilters mutableCopy]];
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"SelectedTagID"];
    
        _txtTagPattern.text  = @"";
        _txtTagPointer.text  = @"";
        _txtTagLength.text   = @"";
        _txtTarget.text      = @"";
        _txtAction.text      = @"";
        _txtMemoryBank.text  = @"";

        [self showAlert:@"Deleted All Filters successfully"];
}


// SRFID_SELECTTARGET Mapper : NSString --> SRFID_SELECTTARGET
SRFID_SELECTTARGET SRFID_SELECTTARGETFromString(NSString *string) {
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

// SRFID_MEMORYBANK Mapper : NSString --> SRFID_MEMORYBANK
SRFID_MEMORYBANK SRFID_MEMORYBANKFromString(NSString *string) {
    static NSDictionary<NSString *, NSNumber *> *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"EPC":     @(SRFID_MEMORYBANK_EPC),
            @"TID":     @(SRFID_MEMORYBANK_TID),
            @"USER":    @(SRFID_MEMORYBANK_USER),
        };
    });

    NSNumber *value = map[string];
    if (value) {
        return (SRFID_MEMORYBANK)value.integerValue;
    }

    // Fallback / default (pick the one that makes sense for your app)
    return SRFID_MEMORYBANK_NONE;
}

// SRFID_SELECTACTION Mapper : NSString --> SRFID_SELECTACTION
SRFID_SELECTACTION SRFID_SELECTACTIONFromString(NSString *string) {
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

// SRFID_SELECTACTION --> NSString
NSString *NSStringFromSRFID_SELECTACTION(SRFID_SELECTACTION action) {
    switch (action) {
        case SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL:
            return @"SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL";
        case SRFID_SELECTACTION_INV_A__OR__ASRT_SL:
            return @"SRFID_SELECTACTION_INV_A__OR__ASRT_SL";
        case SRFID_SELECTACTION_NOT_INV_B__OR__NOT_DSRT_SL:
            return @"SRFID_SELECTACTION_NOT_INV_B__OR__NOT_DSRT_SL";
        case SRFID_SELECTACTION_INV_A2BB2A_NOT_INV_A__OR__NEG_SL_NOT_ASRT_SL:
            return @"SRFID_SELECTACTION_INV_A2BB2A_NOT_INV_A__OR__NEG_SL_NOT_ASRT_SL";
        case SRFID_SELECTACTION_INV_B_NOT_INV_A__OR__DSRT_SL_NOT_ASRT_SL:
            return @"SRFID_SELECTACTION_INV_B_NOT_INV_A__OR__DSRT_SL_NOT_ASRT_SL";
        case SRFID_SELECTACTION_INV_B__OR__DSRT_SL:
            return @"SRFID_SELECTACTION_INV_B__OR__DSRT_SL";
        case SRFID_SELECTACTION_NOT_INV_A__OR__NOT_ASRT_SL:
            return @"SRFID_SELECTACTION_NOT_INV_A__OR__NOT_ASRT_SL";
        case SRFID_SELECTACTION_NOT_INV_A2BB2A__OR__NOT_NEG_SL:
            return @"SRFID_SELECTACTION_NOT_INV_A2BB2A__OR__NOT_NEG_SL";
    }

    // Unknown value
    return nil;
}

// SRFID_SELECTTARGET --> NSString
NSString *NSStringFromSRFID_SELECTTARGET(SRFID_SELECTTARGET target) {
    switch (target) {
        case SRFID_SELECTTARGET_S0:
            return @"SRFID_SELECTTARGET_S0";
        case SRFID_SELECTTARGET_S1:
            return @"SRFID_SELECTTARGET_S1";
        case SRFID_SELECTTARGET_S2:
            return @"SRFID_SELECTTARGET_S2";
        case SRFID_SELECTTARGET_S3:
            return @"SRFID_SELECTTARGET_S3";
        case SRFID_SELECTTARGET_SL:
            return @"SRFID_SELECTTARGET_SL";
    }
    // Unknown/unsupported value
    return nil;
}

// SRFID_MEMORYBANK --> NSString
NSString *NSStringFromSRFID_MEMORYBANK(SRFID_MEMORYBANK bank) {
    switch (bank) {
        case SRFID_MEMORYBANK_EPC:     return @"EPC";
        case SRFID_MEMORYBANK_TID:     return @"TID";
        case SRFID_MEMORYBANK_USER:    return @"USER";
        case SRFID_MEMORYBANK_RESV:    return @"RESV";
        case SRFID_MEMORYBANK_NONE:    return @"NONE";
        case SRFID_MEMORYBANK_ACCESS:  return @"ACCESS";
        case SRFID_MEMORYBANK_KILL:    return @"KILL";
        case SRFID_MEMORYBANK_TAMPER:  return @"AMPER";
        case SRFID_MEMORYBANK_ALL:     return @"ALL";
    }
    return nil;
}

- (void)showAlert:(NSString *)alertMsg {
    
    [AlertViewHelper showAlertOn:self
                       title: @"Alert"
                     message: alertMsg];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    NSString *singulationKey = nil;

    if (textField == self.txtTarget) {
        singulationKey = @"TARGET_FILTER";
    }
    else if (textField == self.txtAction) {
        singulationKey = @"ACTION_FILTER";
    }
    else if (textField == self.txtPreFilterList) {
        singulationKey = @"FILTER_LIST";
        self.didNavigateToSelectionVC = YES;
    }
    else if (textField == self.txtMemoryBank) {
        singulationKey = @"MEMORYBANK_FILTER";
    }

    if (singulationKey) {
        // Dismiss any OTHER keyboard that might already be open
        [self.view endEditing:YES];

        SelectionVC *selectionVC = (SelectionVC *)[[UIStoryboard                       storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME
                        bundle:[NSBundle mainBundle]]
                        instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegatePreFilter = self;
        selectionVC.singulationSettingData = singulationKey;

        [self.navigationController pushViewController:selectionVC animated:YES];

        return NO; // prevent this text field from becoming first responder at all
    }

    return YES; // allow normal text fields to open the keyboard
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



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


- (void)actionPreFilter:(SelectionVC *)controller didFinishSelectAction:(NSString *)text{
    _txtAction.text = text;
}
- (void)targetPreFilter:(SelectionVC *)controller didFinishSelectTarget:(NSString *)text{
    _txtTarget.text = text;
}
- (void)memoryBankPreFilter:(SelectionVC *)controller didFinishSelectMemory:(NSString *)text{
    _txtMemoryBank.text = text;
}

- (void)filterListPreFilter:(SelectionVC *)controller didFinishFilterList:(NSString *)text{
    _txtPreFilterList.text = text;
}

// Only allow hexa decimals in prefilter tag pattern
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string
{
    if (textField != _txtTagPattern) {
        return YES;
    }

    // Allow backspace/delete
    if (string.length == 0) {
        return YES;
    }

    // Force uppercase and validate hex characters
    NSString *uppercased = [string uppercaseString];
    NSCharacterSet *hexSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];

    if ([[uppercased stringByTrimmingCharactersInSet:hexSet] length] != 0) {
        return NO; // contains non-hex characters
    }

    // If user typed lowercase, manually replace with uppercase
    if (![string isEqualToString:uppercased]) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                withString:uppercased];
        return NO;
    }

    return YES;
}


@end
