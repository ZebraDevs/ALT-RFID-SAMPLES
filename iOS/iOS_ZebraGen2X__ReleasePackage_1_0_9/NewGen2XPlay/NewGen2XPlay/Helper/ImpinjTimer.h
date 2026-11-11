//
//  ImpinjTimer.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-03-04.
//

#import <Foundation/Foundation.h>



@interface ImpinjTimer : NSObject
@property (nonatomic, strong) NSTimer *myTimer;

- (void)startTimer;
- (void)stopTimer;
- (void)timerFired:(NSTimer *)timer;

@end


