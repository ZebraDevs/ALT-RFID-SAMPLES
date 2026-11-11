//
//  ProtectedVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import "ProtectedVC.h"
#import "ZebraServiceEngine.h"
#import "AppConstants.h"
#import "AlertViewHelper.h"

@interface ProtectedVC ()
@property (strong, nonatomic) NSArray *pickerData;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *activityOverlay;
@end

@implementation ProtectedVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSelected_EnableVisibilityBtn = NO;
    isSelected_DisableVisibilityBtn = NO;
    
    m_TagPasswordTxtField.delegate = self;
    m_TagPatternTxtField.delegate = self;
    
    [self setTitle:@"Protected Mode"];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    // Initialize the data source
    self.pickerData = @[@"Protect", @"Unprotect",@"Get Password", @"Set Password", @"Enable Inventory of Protected Tags", @"Clear Protected Mode Config"];
    
    // Set the delegate and data source
    self->m_PickerTagProtectMode.delegate = self;
    self->m_PickerTagProtectMode.dataSource = self;
    
    [self setTagIdToText];
    [self pickerSelectValueWhenLoadTheScreen];
    
    // Create the gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // Add the gesture to the main view
    [self.view addGestureRecognizer:tapGesture];
    [self setupActivityUIIfNeeded];
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSLog(@"ProtectedVC text field text: %@", m_TagPatternTxtField.text);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *selectedTagID = [defaults objectForKey:@"SelectedTagID"];

        if (selectedTagID != nil) {
            m_TagPatternTxtField.text = selectedTagID;
            NSLog(@"ProtectedVC text field text (from defaults): %@", selectedTagID);

            // Clear the stored value so it doesn't keep applying
//            [defaults removeObjectForKey:@"SelectedTagID"];
//            [defaults synchronize];
        } else {
            NSLog(@"No SelectedTagID found in NSUserDefaults");
        }
}

-(void)viewDidAppear:(BOOL)animated
{
    [self darkModeCheck:self.view.traitCollection];
    
}

-(void)pickerSelectValueWhenLoadTheScreen
{
    
    NSInteger selectedRow = [m_PickerTagProtectMode selectedRowInComponent:0];
    selectedOption = self.pickerData[selectedRow];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // This check applies the validation only to m_TagPasswordTxtField
    if (textField == m_TagPasswordTxtField) {
        // Convert the replacement string to uppercase
        NSString *uppercaseString = [string uppercaseString];
        
        // Define the set of allowed uppercase hexadecimal characters.
        NSCharacterSet *hexCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
        
        // Check if all characters in the converted string are part of the hex set.
        for (int i = 0; i < [uppercaseString length]; i++) {
            unichar c = [uppercaseString characterAtIndex:i];
            if (![hexCharSet characterIsMember:c]) {
                return NO; // Reject the change if a character is not in the set.
            }
        }
        
        // If validation passes, replace the text field's content with the uppercase version
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:uppercaseString];
        return NO; // Return NO because we've manually updated the text field.
    }
    
    return YES; // Allow the change for this or any other text fields.
}

#pragma mark - IBAction
- (IBAction)protectTag:(UIButton *)sender{
    
    [self tagProtectImpinjin];
    
}
#pragma mark - Activity Indicator

- (void)setupActivityUIIfNeeded {
    if (self.activityIndicator) return;

    self.activityOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    self.activityOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.activityOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    self.activityOverlay.hidden = YES;

    self.activityIndicator =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.color = [UIColor whiteColor];

    [self.activityOverlay addSubview:self.activityIndicator];
    [self.view addSubview:self.activityOverlay];

    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.activityOverlay.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.activityOverlay.centerYAnchor],
    ]];
}

- (void)showActivity {
    [self setupActivityUIIfNeeded];
    self.activityOverlay.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)hideActivity {
    [self.activityIndicator stopAnimating];
    self.activityOverlay.hidden = YES;
}

#pragma mark - UIPickerViewDataSource

// Number of components (columns) in the picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // Assuming a single column picker
}

// Number of rows in each component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

// Title for each row
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

// Optional: Handle selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedOption = self.pickerData[row];
    NSLog(@"Selected: %@", selectedOption);
    // Perform actions based on the selected option
}

#pragma mark - Dark mode handling

/// Check whether darkmode is changed
/// @param traitCollection The traits, such as the size class and scale factor.
-(void)darkModeCheck:(UITraitCollection *)traitCollection
{
   // self.view.backgroundColor = [UIColor getDarkModeViewBackgroundColor:traitCollection];
    
    
}


