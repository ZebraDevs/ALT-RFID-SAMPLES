//
//  SelectionVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import "SelectionVC.h"

@interface SelectionVC ()

@end

@implementation SelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // The 'dataFromA' property now holds the string from ViewControllerA
      NSLog(@"Data received: %@", self.singulationSettingData);
      [self setTitle:self.singulationSettingData];
      
    
    self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    
    // Initialize the data array
    
    self.dataArraySession = [self sessionOptionsForSingulationSetting:_singulationSettingData];

   

    
    // Initialize the table view
    self->tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    // Set the delegate and data source
    self->tableView.delegate = self;
    self->tableView.dataSource = self;
    
    [self.view addSubview:self->tableView];
}


- (NSArray<NSString *> *)sessionOptionsForSingulationSetting:(NSString *)selectionDataFromTable
{
    if ([selectionDataFromTable isEqualToString:@"SESSION"]) {
        return @[@"S0", @"S1", @"S2", @"S3"];
    }

    if ([selectionDataFromTable isEqualToString:@"TAG_POPULATION"]) {
        return @[@"Session 0", @"Session 1", @"Session 2", @"Session 3"];
    }

    if ([selectionDataFromTable isEqualToString:@"STATE"]) {
        return @[@"STATE A", @"STATE B", @"AB_FLIP"];
    }

    if ([selectionDataFromTable isEqualToString:@"SL_FLAG"]) {
        return @[@"ASSERTED", @"DEASSERTED", @"ALL"];
    }
    
    
    if ([selectionDataFromTable isEqualToString:@"TAG_MASK_1"] | [selectionDataFromTable isEqualToString:@"TAG_MASK_2"] |[selectionDataFromTable isEqualToString:@"TAG_MASK_3"] ) {
        return @[@"SOB", @"S2B", @"S3B", @"SL_ASSERT",@"SOA",@"S2A",@"S3A",@"SL_DEASSERT"];
    }
    if ([selectionDataFromTable isEqualToString:@"ACTION"]) {
        return @[@"SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL",
                 @"SRFID_SELECTACTION_INV_A__OR__ASRT_SL",
                 @"SRFID_SELECTACTION_NOT_INV_B__OR__NOT_DSRT_SL",
                 @"SRFID_SELECTACTION_INV_A2BB2A_NOT_INV_A__OR__NEG_SL_NOT_ASRT_SL",
                 @"SRFID_SELECTACTION_INV_B_NOT_INV_A__OR__DSRT_SL_NOT_ASRT_SL",
                 @"SRFID_SELECTACTION_INV_B__OR__DSRT_SL",
                 @"SRFID_SELECTACTION_NOT_INV_A__OR__NOT_ASRT_SL",
                 @"SRFID_SELECTACTION_NOT_INV_A2BB2A__OR__NOT_NEG_SL"
        ];
    }
    if ([selectionDataFromTable isEqualToString:@"TARGET"]) {
        return @[@"SRFID_SELECTTARGET_S0",
                 @"SRFID_SELECTTARGET_S1",
                 @"SRFID_SELECTTARGET_S2",
                 @"SRFID_SELECTTARGET_S3",
                 @"SRFID_SELECTTARGET_SL"];
    }
    if ([selectionDataFromTable isEqualToString:@"TARGET_FILTER"]) {
        return @[@"SRFID_SELECTTARGET_S0",
                 @"SRFID_SELECTTARGET_S1",
                 @"SRFID_SELECTTARGET_S2",
                 @"SRFID_SELECTTARGET_S3",
                 @"SRFID_SELECTTARGET_SL"];
    }
    if ([selectionDataFromTable isEqualToString:@"MEMORYBANK_FILTER"]) {
        return @[@"EPC",
                 @"TID",
                 @"USER"];
    }
    
    if ([selectionDataFromTable isEqualToString:@"FILTER_LIST"]) {
        return @[@"1",
                 @"2",
                 @"3",
                 @"4"
        ];
    }
    
    else if ([selectionDataFromTable isEqualToString:@"ACTION_FILTER"]) {
        return @[@"SRFID_SELECTACTION_INV_A_NOT_INV_B__OR__ASRT_SL_NOT_DSRT_SL",
                 @"SRFID_SELECTACTION_INV_A__OR__ASRT_SL",
                 @"SRFID_SELECTACTION_NOT_INV_B__OR__NOT_DSRT_SL",
                 @"SRFID_SELECTACTION_INV_A2BB2A_NOT_INV_A__OR__NEG_SL_NOT_ASRT_SL",
                 @"SRFID_SELECTACTION_INV_B_NOT_INV_A__OR__DSRT_SL_NOT_ASRT_SL",
                 @"SRFID_SELECTACTION_INV_B__OR__DSRT_SL",
                 @"SRFID_SELECTACTION_NOT_INV_A__OR__NOT_ASRT_SL",
                 @"SRFID_SELECTACTION_NOT_INV_A2BB2A__OR__NOT_NEG_SL"
        ];
    }
    
    //ACTION_FILTER
    
    
    
  
    return @[];
}

