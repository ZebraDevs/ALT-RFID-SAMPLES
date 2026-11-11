//
//  PreFilterVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-19.
//

#import <UIKit/UIKit.h>
#import "SelectionVC.h"
#import "ZebraServiceEngine.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreFilterVC : BaseViewController<SelectionPrefilterDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtTarget;
@property (weak, nonatomic) IBOutlet UITextField *txtAction;
@property (weak, nonatomic) IBOutlet UITextField *txtMemoryBank;
@property (weak, nonatomic) IBOutlet UITextField *txtTagPattern;
@property (weak, nonatomic) IBOutlet UITextField *txtTagPointer;
@property (weak, nonatomic) IBOutlet UITextField *txtTagLength;
@property (weak, nonatomic) IBOutlet UITextField *txtPreFilterList;
@property (nonatomic, assign) BOOL didNavigateToSelectionVC;
@property (nonatomic, strong) NSMutableArray *prefilterArray;
@end

NS_ASSUME_NONNULL_END