/// Notifies the container that its trait collection changed.
/// @param traitCollection The traits, such as the size class and scale factor,.
/// @param coordinator The transition coordinator object managing the size change.
- (void)willTransitionToTraitCollection:(UITraitCollection *)traitCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"Dark Mode change");
    [self darkModeCheck:traitCollection];
    
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}
-(void)setTagIdToText{
//    NSString * tagID;
//    if([[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getConfigASCIIMode])
//    {
//        tagID = [AsciiToHex stringFromAsciiString:[[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess]];
//    }
//    else
//    {
//        tagID = [[[zt_RfidAppEngine sharedAppEngine] appConfiguration] getTagIdAccess];
//    }
//    
//    m_TagPatternTxtField.text = tagID;
//    
}


#pragma mark - API call

-(void)enableTagVisibilityApi {
    
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    
    NSString * pin = m_TagPasswordTxtField.text;
    NSString *status = [[NSString alloc] init];
    result = [[ZebraServiceEngine sharedInstance]enableVisibilityTag:pin status:&status];
    if (result == SRFID_RESULT_SUCCESS)
    {
        // Track the status
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enableVS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success enable visibility"];
        
        srfidPreFilter *filter = [[srfidPreFilter alloc] init];
        [filter setTarget:SRFID_SELECTTARGET_S0];
        [filter setAction:SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL];
        [filter setMemoryBank:SRFID_MEMORYBANK_USER];
        [filter setMaskStartPos:0];
        [filter setMatchPattern:pin];
        [filter setMatchLength:32];
        
        SRFID_RESULT set_prefilters = SRFID_RESULT_FAILURE;
        NSMutableArray *prefilters = [[NSMutableArray alloc] init];
        
        NSString *status = [[NSString alloc] init];
        SRFID_RESULT delete_prefilters = [[ZebraServiceEngine sharedInstance] deleteAllPrefilter:&status];
        [[ZebraServiceEngine sharedInstance] resetPrefilters];
        //NSLog(@"Enable Visibility delete_prefilters: %u", delete_prefilters);
        //prefilters =  [[ZebraServiceEngine sharedInstance] getPrefilters];
        [prefilters addObject:filter];
        
        set_prefilters = [[ZebraServiceEngine sharedInstance] setPrefilters:prefilters];
        NSLog(@"Enable Visibility Set Prefilters: %u", set_prefilters);
        NSLog(@"Enable Visibility Delete All Prefilters: %u", delete_prefilters);
        

        
        
    }
    else
    {
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed enable visibility"];
        
        
    }
}

-(void)disableTagVisibilityApi {
   
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    
    NSString * pin = m_TagPasswordTxtField.text;
    NSString *status2 = [[NSString alloc] init];
    result = [[ZebraServiceEngine sharedInstance]disableVisibilityTag:pin status:&status2];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        // Track the status
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"enableVS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success disable visibility"];
        NSString *status = [[NSString alloc] init];
        SRFID_RESULT delete_prefilters = [[ZebraServiceEngine sharedInstance] deleteAllPrefilter:&status];
        [[ZebraServiceEngine sharedInstance] resetPrefilters];
        
        NSLog(@"Disable Visibility Delete All Prefilters: %u", delete_prefilters);
        
        
    }
    else
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed disable visibility"];
        
        
    }
    
}
-(void)protecTagApi {
   
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    //NSString *status = [[NSString alloc] init];
    srfidTagData *tagDataObjectTest = [[srfidTagData alloc] init];
    
    NSString * pin = m_TagPasswordTxtField.text;
    NSString *status = [[NSString alloc] init];
    result = [[ZebraServiceEngine sharedInstance]protectTag:m_TagPatternTxtField.text withTagData:&tagDataObjectTest withPassword:pin status:&status];
    
    
    // Call disable visibility
    SRFID_RESULT result2 = SRFID_RESULT_FAILURE;
    NSString *status2 = [[NSString alloc] init];
    result2 = [[ZebraServiceEngine sharedInstance]disableVisibilityTag:pin status:&status2];
    
    [[NSUserDefaults standardUserDefaults]
        setBool:YES
         forKey:@"ProtectTagEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success Protect Tag"];
    }
    else
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed Protect Tag"];
    }
}

