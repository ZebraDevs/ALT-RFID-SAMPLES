//
//  ImpinjCustomTableViewCell.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ImpinjCustomTableViewCell;

@protocol CustomTableViewCellDelegate <NSObject>
- (void)customCellCheckBoxButtonTapped:(ImpinjCustomTableViewCell *)cell;
@end

@interface ImpinjCustomTableViewCell : UITableViewCell
{

}

@property (weak, nonatomic) id<CustomTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;
@property (assign, nonatomic) BOOL checked;
- (void)updateCheckboxImage;

@property (nonatomic, weak) IBOutlet UILabel *lblImpinjTagID;
@property (nonatomic, weak) IBOutlet UILabel *lblImpinjTagReadCount;
@property (nonatomic, weak) IBOutlet UILabel *lblImpinjReadCount;
@property (nonatomic, weak) IBOutlet UILabel *lblImpinjReadRate;
@property (nonatomic, weak) IBOutlet UILabel *lblImpinjRSSI;

@end

NS_ASSUME_NONNULL_END