#pragma mark - UITableViewDataSource

// Number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Single section
}

// Number of rows in the section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArraySession.count; // Number of items in the array
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

    cell.textLabel.text = self.dataArraySession[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

// Handle row selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect the row with animation
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *textToPassBack = self.dataArraySession[indexPath.row];
    if ([_singulationSettingData isEqualToString:@"SESSION"]) {
        [self.delegate sessionValue:self didFinishSelectSession:textToPassBack];
    }

    if ([_singulationSettingData isEqualToString:@"TAG_POPULATION"]) {
        [self.delegate tagPopulationValue:self didFinishSelectTagPopulationValue:textToPassBack];
    }

    if ([_singulationSettingData isEqualToString:@"STATE"]) {
        [self.delegate inventoryStateValue:self didFinishSelectInventoryStateValue:textToPassBack];
    }

    if ([_singulationSettingData isEqualToString:@"SL_FLAG"]) {
        [self.delegate slFlageValue:self didFinishSelectSlFlagValue:textToPassBack];
    }
    
    
    if ([_singulationSettingData isEqualToString:@"TAG_MASK_1"]) {
        [self.delegateTagQuiet tagQuietMask1:self didFinishSelectTagQuietMask:textToPassBack];
    }

    if ([_singulationSettingData isEqualToString:@"TAG_MASK_2"]) {
        [self.delegateTagQuiet tagQuietMask2:self didFinishSelectTagQuietMask:textToPassBack];
    }

    if ([_singulationSettingData isEqualToString:@"TAG_MASK_3"]) {
        [self.delegateTagQuiet tagQuietMask3:self didFinishSelectTagQuietMask:textToPassBack];
    }

    if ([_singulationSettingData isEqualToString:@"ACTION"]) {
        [self.delegateTagQuiet action:self didFinishSelectAction:textToPassBack];
    }
    if ([_singulationSettingData isEqualToString:@"TARGET"]) {
        [self.delegateTagQuiet target:self didFinishSelectTarget:textToPassBack];
    }
    
    
    if ([_singulationSettingData isEqualToString:@"TARGET_FILTER"]) {
        [self.delegatePreFilter targetPreFilter:self didFinishSelectTarget:textToPassBack];
    }
    
    if ([_singulationSettingData isEqualToString:@"ACTION_FILTER"]) {
        [self.delegatePreFilter actionPreFilter:self didFinishSelectAction:textToPassBack];
    }
    if ([_singulationSettingData isEqualToString:@"MEMORYBANK_FILTER"]) {
        [self.delegatePreFilter memoryBankPreFilter:self didFinishSelectMemory:textToPassBack];
    }
    
    if ([_singulationSettingData isEqualToString:@"FILTER_LIST"]) {
        [self.delegatePreFilter filterListPreFilter:self didFinishFilterList:textToPassBack];
    }
  
 
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)enableTagFocusImpinj:(BOOL)enable {
    
    
}

- (void)showWarning:(NSString *)message
{
   // [self showLoadingBarWithDurationWithMessage:message time:ZT_ALERTVIEW_WAITING_TIME];
   
}





@end


