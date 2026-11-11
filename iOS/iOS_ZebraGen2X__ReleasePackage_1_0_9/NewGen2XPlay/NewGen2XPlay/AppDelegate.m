//
//  AppDelegate.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-16.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIColor *bg = [UIColor colorWithRed:66.0/255.0 green:135.0/255.0 blue:245.0/255.0 alpha:1.0];
    UIColor *fg = [UIColor whiteColor];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = bg;
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName : fg };
        appearance.largeTitleTextAttributes = @{ NSForegroundColorAttributeName : fg };

        UINavigationBar *bar = [UINavigationBar appearance];
        bar.standardAppearance = appearance;
        bar.scrollEdgeAppearance = appearance;
        bar.compactAppearance = appearance;
        bar.tintColor = fg; // bar button items
    } else {
        [[UINavigationBar appearance] setBarTintColor:bg];     // background
        [[UINavigationBar appearance] setTintColor:fg];        // bar button items
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: fg}];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"SavedInventoryTime"];
    [defaults removeObjectForKey:@"SavedQuietTime"];
    [defaults synchronize];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"FastIDEnabled"];
    [defaults setBool:NO forKey:@"enableVS"];
    [defaults setBool:NO forKey:@"TagFocusEnabled"];
    [defaults setBool:NO forKey:@"TagQuietEnabled"];
    [defaults setBool:NO forKey:@"IsInventoryRunning"];
    [defaults removeObjectForKey:@"SelectedTagID"];
    
    [defaults removeObjectForKey:@"TagQuiet_Mask1"];
    [defaults removeObjectForKey:@"TagQuiet_Mask2"];
    [defaults removeObjectForKey:@"TagQuiet_Mask3"];
    [defaults removeObjectForKey:@"TagQuiet_Action"];
    [defaults removeObjectForKey:@"TagQuiet_Target"];
    
    [defaults removeObjectForKey:@"InvProtocolChanged"];
    [defaults removeObjectForKey:@"ProtectTagEnabled"];
    
    [defaults removeObjectForKey:@"SavedInventoryTime"];
    [defaults removeObjectForKey:@"SavedQuietTime"];
   

    [defaults synchronize];
}


@end
