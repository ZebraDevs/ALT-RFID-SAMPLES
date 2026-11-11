//
//  AlertViewHelper.m
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 21/05/26.
//

#import "AlertViewHelper.h"

@implementation AlertViewHelper

+ (void)showAlertOn:(UIViewController *)viewController
              title:(NSString *)title
            message:(NSString *)message {
    [self showAlertOn:viewController
                title:title
              message:message
         actionTitles:@[@"OK"]
           completion:nil];
}

+ (void)showAlertOn:(UIViewController *)viewController
              title:(NSString *)title
            message:(NSString *)message
       actionTitles:(NSArray<NSString *> *)actionTitles
         completion:(void (^)(NSInteger index))completion {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    for (NSInteger i = 0; i < actionTitles.count; i++) {
        NSString *buttonTitle = actionTitles[i];

        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion(i);
            }
        }];
        [alert addAction:action];
    }

    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
