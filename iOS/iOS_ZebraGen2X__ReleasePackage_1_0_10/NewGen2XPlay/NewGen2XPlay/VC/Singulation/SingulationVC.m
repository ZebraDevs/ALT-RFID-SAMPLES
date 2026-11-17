//
//  SingulationVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import "SingulationVC.h"
#import "SelectionVC.h"
#import "ZebraServiceEngine.h"
#define IMPINJ_SELECTIO_STORYBOARD_NAME   @"PickerSelectedStoryboard"
#define IMPINJ_SELECTION_BOARD_ID     @"IMPINJ_SELECTION_BOARD_ID"

@interface SingulationVC ()<UITextFieldDelegate>

@end

@implementation SingulationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Singulation"];
    [self setupKeyboardDismissOnBackgroundTap];
    // Do any additional setup after loading the view.
    
    [self populateArrays];
    [self getInitialSingulationSettingsFromReader];
}

-(void)getInitialSingulationSettingsFromReader{
    singulationConfig = [[ZebraServiceEngine sharedInstance] getSingulationConfiguration];
    NSLog(@"SL Flag: %u %@", [singulationConfig getSLFlag], slFlagArray[[singulationConfig getSLFlag]]);
    NSLog(@"Inv State: %u %@", [singulationConfig getInventoryState], invStateArray[[singulationConfig getInventoryState]]);
    NSLog(@"Session: %u %@", [singulationConfig getSession], sessionArray[[singulationConfig getSession]]);
    NSLog(@"Tag Population: %d", [singulationConfig getTagPopulation]);
    
    _txtSession.text = sessionArray[[singulationConfig getSession]];
    _txtInventoryState.text = invStateArray[[singulationConfig getInventoryState]];
    _txtSlFlag.text = slFlagArray[[singulationConfig getSLFlag]];
    _txtTagPopulation.text = [NSString stringWithFormat:@"%d", [singulationConfig getTagPopulation]];
    
    
}

-(void)setSingulationConfiguration{
    [self populateArrays];
    singulationConfig = [[ZebraServiceEngine sharedInstance] getSingulationConfiguration];
    NSUInteger sessionIndex = [sessionArray indexOfObject:_txtSession.text];
    NSUInteger invStateIndex = [invStateArray indexOfObject:_txtInventoryState.text];
    NSUInteger slFlagIndex = [slFlagArray indexOfObject:_txtSlFlag.text];
    
    int tagPopulation = [_txtTagPopulation.text intValue];
    
    SRFID_SESSION sessionValue = (SRFID_SESSION)sessionIndex;
    SRFID_INVENTORYSTATE invStateValue = (SRFID_INVENTORYSTATE)invStateIndex;
    SRFID_SLFLAG slFlagValue = (SRFID_SLFLAG)slFlagIndex;
    
    [singulationConfig setSession:sessionValue];
    [singulationConfig setInventoryState:invStateValue];
    [singulationConfig setSlFlag:slFlagValue];
    [singulationConfig setTagPopulation:tagPopulation];
    
    SRFID_RESULT result = [[ZebraServiceEngine sharedInstance] setSingulationConfiguration:singulationConfig];
    
    if(result == SRFID_RESULT_SUCCESS){
        [self showAlert:@"Set Singulation Success"];
    }else {
        [self showAlert:@"Set Singulation Failure"];
    }
}
- (IBAction)saveBtnPressed:(id)sender {

    [self setSingulationConfiguration];
}

- (void)showAlert:(NSString *)alertMsg {
    // Create the alert controller with a title, message, and preferred style (alert or action sheet)
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                             message:alertMsg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // Create an action (a button) for the alert
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
        // Optional: Code to run when the button is tapped
        //                                                              NSLog(@"OK button tapped");
    }];
    
    // Add the action to the alert controller
    [alertController addAction:defaultAction];
    
    // Present the alert controller from your current view controller
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - Actions
-(void)populateArrays{
    sessionArray = @[@"S0", @"S1", @"S2", @"S3"];
    invStateArray = @[@"STATE A", @"STATE B", @"AB_FLIP"];
    slFlagArray = @[@"ASSERTED", @"DEASSERTED", @"ALL"];;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    SelectionVC *selectionVC = nil;
    // textField was tapped / became active
    if (textField == self.txtSession) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegate = self;
        selectionVC.singulationSettingData = @"SESSION";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
    else if (textField == self.txtTagPopulation) {
        
         
        
    }
    else if (textField == self.txtInventoryState) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegate = self;
        selectionVC.singulationSettingData = @"STATE";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
    else if (textField == self.txtSlFlag) {
        [textField resignFirstResponder];

        selectionVC = (SelectionVC*)[[UIStoryboard storyboardWithName:IMPINJ_SELECTIO_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_SELECTION_BOARD_ID];
        selectionVC.delegate = self;
        selectionVC.singulationSettingData = @"SL_FLAG";

        [self.navigationController pushViewController:selectionVC animated:YES];
      
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



- (void)sessionValue:(SelectionVC *)controller didFinishSelectSession:(NSString *)text {
    //NSLog(@"Received text from second view controller: %@", text);
    _txtSession.text = text;
    // You can now use the 'text' variable to update the UI or perform other actions.
}


- (void)tagPopulationValue:(SelectionVC *)controller didFinishSelectTagPopulationValue:(NSString *)text {
    //NSLog(@"Received text from second view controller: %@", text);
    _txtTagPopulation.text = text;

}

- (void)inventoryStateValue:(SelectionVC *)controller didFinishSelectInventoryStateValue:(NSString *)text {
    //NSLog(@"Received text from second view controller: %@", text);
    _txtInventoryState.text = text;
    // You can now use the 'text' variable to update the UI or perform other actions.
}

- (void)slFlageValue:(SelectionVC *)controller didFinishSelectSlFlagValue:(NSString *)text {
    //NSLog(@"Received text from second view controller: %@", text);
    _txtSlFlag.text = text;
    // You can now use the 'text' variable to update the UI or perform other actions.
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
@end
