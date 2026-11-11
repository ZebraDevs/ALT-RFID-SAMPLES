//
//  MenuVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import "MenuVC.h"
#import "ProtectedVC.h"
#import "SingulationVC.h"
#import "TagQuietVC.h"
#import "TagQuietVC.h"
#import "PreFilterVC.h"
#import "InventoryVC.h"
#import "InventoryProtocolVC.h"
#import "AlertViewHelper.h"

#define IMPINJ_TAG_CONFIG_STORYBOARD_NAME   @"ImpinjTagConfigStoryboard"
#define IMPINJ_TAG_PROTECT_BOARD_ID     @"IMPINJ_TAG_PROTECT_BOARD_ID"

#define IMPINJ_TAG_SINGULATION_STORYBOARD_NAME   @"Singulation_Storboard"
#define IMPINJ_TAG_SINGULATION_BOARD_ID     @"IMPINJ_TAG_SINGULATION_BOARD_ID"

#define IMPINJ_TAG_QUIET_STORYBOARD_NAME   @"TagQuietStoryboard"
#define IMPINJ_TAG_QUIET_BOARD_ID     @"IMPINJ_TAG_QUIET_BOARD_ID"

#define IMPINJ_PRE_FILTER_STORYBOARD_NAME   @"PreFilterStoryboard"
#define IMPINJ_PRE_FILTER_BOARD_ID     @"PRE_FILTER_S_BOARD_ID"


#define IMPINJ_INVENTORY_STORYBOARD_NAME   @"InventoryStoryboard"
#define IMPINJ_INVENTORY__BOARD_ID     @"INVENTORY_VC_ID"

#define IMPINJ_INVENTORY_PTOTOCOL_STORYBOARD_NAME   @"InventoryProtocolStoryboard"
#define IMPINJ_INVENTORY_PROTOCOL_BOARD_ID     @"INVENTORY_PROTOCOL_BOARD_ID"

@interface MenuVC ()

@end
//
@implementation MenuVC

-  (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    
    // Initialize the data array
    self.dataArray = @[@"Connect", @"Inventory",@"Singulation", @"Prefilter",@"Custom Tag Quieting",@"Protected Mode", @"Inventory Protocol"];
    
    // Initialize the table view
    self->tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // Set the delegate and data source
    self->tableView.delegate = self;
    self->tableView.dataSource = self;
    
    // Register a basic UITableViewCell class
    //[self->tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell123"];
    // Load the nib file and register it with the identifier "Cell123"
      //[self->tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell123"];
    
    // Add the table view to the view hierarchy
    [self.view addSubview:self->tableView];
}

#pragma mark - UITableViewDataSource

// Number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Single section
}

// Number of rows in the section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count; // Number of items in the array
}

// Configure and return each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellID";
      
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
     cellIdentifier];
     
     if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
        UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
     }

    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor labelColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

