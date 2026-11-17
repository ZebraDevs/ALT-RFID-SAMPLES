//
//  MenuVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MenuVC : BaseViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    BOOL inventoryRequested;
    IBOutlet UITableView *tableView;
    
}
@property (nonatomic, strong) NSArray *dataArray;

@end
NS_ASSUME_NONNULL_END
