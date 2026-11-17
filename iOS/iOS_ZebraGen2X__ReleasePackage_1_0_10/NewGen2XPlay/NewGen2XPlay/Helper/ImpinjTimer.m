//
//  ImpinjTimer.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-03-04.
//

#import "ImpinjTimer.h"

@implementation ImpinjTimer
// START the timer
- (void)startTimer {
    // Invalidate any existing timer first to avoid duplicates
    [self stopTimer];
    
    // Fire every 1.0 second, repeating
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
}

// STOP the timer
- (void)stopTimer {
    if (self.myTimer) {
        [self.myTimer invalidate];
        self.myTimer = nil;
    }
}

// Called each time the timer fires
- (void)timerFired:(NSTimer *)timer {
    NSLog(@"Timer fired!");
}
@end
