//
//  ReadRateAlertView.m
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 15/04/26.
//

#import "ReadRateAlertView.h"

@implementation ReadRateAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self setupSubviews];
        [self setupLayout];
    }
    return self;
}

// Basic view styling
- (void)setupView {
    self.backgroundColor = [UIColor systemGray6Color];
    self.layer.cornerRadius = 14.0;
    self.layer.masksToBounds = YES;
}

// Create and configure all the UI elements
- (void)setupSubviews {
//    UIImage *iconImage = [UIImage systemImageNamed:@"chart.bar.xaxis"];
//    self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
//    self.iconImageView.tintColor = [UIColor blackColor];
//    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:self.iconImageView];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"📊 Read Rate";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.titleLabel.textColor = [UIColor labelColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];

    // ---- Create the 3 labels (IMPORTANT) ----
    self.totalReadsLabel = [[UILabel alloc] init];
    self.totalReadsLabel.font = [UIFont systemFontOfSize:15.0];
    self.totalReadsLabel.textColor = [UIColor darkGrayColor];
    self.totalReadsLabel.textAlignment = NSTextAlignmentLeft;
    self.totalReadsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.totalReadsLabel];

    self.totalTimeLabel = [[UILabel alloc] init];
    self.totalTimeLabel.font = [UIFont systemFontOfSize:15.0];
    self.totalTimeLabel.textColor = [UIColor darkGrayColor];
    self.totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.totalTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.totalTimeLabel];

    self.readRateLabel = [[UILabel alloc] init];
    self.readRateLabel.font = [UIFont systemFontOfSize:15.0];
    self.readRateLabel.textColor = [UIColor darkGrayColor];
    self.readRateLabel.textAlignment = NSTextAlignmentLeft;
    self.readRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.readRateLabel];

    // Button
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.dismissButton setTitle:@"OK" forState:UIControlStateNormal];
    self.dismissButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [self.dismissButton addTarget:self action:@selector(dismissButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.dismissButton];

    // Optional defaults (so it shows something before configure is called)
    self.totalReadsLabel.text = @"Total Reads: 0";
    self.totalTimeLabel.text = @"Total Time: 00:00";
    self.readRateLabel.text = @"Read Rate: 0.00 reads/sec";
}

- (void)setupLayout {
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:20],
        
        // Total Reads
        [self.totalReadsLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.totalReadsLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.totalReadsLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12],
        // Total Time
        [self.totalTimeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.totalTimeLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.totalTimeLabel.topAnchor constraintEqualToAnchor:self.totalReadsLabel.bottomAnchor constant:8],
        
        // Read Rate
        [self.readRateLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self.readRateLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [self.readRateLabel.topAnchor constraintEqualToAnchor:self.totalTimeLabel.bottomAnchor constant:8],
        
        [self.dismissButton.topAnchor constraintEqualToAnchor:self.readRateLabel.bottomAnchor constant:20],
        [self.dismissButton.heightAnchor constraintEqualToConstant:44],
        [self.dismissButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.dismissButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.dismissButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
    
    [self createSeparatorLineForButton:self.dismissButton];
}

- (void)createSeparatorLineForButton:(UIButton *)button {
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separator];

    [NSLayoutConstraint activateConstraints:@[
        [separator.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [separator.heightAnchor constraintEqualToConstant:0.5],
        [separator.bottomAnchor constraintEqualToAnchor:button.topAnchor]
    ]];
}
- (void)dismissButtonTapped {
    if (self.dismissAction) {
        self.dismissAction();
    }
}

- (void)configureWithTotalReads:(NSInteger)totalReads
                      totalTime:(NSTimeInterval)totalTimeSeconds
                       readRate:(double)readRate
{
    NSInteger minutes = (NSInteger)(totalTimeSeconds / 60.0);
    NSInteger seconds = (NSInteger)lrint(fmod(totalTimeSeconds, 60.0));

    self.totalReadsLabel.text = [NSString stringWithFormat:@"Total Reads: %ld", (long)totalReads];
    self.totalTimeLabel.text  = [NSString stringWithFormat:@"Total Time: %02ld:%02ld", (long)minutes, (long)seconds];
    self.readRateLabel.text   = [NSString stringWithFormat:@"Read Rate: %.2f reads/sec", readRate];
}

@end
