//
//  readRateAlertView.h
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 15/04/26.
//

// CustomAlertView.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReadRateAlertView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *totalReadsLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UILabel *readRateLabel;
// We can add a completion block to know when the dismiss button is tapped.
@property (nonatomic, copy) void (^dismissAction)(void);

- (void)configureWithTotalReads:(NSInteger)totalReads
                      totalTime:(NSTimeInterval)totalTimeSeconds
                       readRate:(double)readRate;

@end

NS_ASSUME_NONNULL_END
