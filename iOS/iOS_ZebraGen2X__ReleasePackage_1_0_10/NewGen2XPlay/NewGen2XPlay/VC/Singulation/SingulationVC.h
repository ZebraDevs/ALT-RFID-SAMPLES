//
//  SingulationVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>
#import "SelectionVC.h"
#import "ZebraServiceEngine.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SingulationVC : BaseViewController<SelectionVCDelegate> {
    srfidSingulationConfig *singulationConfig;
    NSArray *sessionArray;
    NSArray *invStateArray;
    NSArray *slFlagArray;
}

@property (weak, nonatomic) IBOutlet UITextField *txtSession;
@property (weak, nonatomic) IBOutlet UITextField *txtTagPopulation;
@property (weak, nonatomic) IBOutlet UITextField *txtInventoryState;
@property (weak, nonatomic) IBOutlet UITextField *txtSlFlag;

@property (weak, nonatomic) IBOutlet UIButton *saveSingulationPressed;





@end

NS_ASSUME_NONNULL_END
