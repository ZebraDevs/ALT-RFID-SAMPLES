//
//  ImpinjCustomTableViewCell.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-27.
//

#import "ImpinjCustomTableViewCell.h"

@implementation ImpinjCustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.checkboxButton addTarget:self
                                action:@selector(checkboxTapped:)
                      forControlEvents:UIControlEventTouchUpInside];
    
   
    // Initialization code
}
- (void)checkboxTapped:(id)sender {
    // Notify the delegate (your ViewController) that the button was tapped
//    if ([self.delegate respondsToSelector:@selector(customCellCheckBoxButtonTapped:)]) {
//        
//        [self.delegate customCellCheckBoxButtonTapped:self];
//        
//    }
    [self.delegate customCellCheckBoxButtonTapped:self];
   // [self updateCheckboxImage];
}

- (void)updateCheckboxImage {
    //checkbox_checked_icon  checkbox_icon
   NSString *imageName = self.checked ? @"checkbox_checked_icon" : @"checkbox_icon";
   // NSString *imageName = self.checked ? @"checkbox_icon" : @"checkbox_checked_icon";
    [self.checkboxButton setImage:[UIImage imageNamed:imageName]
                         forState:UIControlStateNormal];
    //self.checked = FALSE;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Create UI elements programmatically
//        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 20)];
//        [self.contentView addSubview:self.titleLabel];
//
//        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 300, 15)];
//        self.subtitleLabel.textColor = [UIColor grayColor];
//        [self.contentView addSubview:self.subtitleLabel];
    }
    return self;
}
@end