-(void)unprotecTagApi {
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    //NSString *status = [[NSString alloc] init];
    srfidTagData *tagDataObjectTest = [[srfidTagData alloc] init];
    
    NSString * pin = m_TagPasswordTxtField.text;
    NSString *status = [[NSString alloc] init];
    result = [[ZebraServiceEngine sharedInstance]
              unprotectTag:m_TagPatternTxtField.text withTagData:&tagDataObjectTest withPassword:pin status:&status];
    
    [[NSUserDefaults standardUserDefaults]
        setBool:YES
         forKey:@"ProtectTagEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    if (result == SRFID_RESULT_SUCCESS)
    {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Success  UnProtect Tag"];
    }
    else
    {
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Failed  UnProtect Tag"];
    }
    
}




// tag protect
-(void)tagProtectImpinjin {
    
    if (m_TagPatternTxtField.text.length != 0 && [selectedOption isEqualToString:@"Get Password"]) {
        [self getPassword];
    }
    else if ([selectedOption isEqualToString:@"Enable Inventory of Protected Tags"])
    {
        [self enableTagVisibilityApi];
    }
    
    else if (m_TagPatternTxtField.text.length != 0 &&  m_TagPasswordTxtField.text.length == 8)
    {
        if ([selectedOption isEqualToString:@"Protect"])
        {
            [self protecTagApi];
        }
        else if ([selectedOption isEqualToString:@"Unprotect"])
        {
            [self unprotecTagApi];
        }
        else if ([selectedOption isEqualToString:@"Set Password"]){
            [self setPassword:m_TagPasswordTxtField.text];
        }
        
        else if ([selectedOption isEqualToString:@"Clear Protected Mode Config"]) {
            [self disableTagVisibilityApi];
        }
    }
    else
    {
        [self textFiledValidation];
    }
    
}


#pragma mark - Alert
/// Display alert message
/// @param title Title string
/// @param messgae message string
-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)messgae {
    
    [AlertViewHelper showAlertOn:self
                       title: title
                     message: messgae];
    
}

#pragma mark - TextField Should Return
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Dismiss the keyboard
    [textField resignFirstResponder];
    
    if (m_TagPasswordTxtField.text.length == 0 && (![selectedOption isEqualToString:@"Get Password"] || ([selectedOption isEqualToString:@"Clear Protected Mode Config"]))) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Password cannot be empty."];
        return NO;
    }
    if (m_TagPasswordTxtField.text.length < 6) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password is too short.");
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Password is too short."];
        // Prevent the user from proceeding if necessary
        return NO;
    }
    
    if (m_TagPatternTxtField.text.length == 0 && (![selectedOption isEqualToString:@"Enable Inventory of Protected Tags"] || ![selectedOption isEqualToString:@"Clear Protected Mode Config"]))
    {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Tag id cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Tag id cannot be empty."];
        return NO;
    }
    
    return YES;
}

-(void)textFiledValidation{
    
    
    if (m_TagPatternTxtField.text.length == 0  && ![selectedOption isEqualToString:@"Enable Inventory of Protected Tags"]) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Tag id cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Tag id cannot be empty."];
        
    }
    
    if (m_TagPasswordTxtField.text.length == 0  && ![selectedOption isEqualToString:@"Get Password"]) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password cannot be empty.");
        // Prevent the user from proceeding if necessary
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Password cannot be empty."];
        
    }
    if (m_TagPasswordTxtField.text.length  != 8 && ![selectedOption isEqualToString:@"Get Password"]) {
        // The text field is empty. Show an alert or a message.
        NSLog(@"Password is too short.");
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"The password length should be 8 characters.."];
        
    }
    
}

-(void)setPassword:(NSString*)password{
    srfidTagData *tagData = [[srfidTagData alloc] init];
    SRFID_RESULT write_tag_result = [[ZebraServiceEngine sharedInstance] writeTag:m_TagPatternTxtField.text withTagData:&tagData withMemoryBankID:SRFID_MEMORYBANK_RESV withOffset:2 withData:password withPassword:0 doBlockWrite:NO aStatusMessage:nil];
    
    NSLog(@"Srfid Write Tag Result %u", write_tag_result);
    
    if (write_tag_result == SRFID_RESULT_SUCCESS) {
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Set Password Success"];
    }else {
        
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Set Password Failure"];
    }
}

- (void)getPassword {

    NSString *tagID = [m_TagPatternTxtField.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (tagID.length == 0) {
        [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Tag id cannot be empty."];
        return;
    }

    [self showActivity];

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{

        srfidTagData *tagData = [[srfidTagData alloc] init];

        SRFID_RESULT read_tag_result =
        [[ZebraServiceEngine sharedInstance] readTag:tagID
                                          withTagData:&tagData
                                     withMemoryBankID:SRFID_MEMORYBANK_RESV
                                           withOffset:2
                                           withLength:2
                                         withPassword:0
                                      aStatusMessage:nil];

        NSString *memory = [tagData getMemoryBankData];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self hideActivity];

            NSLog(@"Srfid Read Tag Result %u", read_tag_result);
            NSLog(@"Tag Data: %@", memory);

            // Update UI on main
            self->m_TagPasswordTxtField.text = memory;

            if (read_tag_result == SRFID_RESULT_SUCCESS) {
                [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Get Password Success"];
            } else if (read_tag_result == SRFID_RESULT_RESPONSE_TIMEOUT) {
                [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:GET_PASSWORD_TIMEOUT];
            } else {
                [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:@"Get Password Failure"];
            }
        });
    });
}

#pragma mark - InventoryVCDelegate
- (void)inventoryVC:(InventoryVC *)controller didSelectItem:(NSString *)item {
    m_TagPatternTxtField.text = item;
}

@end
