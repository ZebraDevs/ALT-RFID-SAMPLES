//
//  BaseViewController.m
//  NewGen2XPlay
//
//  Created by Kakarlapudi, Prudhvi on 15/04/26.
//
#import "BaseViewController.h"
#import "AppConstants.h"
#import "ZebraServiceEngine.h"

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (![self shouldShowInfoButton]) return;

    // If already present, don't add again
    for (UIBarButtonItem *item in (self.navigationItem.rightBarButtonItems ?: @[])) {
        if (item.action == @selector(infoButtonTapped)) {
            return;
        }
    }

    UIImage *infoButtonImage = [UIImage systemImageNamed:@"info"];
    UIBarButtonItem *infoItem =
        [[UIBarButtonItem alloc] initWithImage:infoButtonImage
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(infoButtonTapped)];
    infoItem.tintColor = UIColor.labelColor;

    NSMutableArray<UIBarButtonItem *> *items =
        [self.navigationItem.rightBarButtonItems mutableCopy] ?: [NSMutableArray new];

    // Put info on the far right. If you prefer it left of refresh, use insertObject:atIndex:0
    [items insertObject:infoItem atIndex:0];

    self.navigationItem.rightBarButtonItems = items;
}


- (BOOL)shouldShowInfoButton {
    return YES;
}

- (void)infoButtonTapped {
    NSString *appVersion =
        [@"App Version: " stringByAppendingString:
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    NSString *sdkVersion =
        [@"\nSDK Version: " stringByAppendingString:
         [[ZebraServiceEngine sharedInstance] getSDKVersion]];

    NSString *msg = [appVersion stringByAppendingString:sdkVersion];

    UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:APP_INFO
                                            message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];

    [alertController addAction:ok];

    // Present safely even if something else is being presented
    UIViewController *presenter = self.presentedViewController ?: self;
    [presenter presentViewController:alertController animated:YES completion:nil];
}

@end
