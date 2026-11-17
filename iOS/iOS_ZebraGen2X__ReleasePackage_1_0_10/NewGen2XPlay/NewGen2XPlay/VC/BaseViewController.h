//
//  BaseViewController.h
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 15/04/26.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
/// Override in a subclass only if you need to hide the info button on some screen.
- (BOOL)shouldShowInfoButton;
@end
