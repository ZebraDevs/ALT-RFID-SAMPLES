//
//  SelectionVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@class SelectionVC;
@protocol SelectionVCDelegate <NSObject>
- (void)sessionValue:(SelectionVC *)controller didFinishSelectSession:(NSString *)text;
- (void)tagPopulationValue:(SelectionVC *)controller didFinishSelectTagPopulationValue:(NSString *)text;
- (void)inventoryStateValue:(SelectionVC *)controller didFinishSelectInventoryStateValue:(NSString *)text;
- (void)slFlageValue:(SelectionVC *)controller didFinishSelectSlFlagValue:(NSString *)text;

@end

@protocol SelectionCustomTagQuiteDelegate <NSObject>
- (void)tagQuietMask1:(SelectionVC *)controller didFinishSelectTagQuietMask:(NSString *)text;
- (void)tagQuietMask2:(SelectionVC *)controller didFinishSelectTagQuietMask:(NSString *)text;
- (void)tagQuietMask3:(SelectionVC *)controller didFinishSelectTagQuietMask:(NSString *)text;
- (void)action:(SelectionVC *)controller didFinishSelectAction:(NSString *)text;
- (void)target:(SelectionVC *)controller didFinishSelectTarget:(NSString *)text;
@end

@protocol SelectionPrefilterDelegate <NSObject>
- (void)actionPreFilter:(SelectionVC *)controller didFinishSelectAction:(NSString *)text;
- (void)targetPreFilter:(SelectionVC *)controller didFinishSelectTarget:(NSString *)text;
- (void)memoryBankPreFilter:(SelectionVC *)controller didFinishSelectMemory:(NSString *)text;
- (void)filterListPreFilter:(SelectionVC *)controller didFinishFilterList:(NSString *)text;

@end


@interface SelectionVC : BaseViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    BOOL inventoryRequested;
    IBOutlet UITableView *tableView;
    
  
}

//id<BViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *dataArraySession;
@property (nonatomic, weak) id<SelectionVCDelegate> delegate;
@property (nonatomic, weak) id<SelectionCustomTagQuiteDelegate> delegateTagQuiet;
@property (nonatomic, weak) id<SelectionPrefilterDelegate> delegatePreFilter;

@property (nonatomic, strong) NSString *singulationSettingData;


@end

NS_ASSUME_NONNULL_END
