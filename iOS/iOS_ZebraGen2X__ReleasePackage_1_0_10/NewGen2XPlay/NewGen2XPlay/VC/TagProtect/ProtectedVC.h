//
//  ProtectedVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>
#import "ZebraServiceEngine.h"
#import "InventoryVC.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProtectedVC : BaseViewController<UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource, InventoryVCDelegate>
{
    IBOutlet UIPickerView *m_PickerTagProtectMode;
    IBOutlet UITextField *m_TagPatternTxtField;
    
    IBOutlet UITextField *m_TagPasswordTxtField;
    
    IBOutlet UIButton *m_BtnPerformOperation;
    NSString *selectedOption ;
    BOOL isSelected_EnableVisibilityBtn;
    BOOL isSelected_DisableVisibilityBtn;
    
    
}
@end

NS_ASSUME_NONNULL_END
