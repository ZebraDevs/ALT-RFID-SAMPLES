//
//  ReaderListVCTableViewCell.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReaderListVCTableViewCell : UITableViewCell {
    
    IBOutlet UILabel *lblImpinjTagID;
    IBOutlet UILabel *lblImpinjTagReadCount;
    IBOutlet UILabel *lblImpinjReadCount;
    IBOutlet UILabel *lblImpinjReadRate;
    
}

@end

NS_ASSUME_NONNULL_END