// Handle row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the row with animation
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    ProtectedVC *impinjTagProtectVC = nil;
    SingulationVC *singulationVC = nil;
    TagQuietVC *tagQuietVC = nil;
    PreFilterVC *preFilterVC = nil;
    InventoryVC *inventoryVC = nil;
    InventoryProtocolVC *inventoryProtocolVC = nil;


    if ([[ZebraServiceEngine sharedInstance] getConnectedReaderId] != -1){
        if(indexPath.row == 1){
            
            inventoryVC = (InventoryVC*)[[UIStoryboard storyboardWithName:IMPINJ_INVENTORY_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_INVENTORY__BOARD_ID];
            [self.navigationController pushViewController:inventoryVC animated:YES];
            

              
                 
        }
         if(indexPath.row == 2){
            singulationVC = (SingulationVC*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_SINGULATION_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_TAG_SINGULATION_BOARD_ID];
        

            [self.navigationController pushViewController:singulationVC animated:YES];
            
        } else if(indexPath.row == 3){
            preFilterVC = (PreFilterVC*)[[UIStoryboard storyboardWithName:IMPINJ_PRE_FILTER_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_PRE_FILTER_BOARD_ID];
       

           [self.navigationController pushViewController:preFilterVC animated:YES];
           
       } else if(indexPath.row == 4){
    //
            tagQuietVC = (TagQuietVC*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_QUIET_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_TAG_QUIET_BOARD_ID];
            [self.navigationController pushViewController:tagQuietVC animated:YES];
            
        } else if(indexPath.row == 5){
    //
            impinjTagProtectVC = (ProtectedVC*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_CONFIG_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_TAG_PROTECT_BOARD_ID];
            [self.navigationController pushViewController:impinjTagProtectVC animated:YES];
            
        } else if(indexPath.row == 6){
            inventoryProtocolVC = (InventoryProtocolVC*)[[UIStoryboard storyboardWithName:IMPINJ_INVENTORY_PTOTOCOL_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_INVENTORY_PROTOCOL_BOARD_ID];
            [self.navigationController pushViewController:inventoryProtocolVC animated:YES];
        }
        
    }else {
        [AlertViewHelper showAlertOn:self
                           title:@"Error"
                         message:@"No Connected Reader"];
    }
    
    
    
    
    
    
    /*
    ImpingTagProtectViewController *impinjTagProtectVC = nil;
    inventoryRequested = [[[zt_RfidAppEngine sharedAppEngine] operationEngine] getStateInventoryRequested];
    if (inventoryRequested == YES) {
        [self showWarning:@"Impinj Tag Functions are not allowed while main inventory is running"];
    }else {
        
        if(indexPath.row == 0){
            impinjTagProtectVC = (ImpingTagProtectViewController*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_CONFIG_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:IMPINJ_TAG_PROTECT_BOARD_ID];
        
            [self.navigationController pushViewController:impinjTagProtectVC animated:YES];
            
        }
        else  if(indexPath.row == 1) {
            
            //[self enableTagFocusImpinj:YES];
            
            SRFID_RESULT result = SRFID_RESULT_FAILURE;
            NSString *status = [[NSString alloc] init];
            
            result = [[zt_RfidAppEngine sharedAppEngine]enableTagFocus:YES
                                                             aStatusMessage:&status];
            
            if (result == SRFID_RESULT_SUCCESS)
            {
                SRFID_RESULT result1 = SRFID_RESULT_FAILURE;
                NSString *status1 = [[NSString alloc] init];
                
                result1 = [[zt_RfidAppEngine sharedAppEngine]getPrefilters :&status1];
                
                if (result1 == SRFID_RESULT_SUCCESS)
                {
                    NSLog(@"SRFID_RESULT_SUCCESS");
                    
                    NSNumber *sessionIndex = @1;
                    [[NSUserDefaults standardUserDefaults] setObject:sessionIndex forKey:@"SavedSessionIndex"];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TagFocusEnabled"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }else{
                    NSLog(@"SRFID_RESULT_Fail");
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TagFocusEnabled"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                
          
                [self showWarning:@"Impinj Enable Tag Focus Success!"];
            }else{
       
                [self showWarning:@"Impinj Enable Tag Focus Fail !"];
            }
            
            
            
            
  
        }
        else  if(indexPath.row == 2) {
            
            SRFID_RESULT result = SRFID_RESULT_FAILURE;
            NSString *status = [[NSString alloc] init];
            
            result = [[zt_RfidAppEngine sharedAppEngine]enableTagFocus:NO
                                                             aStatusMessage:&status];
            
            if (result == SRFID_RESULT_SUCCESS)
            {
                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
                [local setPrefilterEnabled:0];
                [self showWarning:@"Impinj Disable Tag Focus Success!"];
            }else{
                [self showWarning:@"Impinj Disable Tag Focus Failed!"];
            }
        }
//        else  if(indexPath.row == 3) {
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TagQueitEnabled"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//
//            NSString *status = [[NSString alloc] init];
//            SRFID_RESULT resTagQuiteFinal =   [[zt_RfidAppEngine sharedAppEngine]enableTagQuiet:YES meesage:&status];
//
//            if(resTagQuiteFinal == SRFID_RESULT_SUCCESS){
//                [self showWarning:@"Impinj Tag Queit Enabled !"];
//                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
//                [local setPrefilterEnabled:1];
//
//            }else{
//                [self showWarning:@"Impinj Tag Queit Enabled Failed !"];
//            }
//
//
//
//
//
//        }else  if(indexPath.row == 4) {
//
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TagQueitEnabled"];
//            [[NSUserDefaults standardUserDefaults]synchronize];
//            NSString *status = [[NSString alloc] init];
//            [[zt_RfidAppEngine sharedAppEngine]deleteAllPrefilter:&status];
//          //  [self showWarning:@"Impinj Tag Queit Disable !"];
//
//
//
//            SRFID_RESULT resTagQuiteFinal =   [[zt_RfidAppEngine sharedAppEngine]enableTagQuiet:NO meesage:&status];
//
//            if(resTagQuiteFinal == SRFID_RESULT_SUCCESS){
//                [self showWarning:@"Impinj Tag Queit Disable !"];
//                zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
//                [local setPrefilterEnabled:0];
//
//            }else{
//                [self showWarning:@"Impinj Tag Queit Disable !Failed !"];
//            }
//
//
//
//
//            zt_SledConfiguration *local = [[zt_RfidAppEngine sharedAppEngine] temporarySledConfigurationCopy];
//            [local setPrefilterEnabled:0];
//
//        }
        
        else  if(indexPath.row == 3) {
            ImpinjInventoryVC *impinjInventoryVC = nil;
            impinjInventoryVC = (ImpinjInventoryVC*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_CONFIG_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IMPINJ_INVENTORY_BOARD_ID"];
            [self.navigationController pushViewController:impinjInventoryVC animated:YES];
                    
        }
       
    }
     
     */
   
}

-(void)enableTagFocusImpinj:(BOOL)enable {
    
    
}

- (void)showWarning:(NSString *)message
{
   // [self showLoadingBarWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];

}





@end

