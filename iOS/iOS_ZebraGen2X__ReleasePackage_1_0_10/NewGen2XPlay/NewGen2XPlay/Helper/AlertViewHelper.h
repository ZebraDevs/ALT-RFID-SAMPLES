//
//  AlertViewHelper.h
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 21/05/26.
//

#import <UIKit/UIKit.h>

@interface AlertViewHelper : NSObject

+ (void)showAlertOn:(UIViewController *)viewController
              title:(NSString *)title
            message:(NSString *)message;

+ (void)showAlertOn:(UIViewController *)viewController
              title:(NSString *)title
            message:(NSString *)message
       actionTitles:(NSArray<NSString *> *)actionTitles
         completion:(void (^)(NSInteger index))completion;

@end
