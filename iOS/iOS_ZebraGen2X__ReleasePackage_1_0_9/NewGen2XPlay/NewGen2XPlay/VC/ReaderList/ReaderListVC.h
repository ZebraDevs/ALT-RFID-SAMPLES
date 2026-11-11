//
//  ReaderListVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>
#import "ZebraServiceEngine.h"
#import "ReaderListVCTableViewCell.h"
#import "ReaderModel.h"
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReaderListVC : BaseViewController<ReaderEventDelegate>
{

    
    IBOutlet UITableView *readerListTableView;
    BOOL isConnected;


}

@end

NS_ASSUME_NONNULL_END
