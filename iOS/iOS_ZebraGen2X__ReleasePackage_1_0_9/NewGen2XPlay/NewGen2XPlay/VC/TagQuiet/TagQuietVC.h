//
//  TagQuietVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>
#import "SelectionVC.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TagQuietVC : BaseViewController<SelectionCustomTagQuiteDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtTagQuietMask1;
@property (weak, nonatomic) IBOutlet UITextField *txtTagQuietMask2;
@property (weak, nonatomic) IBOutlet UITextField *txtTagQuietMask3;
@property (weak, nonatomic) IBOutlet UITextField *txtAction;
@property (weak, nonatomic) IBOutlet UITextField *txtTarget;

@end

NS_ASSUME_NONNULL_END
