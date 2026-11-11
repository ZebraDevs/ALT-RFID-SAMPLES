//
//  InventoryProtocolVC.m
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 13/04/26.
//

#import <Foundation/Foundation.h>
#import "InventoryProtocolVC.h"
#import "AppConstants.h"
#import "AlertViewHelper.h"

@interface InventoryProtocolVC ()
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *currentModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *gen2Button;
@property (weak, nonatomic) IBOutlet UIButton *gen2xButton;
@property (weak, nonatomic) IBOutlet UIButton *hybridButton;
@property (strong, nonatomic) NSArray<UIButton *> *modeButtons;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, assign) SRFID_ENUM_INVENTORY_PROTOCOL selectedProtocol;
@end

@implementation InventoryProtocolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = INVENTORY_PROTOCOL_VC_TITLE;

    self.modeButtons = @[self.gen2Button, self.gen2xButton, self.hybridButton];

    // IMPORTANT: set tags to enum values (do this in storyboard ideally)
    self.gen2Button.tag = GEN2;
    self.gen2xButton.tag = GEN2X;
    self.hybridButton.tag = HYBRID;

    [self setupSegmentedControl];

    [self getProtocol];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getProtocol];
}

- (void)setupSegmentedControl {
    self.containerView.layer.borderWidth = 1;
    self.containerView.layer.cornerRadius = 44 / 2;
    self.containerView.layer.borderColor = [UIColor redColor].CGColor;
    self.containerView.clipsToBounds = YES;

    for (UIButton *btn in self.modeButtons) {
        btn.backgroundColor = UIColor.clearColor;
        [btn setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    }
}

#pragma mark - UI Selection

- (IBAction)modeButtonTapped:(UIButton *)sender {
    if (sender.selected) return;

    self.selectedProtocol = (SRFID_ENUM_INVENTORY_PROTOCOL)sender.tag;
    [self setSelectedModeButton:sender];
}

- (void)setSelectedModeButton:(UIButton *)selectedButton {
    for (UIButton *btn in self.modeButtons) {
        BOOL isSelected = (btn == selectedButton);
        btn.selected = isSelected;

        if (isSelected) {
            [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        } else {
            [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        }
    }

    NSString *title = selectedButton.titleLabel.text ?: @"";
    self.currentModeLabel.text = [NSString stringWithFormat:@"Current: %@", title.uppercaseString];
}

#pragma mark - Save button

- (IBAction)saveButtonTapped:(UIButton *)sender {
    // APPLY the selected protocol, not the save button tag
    [self setInventoryProtocol:self.selectedProtocol];
}

#pragma mark - Save & Restore

- (void)saveSelectedProtocol:(SRFID_ENUM_INVENTORY_PROTOCOL)protocol {
    [[NSUserDefaults standardUserDefaults] setInteger:protocol forKey:SELECTED_PROTOCOL_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)restoreSelectedProtocol {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults objectForKey:SELECTED_PROTOCOL_KEY] != nil) {
        SRFID_ENUM_INVENTORY_PROTOCOL p = (SRFID_ENUM_INVENTORY_PROTOCOL)[defaults integerForKey:SELECTED_PROTOCOL_KEY];
        
        switch (p) {
            case GEN2:   [self setSelectedModeButton:self.gen2Button]; break;
            case GEN2X:  [self setSelectedModeButton:self.gen2xButton]; break;
            case HYBRID: [self setSelectedModeButton:self.hybridButton]; break;
            default:     [self setSelectedModeButton:self.gen2Button];  break;
        }
    } else {
        // First time — default to GEN2
        [self setSelectedModeButton:self.gen2Button];
    }
}

#pragma mark - Set Inventory Protocol (unified)

-(void)getProtocol {

    NSString *status = nil;
    SRFID_ENUM_INVENTORY_PROTOCOL protocolEnum;
    SRFID_RESULT result = [[ZebraServiceEngine sharedInstance]
                           getReaderInventoryProtocol:&protocolEnum
                           aStatusMessage:&status];

    if (result == SRFID_RESULT_SUCCESS) {

        [self saveSelectedProtocol:protocolEnum];

        self.selectedProtocol = protocolEnum;
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (protocolEnum) {
                case GEN2:
                    [self setSelectedModeButton:self.gen2Button];
                    break;
                case GEN2X:
                    [self setSelectedModeButton:self.gen2xButton];
                    break;
                case HYBRID:
                    [self setSelectedModeButton:self.hybridButton];
                    break;
                default:
                    [self setSelectedModeButton:self.gen2Button];
                    break;
            }
        });

    } else {
        NSLog(@"Failed to get protocol. Status: %@", status);
    }
}

-(void)setInventoryProtocol:(SRFID_ENUM_INVENTORY_PROTOCOL)protocol {
//    int connectedId = [[ZebraServiceEngine sharedInstance] getConnectedReaderId];
    SRFID_RESULT result = SRFID_RESULT_FAILURE;
    NSString *status = nil;
    NSString *protocolName;
       switch (protocol) {
           case GEN2:
               protocolName = @"GEN2";
               break;
           case GEN2X:
               protocolName = @"GEN2X";
               break;
           case HYBRID:
               protocolName = @"HYBRID";
               break;
           default:
               protocolName = @"UNKNOWN";
               break;
       }
    
    result = [[ZebraServiceEngine sharedInstance]  setReaderInventoryProtocol:protocol aStatusMessage:&status];

    if (result == SRFID_RESULT_SUCCESS) {
        // Save selection only on success
        [[NSUserDefaults standardUserDefaults]
            setBool:YES
             forKey:@"InvProtocolChanged"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self saveSelectedProtocol:protocol];
        [self getProtocol];
    }
    
    NSString *prefix = (result == SRFID_RESULT_SUCCESS) ? @"Success" : @"Failed";
    NSString *message = [NSString stringWithFormat:@"%@: Inventory protocol set to %@", prefix, protocolName];
    [self showAlertMessageWithTitle:ZT_RFID_APP_NAME withMessage:message];
}

#pragma mark - Alert Helper

/// Display alert message
/// @param title Title string
/// @param message Message string
-(void)showAlertMessageWithTitle:(NSString*)title withMessage:(NSString*)message {
    [AlertViewHelper showAlertOn:self
                       title:title
                     message:message];
}


@end
