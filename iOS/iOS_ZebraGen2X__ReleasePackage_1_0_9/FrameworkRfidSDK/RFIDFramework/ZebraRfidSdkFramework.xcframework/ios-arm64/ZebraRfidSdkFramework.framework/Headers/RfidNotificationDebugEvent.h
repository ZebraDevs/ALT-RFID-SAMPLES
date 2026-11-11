//
//  RfidNotificationDebugEvent.h
//  SymbolRfidSdk
//
//  Created by Ranga, Manoj on 2026-08-13.
//  Copyright © 2026 Motorola Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface srfidNotificationDebugEvent : NSObject
{
    NSString *message;
    int level;
}

- (int) getLevel;
- (void) setLevel:(int)val;
- (NSString *) getMessage;
- (void) setMessage:(NSString *)val;

@end
