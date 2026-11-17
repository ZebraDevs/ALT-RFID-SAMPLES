//
//  InventoryVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-23.
//

#import "InventoryVC.h"
#import "ImpinjCustomTableViewCell.h"
#import "ReadRateAlertView.h"
// Start and Stop icons for scanner start and stop action.
#define START_SCAN_ICON @"start_scan_icon"
#define STOP_SCAN_ICON @"stop_scan_icon"

#define MAX_SELECTED_TAGS 31
#define BATCH_SIZE 31

#define DEFAULT_QUIET_CYCLE_INTERVAL 4.0


@interface InventoryCache : NSObject

@property (nonatomic, strong) NSMutableArray *tagDataInventory;
@property (nonatomic, strong) NSMutableDictionary *tagCountDictionary;
@property (nonatomic, strong) NSMutableDictionary *tagReadRateDictionary;
@property (nonatomic, strong) NSMutableDictionary *tagAvgReadRateDictionary;
@property (nonatomic, strong) NSMutableArray *checkedStates;
@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic, strong) NSMutableArray *currentlySelectedTagIdObjectArray;
@property (nonatomic, strong) NSMutableSet *quietedTagIDs;
@property (nonatomic, assign) NSInteger totalReadCount;
@property (nonatomic, strong) NSDate *scanStartTime;
@property (nonatomic, assign) BOOL isQuietCycleActive;

// ── New properties ──
@property (nonatomic, assign) BOOL inventoryRunning;
@property (nonatomic, strong) NSDate *inventoryStartTime;
@property (nonatomic, strong) NSDate *inventoryAutoStopDate;
@property (nonatomic, assign) NSInteger autoStopSeconds;
@property (nonatomic, assign) int secondsElapsed;

+ (instancetype)sharedCache;
@end

@implementation InventoryCache
+ (instancetype)sharedCache {
    static InventoryCache *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        shared.tagDataInventory = [NSMutableArray array];
        shared.tagCountDictionary = [NSMutableDictionary dictionary];
        shared.tagReadRateDictionary = [NSMutableDictionary dictionary];
        shared.tagAvgReadRateDictionary = [[NSMutableDictionary alloc] init];
        shared.checkedStates = [NSMutableArray array];
        shared.selectedRows = [NSMutableArray array];
        shared.currentlySelectedTagIdObjectArray = [NSMutableArray array];
        shared.quietedTagIDs = [NSMutableSet set];
        shared.totalReadCount = 0;
        shared.scanStartTime = nil;
        shared.isQuietCycleActive = NO;
        shared.inventoryRunning = NO;
        shared.inventoryStartTime = nil;
        shared.inventoryAutoStopDate = nil;
        shared.autoStopSeconds = 0;
        shared.secondsElapsed = 0;
    });
    return shared;
}
@end

@interface InventoryVC ()
@property(atomic, assign) BOOL inventoryRunning;
@property(atomic, assign) BOOL inventoryStartStopInProgress;

@property(nonatomic, strong) NSTimer *quietCycleTimer;
@property(nonatomic, assign) NSInteger currentQuietChunkIndex;
@property(nonatomic, assign) BOOL isQuietCycleActive;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) ReadRateAlertView *readRateAlert;
@property(nonatomic, assign) double globalAverageRate;
@property(atomic, assign) BOOL isQuietTransitioning;
@property (nonatomic, assign) BOOL autoQuietNewTags;

@property(nonatomic, strong) NSMutableArray *quietBatches;
@property(nonatomic, assign) NSInteger currentBatchIndex;
@property(nonatomic, assign) NSTimeInterval quietCycleInterval;


@property (nonatomic, strong) NSMutableDictionary *quietRetryCount;
@property(nonatomic, assign) NSInteger currentBatchRetryCount;
@property(nonatomic, assign) NSInteger globalRetryRound;

@property(nonatomic, strong) NSMutableDictionary *countSnapshotBeforeVerify;

// EPCs the cycle is responsible for quieting, in the order they were discovered.
@property (nonatomic, strong) NSMutableOrderedSet<NSString *> *quietTargetTagIDs;
// YES when the cycle started from a full-inventory selection, in which case tags
// discovered mid-cycle are adopted into the target set.
@property (nonatomic, assign) BOOL quietAdoptsNewTags;

// Coalesces the expensive recalculateColorCounts + tableView reload so it runs at
// a bounded rate instead of once per tag read. Doing that work per-read made each
// event cost grow with the tag count, which backed up the main queue and starved
// the quiet cycle (and the reader's live Inventory airtime) of main-thread time.
@property (nonatomic, strong) NSTimer *uiRefreshTimer;
@property (nonatomic, assign) BOOL pendingTagUIRefresh;

@end

@implementation InventoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [ZebraServiceEngine sharedInstance].delegateTagDataEvent = self;
    
    self->tblImpinjInventory.delegate = self;
    self->tblImpinjInventory.dataSource = self;
    self.secondsElapsed = 0;
    // Do any additional setup after loading the view.
    
    // --- POINT ARRAYS TO CACHE ---
    InventoryCache *cache = [InventoryCache sharedCache];
    _tagDataInventory = cache.tagDataInventory;
    _tagCountDictionary = cache.tagCountDictionary;
    _tagReadRateDictionary = cache.tagReadRateDictionary;
    _tagAvgReadRateDictionary = cache.tagAvgReadRateDictionary;
    _selectedRows = cache.selectedRows;
    _currentlySelectedTagIdObjectArray = cache.currentlySelectedTagIdObjectArray;
    _quietedTagIDs = cache.quietedTagIDs;
    self.checkedStates = cache.checkedStates;
    self->_totalReadCount = cache.totalReadCount;
    self->_scanStartTime = cache.scanStartTime;
    self.isQuietCycleActive = cache.isQuietCycleActive;
    // ------------------------------------------------
    
    _uniqueTagCountAtLastInterval = 0; //
    
    _quietedTagIDs = [NSMutableSet set];
    
    coutGreen = 0;
    coutGray = 0;
    coutWhite = 0;
    coutYellow = 0;
    //    [self defultFastIDMode];
    self.inventoryRunning = NO;
    self.inventoryStartStopInProgress = NO;
    
    self->txtInventoryTime.delegate = self;
    self->txtQuietTime.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarRight];

    // --- RESTORE UI FROM CACHE ---
    [self recalculateColorCounts];
    [self->tblImpinjInventory reloadData];
    [self updateSelectAllButtonState];
    self->lbGrayCount.text   = [[NSNumber numberWithInt:self->coutGray] stringValue];
    self->lbGreenCount.text  = [[NSNumber numberWithInt:self->coutGreen] stringValue];
    self->lbYellowCount.text = [[NSNumber numberWithInt:self->coutYellow] stringValue];
    self->lbWhiteCount.text  = [[NSNumber numberWithInt:self->coutWhite] stringValue];
    self->lbUniqeCount.text  = [NSString stringWithFormat:@"%lu",
                                (unsigned long)[self->_tagDataInventory count]];

    // ── Restore persisted text field values ──
    NSString *savedInventoryTime = [[NSUserDefaults standardUserDefaults]
                                    stringForKey:@"SavedInventoryTime"];
    if (savedInventoryTime.length > 0) {
        self->txtInventoryTime.text = savedInventoryTime;
    }
    NSString *savedQuietTime = [[NSUserDefaults standardUserDefaults]
                                stringForKey:@"SavedQuietTime"];
    if (savedQuietTime.length > 0) {
        self->txtQuietTime.text = savedQuietTime;
    }

    [[ZebraServiceEngine sharedInstance] addTriggerEventDelegate:self];

    BOOL isRunning = [InventoryCache sharedCache].inventoryRunning || [InventoryCache sharedCache].isQuietCycleActive;
    
    if (isRunning) {
        // ── Restore from cache ──
        self.inventoryRunning = YES;
        [UIView performWithoutAnimation:^{
            [btnImpinjInvStart setImage:[UIImage imageNamed:STOP_SCAN_ICON]
                               forState:UIControlStateNormal];
            [btnImpinjInvStart setSelected:YES];
            [btnImpinjInvStart layoutIfNeeded];
        }];
        
        // ── Compute elapsed time from cache start time ──
        NSDate *startTime = [InventoryCache sharedCache].inventoryStartTime;
        if (startTime) {
            self.secondsElapsed = (int)[[NSDate date] timeIntervalSinceDate:startTime];
        } else {
            self.secondsElapsed = [InventoryCache sharedCache].secondsElapsed;
        }
        
        int minutes = self.secondsElapsed / 60;
        int seconds = self.secondsElapsed % 60;
        self->lbTimer.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        
        // Fresh countdown timer
        self.countdownTimer = [NSTimer timerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.countdownTimer
                                  forMode:NSRunLoopCommonModes];
        
        // ── Restore auto-stop timer from cache ──
        [self.inventoryAutoStopTimer invalidate];
        self.inventoryAutoStopTimer = nil;
        NSDate *autoStopDate = [InventoryCache sharedCache].inventoryAutoStopDate;
        if (autoStopDate) {
            NSTimeInterval remaining = [autoStopDate timeIntervalSinceNow];
            if (remaining > 0) {
                self.inventoryAutoStopTimer = [NSTimer timerWithTimeInterval:remaining
                                                                      target:self
                                                                    selector:@selector(autoStopInventory)
                                                                    userInfo:nil
                                                                     repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:self.inventoryAutoStopTimer
                                          forMode:NSRunLoopCommonModes];
            } else {
                [self autoStopInventory];
            }
        }
    } else {
        self.inventoryRunning = NO;
        [UIView performWithoutAnimation:^{
            [btnImpinjInvStart setImage:[UIImage imageNamed:START_SCAN_ICON]
                               forState:UIControlStateNormal];
            [btnImpinjInvStart setSelected:NO];
            [btnImpinjInvStart layoutIfNeeded];
        }];
        
        // Restore the cached elapsed time instead of wiping to 0
        self.secondsElapsed = [InventoryCache sharedCache].secondsElapsed;
        int minutes = self.secondsElapsed / 60;
        int seconds = self.secondsElapsed % 60;
        self->lbTimer.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[ZebraServiceEngine sharedInstance] removeTriggerEventDelegate:self];

    // ── Always invalidate the timer when leaving the view ──
    // This prevents multiple timer instances stacking up on the run loop
    // when viewWillAppear recreates it on every visit.
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;

    [self stopUIRefreshTimer];

    // ── Force save text field values before leaving ──
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *inventoryTime = [self->txtInventoryTime.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [defaults setObject:inventoryTime forKey:@"SavedInventoryTime"];
        
    NSString *quietTime = [self->txtQuietTime.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [defaults setObject:quietTime forKey:@"SavedQuietTime"];

    [defaults synchronize];
}

-(void)navigationBarRight {
    
    UIImage *img = [[UIImage imageNamed:@"ic_read_rate"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *readRateItem =
    [[UIBarButtonItem alloc] initWithImage:img
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showReadRateAlert)];
    
    NSMutableArray<UIBarButtonItem *> *items =
    [self.navigationItem.rightBarButtonItems mutableCopy] ?: [NSMutableArray new];
    
    // Put screen button closer to title (left side within right items)
    [items addObject:readRateItem];
    
    self.navigationItem.rightBarButtonItems = items;
    
}

- (void)showReadRateAlert {
    // Prevent showing multiple alerts
    if (self.readRateAlert) {
        return;
    }
    [self updateTimer];
    // Overlay
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    [self.view addSubview:self.overlayView];
    
    // Alert
    self.readRateAlert = [[ReadRateAlertView alloc] init];
    self.readRateAlert.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.readRateAlert];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.readRateAlert.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.readRateAlert.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.readRateAlert.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.8]
    ]];
    
    // ---- compute numbers from InventoryVC state ----
    NSInteger totalReads = self->_totalReadCount;
    NSTimeInterval elapsed = [self currentInventoryElapsedTime];
    double readRate = (elapsed > 0) ? ((double)totalReads / elapsed) : 0.0;
    
    [self.readRateAlert configureWithTotalReads:totalReads totalTime:elapsed readRate:readRate];
    
    __weak typeof(self) weakSelf = self;
    self.readRateAlert.dismissAction = ^{
        [weakSelf dismissreadRateAlert];
    };
    
    // Animate
    self.overlayView.alpha = 0;
    self.readRateAlert.alpha = 0;
    self.readRateAlert.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.overlayView.alpha = 1;
        weakSelf.readRateAlert.alpha = 1;
        weakSelf.readRateAlert.transform = CGAffineTransformIdentity;
    }];
}

// --- Method to hide and clean up the alert ---
- (void)dismissreadRateAlert {
    [UIView animateWithDuration:0.25 animations:^{
        self.overlayView.alpha = 0;
        self.readRateAlert.alpha = 0;
        self.readRateAlert.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [self.overlayView removeFromSuperview];
        [self.readRateAlert removeFromSuperview];
        self.overlayView = nil;
        self.readRateAlert = nil;
    }];
}

- (NSTimeInterval)currentInventoryElapsedTime {
    return (NSTimeInterval)self.secondsElapsed;
}

- (void)defultFastIDMode {
    
    NSString *status = [[NSString alloc] init];
    
    [[ZebraServiceEngine sharedInstance] configureFastID:NO status:&status];
    [[ZebraServiceEngine sharedInstance] setFastIDEnableStatue:NO];
    
    [UIView performWithoutAnimation:^{
        [btnFastID setImage:[UIImage imageNamed:@"checkbox_icon"]
                   forState:UIControlStateNormal];
        [btnFastID setSelected:NO];
        [btnFastID layoutIfNeeded];
    }];
}

#pragma mark - Inventory Tag data  Delegate
- (void)eventTagDataRecived:(ZebraServiceEngine *)zebraServiceEngine
didFinishEventTagDataRecived:(srfidTagData *)tagData {
    NSString *newTagId = [tagData getTagId];
    
    _totalReadCount++;
    [InventoryCache sharedCache].totalReadCount = _totalReadCount; // Sync to cache
    
    // Use the global timer instead of the _scanStartTime
    NSTimeInterval elapsedTime = (NSTimeInterval)self.secondsElapsed;
    if (elapsedTime <= 0.0) {
        elapsedTime = 1.0; // Prevent division by zero on first instant
    }
    
    // Move ALL mutable collection mutations to the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self->_tagDataInventory) {
            self->_tagDataInventory = [NSMutableArray array];
        }
        if (!self->_tagCountDictionary) {
            self->_tagCountDictionary = [NSMutableDictionary dictionary];
        }
        if (!self->_tagReadRateDictionary) {
            self->_tagReadRateDictionary = [NSMutableDictionary dictionary];
        }
        
        // O(1) membership check via the dictionary instead of a linear scan over
        // the whole array on every single read. That scan — plus the full
        // recalculateColorCounts/reloadData below — used to cost O(n) per read and
        // only got slower as the inventory grew, which backed up the main queue and
        // delayed the quiet cycle's dispatch_sync in applyQuietToTagIDs, starving
        // the reader of the live-Inventory airtime it needs to actually beep.
        BOOL alreadyKnown = (self->_tagCountDictionary[newTagId] != nil);
        
        // Track occurrence count
        if (alreadyKnown) {
            int currentCount = [self->_tagCountDictionary[newTagId] intValue];
            if (currentCount == -1) {
                // Was marked for quieting but is still reporting → non-gen2x
                self->_tagCountDictionary[newTagId] = @(1);
            } else {
                currentCount++;
                self->_tagCountDictionary[newTagId] = @(currentCount);
            }
        } else {
            self->_tagCountDictionary[newTagId] = @(1);
            [self->_tagDataInventory addObject:tagData];
        }
        
        // Grow checkedStates (never rebuild)
        if (!self.checkedStates) {
            self.checkedStates = [NSMutableArray array];
        }
        while (self.checkedStates.count < self->_tagDataInventory.count) {
            [self.checkedStates addObject:@(NO)];
        }
        // Calculate read rate (only after 1 second)
        if (elapsedTime >= 1.0) {
            int tagCount = [self->_tagCountDictionary[newTagId] intValue];

            //    If this tag is currently marked as quieted (-1),
            //    do NOT update its rate. Writing a rate here would re-insert
            //    it into _tagAvgReadRateDictionary, causing the average to be
            //    skewed and non-quieted tags to show wrong green/gray colours.
            if (tagCount != -1) {
                double tagReadRate = tagCount / elapsedTime;
                self->_tagReadRateDictionary[newTagId] = @(tagReadRate);

                if (![self.quietedTagIDs containsObject:newTagId]) {
                    [self->_tagAvgReadRateDictionary setObject:@(tagReadRate) forKey:newTagId];
                }
            }
        }
        
        // Defer the expensive recalc + full table reload to a bounded-rate flush
        // (see flushPendingTagUIRefresh) instead of doing it on every single read.
        self.pendingTagUIRefresh = YES;
        [self startUIRefreshTimerIfNeeded];
    });
}

#pragma mark - Throttled UI Refresh

// Runs recalculateColorCounts + reloadData + label updates at a fixed cadence
// (instead of once per tag read) so the per-event cost stops growing with the
// size of the inventory. Mirrors Android's AVG_CALCULATION_INTERVAL / 1s timer
// pattern in InventoryAdapter/InventoryFragment, which never does this work
// inside the raw per-tag callback.
- (void)startUIRefreshTimerIfNeeded {
    if (self.uiRefreshTimer && [self.uiRefreshTimer isValid]) return;

    self.uiRefreshTimer = [NSTimer timerWithTimeInterval:0.25
                                                   target:self
                                                 selector:@selector(flushPendingTagUIRefresh)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.uiRefreshTimer forMode:NSRunLoopCommonModes];
}

- (void)stopUIRefreshTimer {
    [self flushPendingTagUIRefresh]; // show the latest state before we stop ticking
    [self.uiRefreshTimer invalidate];
    self.uiRefreshTimer = nil;
}

- (void)flushPendingTagUIRefresh {
    if (!self.pendingTagUIRefresh) return;
    self.pendingTagUIRefresh = NO;

    [self recalculateColorCounts];

    [self->tblImpinjInventory reloadData];
    self->lbUniqeCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self->_tagDataInventory count]];
    self->lbGrayCount.text = [[NSNumber numberWithInt:self->coutGray] stringValue];
    self->lbGreenCount.text = [[NSNumber numberWithInt:self->coutGreen] stringValue];
    self->lbYellowCount.text = [[NSNumber numberWithInt:self->coutYellow] stringValue];
    self->lbWhiteCount.text = [[NSNumber numberWithInt:self->coutWhite] stringValue];
}

#pragma mark - Unique Tag Interval Counter

- (void)updateNewUniqueTagCount {
    NSInteger currentTotal = [_tagDataInventory count];
    NSInteger newUniqueTags = currentTotal - _uniqueTagCountAtLastInterval;
    _uniqueTagCountAtLastInterval = currentTotal;
    
    lbNewUniqueTagCounter.text =
    [NSString stringWithFormat:@"New Unique tags every 10s : %ld",
     (long)newUniqueTags];
}

- (void)recalculateColorCounts {
    double sum = 0.0;
    int activeCount = 0;
    
    for (NSString *key in _tagAvgReadRateDictionary) {
        if ([_tagCountDictionary[key] intValue] == -1) continue;
        sum += [_tagAvgReadRateDictionary[key] doubleValue];
        activeCount++;
    }
    
    double averageRate = 0.0;
    if (activeCount > 0) {
        averageRate = sum / activeCount;
    }
    
    int greenCount = 0;
    int grayCount = 0;
    int whiteCount = 0;
    int yellowCount = 0;
    
    for (srfidTagData *tag in _tagDataInventory) {
        NSString *tagId = [tag getTagId];
        
        if ([_tagCountDictionary[tagId] intValue] == -1) {
            yellowCount++;
            continue;
        }
        
        NSNumber *rateNumber = _tagAvgReadRateDictionary[tagId];
        double rate = [rateNumber doubleValue];
        
        if (rate > averageRate) {
            greenCount++;
        } else if (rate < averageRate) {
            grayCount++;
        } else {
            whiteCount++;
        }
    }
    
    coutGreen = greenCount;
    coutGray = grayCount;
    coutWhite = whiteCount;
    coutYellow = yellowCount;
}

- (void)resetInventoryState {
    
    // Reset un-quiet button
    [UIView performWithoutAnimation:^{
        [self->btnTagUnquiet setImage:[UIImage imageNamed:@"checkbox_icon"] forState:UIControlStateNormal];
        [self->btnTagUnquiet setSelected:NO];
        [self->btnTagUnquiet layoutIfNeeded];
    }];
    
    // Reset select all button
    [UIView performWithoutAnimation:^{
        [self->btnSlectAllTags setImage:[UIImage imageNamed:@"checkbox_icon"] forState:UIControlStateNormal];
        [self->btnSlectAllTags setSelected:NO];
        [self->btnSlectAllTags layoutIfNeeded];
    }];
    
    //  Preserve tags with count == -1 (successfully quieted)
    NSMutableArray *quietedTagsToKeep = [NSMutableArray array];
    for (srfidTagData *tag in self->_tagDataInventory) {
        NSString *tagId = [tag getTagId];
        if ([self->_tagCountDictionary[tagId] intValue] == -1) {
            [quietedTagsToKeep addObject:tag];
        }
    }
    
    // Clear all data
    [self->_tagDataInventory removeAllObjects];
    [self->_tagCountDictionary removeAllObjects];
    [self->_tagReadRateDictionary removeAllObjects];
    [self->_tagAvgReadRateDictionary removeAllObjects];
    [self.checkedStates removeAllObjects];
    [self clearAllSelections];
    
    //  Restore quieted tags and their -1 counts
    [self->_tagDataInventory addObjectsFromArray:quietedTagsToKeep];
    for (srfidTagData *tag in quietedTagsToKeep) {
        self->_tagCountDictionary[[tag getTagId]] = @(-1);
    }
    
    // Restore checkedStates for the preserved quieted tags
    for (int i = 0; i < quietedTagsToKeep.count; i++) {
        [self.checkedStates addObject:@(NO)];
    }
    
    // Reset read rate tracking
    self->_scanStartTime = nil;
    self->_totalReadCount = 0;
    
    // Reset color counters
    self->coutGreen = 0;
    self->coutGray = 0;
    self->coutWhite = 0;
    self->coutYellow = (int)quietedTagsToKeep.count;
    
    // Reset unique tag interval counter
    self.uniqueTagCountAtLastInterval = quietedTagsToKeep.count;
    
    // Reset labels
    self->lbUniqeCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)quietedTagsToKeep.count];
    self->lbGreenCount.text = @"0";
    self->lbGrayCount.text = @"0";
    self->lbWhiteCount.text = @"0";
    self->lbYellowCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)quietedTagsToKeep.count];
    self->lbNewUniqueTagCounter.text = @"New Unique tags every 10s : 0";
    
    // Reload table
    [self->tblImpinjInventory reloadData];
}

#pragma mark - Tag Focus

- (IBAction)btnTagFocusChecked:(id)sender {
    
    if (btnTagFocus.isSelected) {
        
        // 1. Update UI immediately on the Main Thread
        [UIView performWithoutAnimation:^{
            [btnTagFocus setImage:[UIImage imageNamed:@"checkbox_icon"]
                         forState:UIControlStateNormal];
            [btnTagFocus setSelected:NO];
            [btnTagFocus layoutIfNeeded];
        }];
        
        dispatch_async(
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           SRFID_RESULT tagFocusResult = SRFID_RESULT_FAILURE;
                           NSString *status2 = [[NSString alloc] init];
                           tagFocusResult =
                           [[ZebraServiceEngine sharedInstance] enableTagFocus:NO
                                                                        status:&status2];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (tagFocusResult == SRFID_RESULT_SUCCESS) {
                                   [self->_tagDataInventory removeAllObjects];
                                   [self clearAllSelections];
                                   [self->tblImpinjInventory reloadData];
                                   [self->_tagCountDictionary removeAllObjects];
                                   self->_hasTagFocusEnabled = YES;
                                   [[NSUserDefaults standardUserDefaults]
                                    setBool:NO
                                    forKey:@"TagFocusEnabled"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   
                                   NSString *status = [[NSString alloc] init];
                                   SRFID_RESULT delete_prefilters =
                                   [[ZebraServiceEngine sharedInstance]
                                    deleteAllPrefilter:&status];
                                   [[ZebraServiceEngine sharedInstance] resetPrefilters];
                                   
                                   NSLog(@"Tag Focus Result: %u", tagFocusResult);
                                   NSLog(@"Tag Focus Result Delete Prefilters: %u",
                                         delete_prefilters);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Tag Focus Disabled Successfully"];
                                   });
                                   
                               } else {
                                   NSLog(@"Tag Focus Result: %u", tagFocusResult);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Tag Focus Disable Failed"];
                                   });
                               }
                           });
                       });
        
    } else {
        [UIView performWithoutAnimation:^{
            [btnTagFocus setImage:[UIImage imageNamed:@"checkbox_checked_icon"]
                         forState:UIControlStateNormal];
            [btnTagFocus setSelected:YES];
            [btnTagFocus layoutIfNeeded];
            
            [btnFastID setImage:[UIImage imageNamed:@"checkbox_icon"]
                       forState:UIControlStateNormal];
            [btnFastID setSelected:NO];
            [btnFastID layoutIfNeeded];
        }];
        
        dispatch_async(
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           SRFID_RESULT tagFocusResult = SRFID_RESULT_FAILURE;
                           
                           NSString *response = @"";
                           
                           tagFocusResult = [[ZebraServiceEngine sharedInstance]
                                             enableTagFocus:YES
                                             status:&response];
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (tagFocusResult == SRFID_RESULT_SUCCESS) {
                                   [self->_tagDataInventory removeAllObjects];
                                   [self clearAllSelections];
                                   [self->tblImpinjInventory reloadData];
                                   [self->_tagCountDictionary removeAllObjects];
                                   self->_hasTagFocusEnabled = YES;
                                   [[NSUserDefaults standardUserDefaults]
                                    setBool:YES
                                    forKey:@"TagFocusEnabled"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   NSLog(@"Tag Focus Result: %u", tagFocusResult);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Tag Focus Enabled Successfully"];
                                   });
                                   
                               } else {
                                   NSLog(@"Tag Focus Result: %u", tagFocusResult);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Tag Focus Enable Failed"];
                                   });
                               }
                           });
                       });
    }
}

- (void)setSingulationForTagFocus {
    SRFID_SLFLAG sl_flag = SRFID_SLFLAG_ALL;
    SRFID_SESSION session = SRFID_SESSION_S1;
    SRFID_INVENTORYSTATE inv_state = SRFID_INVENTORYSTATE_A;
    
    srfidSingulationConfig *config = [[srfidSingulationConfig alloc] init];
    [config setSlFlag:sl_flag];
    [config setSession:session];
    [config setTagPopulation:200];
    [config setInventoryState:inv_state];
    
    SRFID_RESULT resultSigulation = SRFID_RESULT_FAILURE;
    NSString *response = @"";
    resultSigulation = [[ZebraServiceEngine sharedInstance]
                        setSingulationConfigurationTagFoucus:config
                        status:&response];
    if (resultSigulation == SRFID_RESULT_SUCCESS) {
        NSLog(@"Set Singulation Configuration for Tag Foucus SUCCESS");
    } else {
        NSLog(@"Set Singulation Configuration for Tag Foucus Failed");
    }
}

#pragma mark - Tag Quiet / Un-Quiet
- (IBAction)btnTagQuietPressed:(id)sender {
    
    [UIView performWithoutAnimation:^{
        [btnTagUnquiet setImage:[UIImage imageNamed:@"checkbox_icon"] forState:UIControlStateNormal];
        [btnTagUnquiet setSelected:NO];
        [btnTagUnquiet layoutIfNeeded];
    }];
    
    [self startCyclicTagQuiet];
}

- (void)logAllTagCounts {
    NSLog(@"═══════════ TAG COUNT SNAPSHOT ═══════════");
    NSLog(@"Total tags: %lu", (unsigned long)self->_tagDataInventory.count);
    
    int quietCount = 0;
    int activeCount = 0;
    
    for (srfidTagData *tag in self->_tagDataInventory) {
        NSString *tagID = [tag getTagId];
        NSNumber *count = self->_tagCountDictionary[tagID];
        int countVal = [count intValue];
        
        if (countVal == -1) {
            quietCount++;
        } else {
            activeCount++;
        }
        
        NSLog(@"  [%@] count=%d", tagID, countVal);
    }
    
    NSLog(@"Summary: %d quieted (-1), %d active (>0)", quietCount, activeCount);
    NSLog(@"══════════════════════════════════════════");
}

- (void)markTagAsQuieted:(NSString *)tagID {
    if (!tagID) return;
    self->_tagCountDictionary[tagID] = @(-1);
    [self->_tagAvgReadRateDictionary removeObjectForKey:tagID];
    [self->_tagReadRateDictionary removeObjectForKey:tagID];
}

- (void)startCyclicTagQuiet {
    
    if (_currentlySelectedTagIdObjectArray.count == 0) {
        BOOL hasQuieted = NO;
        for (NSNumber *val in _tagCountDictionary.allValues) {
            if ([val intValue] == -1) {
                hasQuieted = YES;
                break;
            }
        }
        
        if (hasQuieted) {
            return;
        } else {
            [self showAlert:@"Please select at least one tag before starting Tag Quiet."];
            return;
        }
    }
    
    self.quietTargetTagIDs = [NSMutableOrderedSet orderedSet];
    for (srfidTagData *tag in _currentlySelectedTagIdObjectArray) {
        NSString *tagID = [tag getTagId];
        if (tagID) {
            [self.quietTargetTagIDs addObject:tagID];
        }
    }
    // Inventory keeps running for the whole cycle, so tags that had not been
    // singulated yet when the user hit Quiet keep arriving. If the user asked to
    // quiet everything, those tags belong to this cycle too.
    self.quietAdoptsNewTags = (_currentlySelectedTagIdObjectArray.count >= _tagDataInventory.count);
    
    self.isQuietCycleActive = YES;
    [InventoryCache sharedCache].isQuietCycleActive = YES;
    
    NSString *quietTimeText = [self->txtQuietTime.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (quietTimeText.length > 0 && [quietTimeText doubleValue] > 0) {
        self.quietCycleInterval = [quietTimeText doubleValue];
    } else {
        self.quietCycleInterval = DEFAULT_QUIET_CYCLE_INTERVAL;
    }
    
    // Start timers and UI updates
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    self.secondsElapsed = 0;
    self->lbTimer.text = @"00:00";
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"InventoryStartTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.countdownTimer = [NSTimer timerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
    
    [self.uniqueTagIntervalTimer invalidate];
    self.uniqueTagIntervalTimer = nil;
    self.uniqueTagCountAtLastInterval = [self->_tagDataInventory count];
    self->lbNewUniqueTagCounter.text = @"New Unique tags every 10s : 0";
    
    self.uniqueTagIntervalTimer = [NSTimer timerWithTimeInterval:10.0
                                                          target:self
                                                        selector:@selector(updateNewUniqueTagCount)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.uniqueTagIntervalTimer forMode:NSRunLoopCommonModes];
    
    // Start the dynamic batch processing
    [self processNextQuietRound];
}


- (void)applyQuietToTagIDs:(NSArray<NSString *> *)tagsToQuiet {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"TagsToQuiet: %lu", (unsigned long)[tagsToQuiet count]);
        if (!self.isQuietCycleActive) return;

        // Step 1: Stop inventory
        [[ZebraServiceEngine sharedInstance] sdkStopInventory];
        self.inventoryRunning = NO;
        
        [InventoryCache sharedCache].inventoryRunning = NO;

        // Android's onQuietButtonClicked waits 100ms after stopping inventory before
        // touching prefilters, so the stop is fully processed by the reader.
        [NSThread sleepForTimeInterval:0.1];

        if (!self.isQuietCycleActive) return;

        // Step 2: Build prefilters (Action INV_B, Target S3)
        NSMutableArray *prefilters = [[NSMutableArray alloc] init];
        for (NSString *tagID in tagsToQuiet) {
            if (!tagID) continue;
            srfidPreFilter *filter = [[srfidPreFilter alloc] init];
            [filter setMaskStartPos:2];
            [filter setMatchLength:96];
            [filter setMatchPattern:tagID];
            [filter setMemoryBank:SRFID_MEMORYBANK_EPC];
            [filter setAction:SRFID_SELECTACTION_INV_B__OR__DSRT_SL];
            [filter setTarget:SRFID_SELECTTARGET_S3];
            [prefilters addObject:filter];
        }

        if (!self.isQuietCycleActive) return;

        // Step 3: Delete existing prefilters & Set new prefilters.
        // Uses the targeted delete, matching Android's PreFilters.deleteAll(). The
        // srfidSetDefaultConfiguration variant would also re-apply the default antenna
        // config and re-enable DPO on every batch, and DPO's power ramping keeps the
        // Select from reaching tags at the edge of the field.
        [[ZebraServiceEngine sharedInstance] DeleteAllPrefilters_New];
        
        // Brief pause to mimic Android's Thread.sleep(50) after delete
        [NSThread sleepForTimeInterval:0.05];
        
        if (!self.isQuietCycleActive) return;
        [[ZebraServiceEngine sharedInstance] setPrefilters:prefilters];

        // Run inventory briefly (500ms) so the prefilter Selects (S3 -> B) actually
        // reach this batch's tags BEFORE the Tag Quiet Select (S3B -> assert SL) is
        // armed. Without this, only a handful of tags per batch get quieted on iOS.
        NSLog(@"Applying prefilters for 500ms...");
        [[ZebraServiceEngine sharedInstance] sdkStartInventory];
        [NSThread sleepForTimeInterval:0.5];
        [[ZebraServiceEngine sharedInstance] sdkStopInventory];
        NSLog(@"Prefilters applied.");

        if (!self.isQuietCycleActive) return;

        // Step 4: Apply Tag Quiet hardware config (Changes Singulation to S2).
        NSString *response = @"";
        [[ZebraServiceEngine sharedInstance] enableTagQuiet:YES meesage:&response];

        if (!self.isQuietCycleActive) return;

        // Step 5: Mark tags as quieted (software-side tracking)
        dispatch_sync(dispatch_get_main_queue(), ^{
            for (NSString *tagID in tagsToQuiet) {
                [self markTagAsQuieted:tagID];
            }
            
            [self clearAllSelections];
            [self recalculateColorCounts];
            [self->tblImpinjInventory reloadData];
            self->lbYellowCount.text = [[NSNumber numberWithInt:self->coutYellow] stringValue];
        });

        if (!self.isQuietCycleActive) return;

        // Step 6: Start main inventory for this batch.
        // Tag Focus singulation (SL_ALL / S1) is deliberately not re-applied here: it
        // would overwrite the SL_DEASSERTED / S2 config enableTagQuiet just installed
        // and unquiet everything. It is restored once the cycle finishes.
        SRFID_RESULT res = [[ZebraServiceEngine sharedInstance] sdkStartInventory];
        
        if (!self.isQuietCycleActive) {
            [[ZebraServiceEngine sharedInstance] sdkStopInventory];
            self.inventoryRunning = NO;
            return;
        }

        if (res == SRFID_RESULT_SUCCESS) {
            self.inventoryRunning = YES;
            [InventoryCache sharedCache].inventoryRunning = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsInventoryRunning"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            // Failsafe: If start fails, stop and exit
            [[ZebraServiceEngine sharedInstance] sdkStopInventory];
            self.inventoryRunning = NO;
            return;
        }

        // Step 7: Update UI to "Scanning" and schedule the next batch
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView performWithoutAnimation:^{
                [self->btnImpinjInvStart setImage:[UIImage imageNamed:STOP_SCAN_ICON] forState:UIControlStateNormal];
                [self->btnImpinjInvStart setSelected:YES];
                [self->btnImpinjInvStart layoutIfNeeded];
            }];
            
            // Trigger the timer to process the next round after your interval
            [self scheduleNextQuietRound];
        });
    });
}

- (void)scheduleNextQuietRound {
    if (!self.isQuietCycleActive) return;

    [self.quietCycleTimer invalidate];
    self.quietCycleTimer = nil;

    self.quietCycleTimer = [NSTimer timerWithTimeInterval:self.quietCycleInterval
                                                   target:self
                                                 selector:@selector(processNextQuietRound)
                                                 userInfo:nil
                                                  repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.quietCycleTimer forMode:NSRunLoopCommonModes];
}

// Pulls tags discovered since the cycle started into the target set, so a tag that
// was not yet visible when the user pressed Quiet still gets quieted.
- (void)adoptNewlyDiscoveredQuietTargets {
    if (!self.quietAdoptsNewTags) return;

    for (srfidTagData *tag in self->_tagDataInventory) {
        NSString *tagID = [tag getTagId];
        if (tagID) {
            [self.quietTargetTagIDs addObject:tagID];
        }
    }
}

// Mirrors Android's quietRunnable: the cycle re-derives its batch from live state
// every round and never concludes on its own. It runs until the user stops
// inventory or un-quiets, which is what keeps a tag that only looks quiet — marked
// but never actually silenced — from being written off.
- (void)processNextQuietRound {
    if (!self.isQuietCycleActive) return;

    [self adoptNewlyDiscoveredQuietTargets];

    NSMutableArray<NSString *> *nextBatch = [NSMutableArray array];
    for (NSString *tagID in self.quietTargetTagIDs) {
        if ([self->_tagCountDictionary[tagID] intValue] != -1) {
            [nextBatch addObject:tagID];
            if (nextBatch.count == BATCH_SIZE) {
                break;
            }
        }
    }

    if (nextBatch.count == 0) {
        // Everything currently looks quiet. Leave inventory running and check again
        // next interval instead of finishing, so any tag that answers is requeued.
        NSLog(@"Quiet Cycle — all %lu target tags currently quiet; holding inventory open",
              (unsigned long)self.quietTargetTagIDs.count);
        [self scheduleNextQuietRound];
        return;
    }

    NSLog(@"Quiet Batched — selecting %lu of %lu target tag(s)",
          (unsigned long)nextBatch.count,
          (unsigned long)self.quietTargetTagIDs.count);

    [self logAllTagCounts];
    [self applyQuietToTagIDs:nextBatch];
}


- (IBAction)btnTagUnquietPressed:(id)sender {
    if (btnTagUnquiet.isSelected) {
        [UIView performWithoutAnimation:^{
            [btnTagUnquiet setImage:[UIImage imageNamed:@"checkbox_icon"]
                           forState:UIControlStateNormal];
            [btnTagUnquiet setSelected:NO];
            [btnTagUnquiet layoutIfNeeded];
        }];
    } else {
        [UIView performWithoutAnimation:^{
            [btnTagUnquiet setImage:[UIImage imageNamed:@"checkbox_checked_icon"]
                           forState:UIControlStateNormal];
            [btnTagUnquiet setSelected:YES];
            [btnTagUnquiet layoutIfNeeded];
        }];
        
        // Kill cycle timer
        self.isQuietCycleActive = NO;
        [InventoryCache sharedCache].isQuietCycleActive = NO;
        [self.quietCycleTimer invalidate];
        self.quietCycleTimer = nil;
        
        [self->_currentlySelectedTagIdObjectArray removeAllObjects];
        
        // Show loading for 10 seconds, then perform un-quiet
        [self showLoadingForSeconds:10 message:@"Un-Quieting Tags..." completion:^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"Currently Selected Array: %@", self->_currentlySelectedTagIdObjectArray);
                
                // 1. Ensure inventory is stopped before modifying RF rules
                [[ZebraServiceEngine sharedInstance] sdkStopInventory];
                
                // 2. Clear old prefilters
                SRFID_RESULT delete_prefilters = [[ZebraServiceEngine sharedInstance] DeleteAllPrefilters_New];
                NSLog(@"Delete All Prefilters: %u", delete_prefilters);
                
                // 3. Apply Tag Un-Quiet Hardware config (This builds the wake-up commands)
                NSString *status = [[NSString alloc] init];
                SRFID_RESULT resTagQuiteFinal = [[ZebraServiceEngine sharedInstance] enableTagQuiet:NO meesage:&status];
                
                // Run inventory briefly (500ms) to broadcast the Unquiet Selects.
//                NSLog(@"Broadcasting Unquiet commands over RF for 500ms...");
//                [[ZebraServiceEngine sharedInstance] sdkStartInventory];
//                [NSThread sleepForTimeInterval:0.5];
//                [[ZebraServiceEngine sharedInstance] sdkStopInventory];
//                NSLog(@"Unquiet commands applied.");
                
                // 4. Clean up the commands so normal inventory works again
                SRFID_RESULT delete_prefilters_two = [[ZebraServiceEngine sharedInstance] DeleteAllPrefilters_New];
                NSLog(@"Delete All Prefilters Two: %u", delete_prefilters_two);
                
                if (resTagQuiteFinal != SRFID_RESULT_SUCCESS) {
                    NSLog(@"Un-Quiet result not confirmed (resTagQuiteFinal=%ld) — clearing the local quieted-tag cache anyway so it doesn't carry stale -1 entries into the next Quiet cycle",
                          (long)resTagQuiteFinal);
                }

                // Always clear the software-side quiet cache after attempting Un-Quiet,
                // regardless of the reported result code. Gating this on SRFID_RESULT_SUCCESS
                // let a non-SUCCESS (but possibly still-applied) result leave every tag's -1
                // marker in _tagCountDictionary in place. resetInventoryState deliberately
                // preserves count == -1 entries across resets so a quiet survives an inventory
                // restart — but that same preservation meant a failed-to-clear cache kept
                // carrying stale "quieted" tags forward into every subsequent Quiet/Unquiet
                // cycle, compounding over 2-3 cycles.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.quietedTagIDs removeAllObjects];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TagQuietEnabled"];
                    [[NSUserDefaults standardUserDefaults] synchronize];

                    NSString *alertMsg = (resTagQuiteFinal == SRFID_RESULT_SUCCESS)
                        ? @"Impinj Tag Un-Quiet Enabled"
                        : @"Impinj Tag Un-Quiet sent, but the reader did not confirm it. Local quiet state has been cleared — please re-run Inventory to verify tags respond.";

                    [self presentAlertWithMessage:alertMsg completion:^{
                        // Programmatically press the clear button to wipe everything,
                        // including the quieted (-1) tag markers, so no stale state
                        // survives into the next Quiet cycle.
                        [self btnClearInventoryPressed:nil];
                    }];
                });
            });
        }];
    }
}


// Loading Bar for Tag Un-quiet
- (void)showLoadingForSeconds:(NSInteger)seconds completion:(void (^)(void))completion {
    // Create overlay
    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    overlay.tag = 9999; // Tag to identify later if needed
    
    // Create activity indicator
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    spinner.color = [UIColor whiteColor];
    spinner.center = overlay.center;
    [spinner startAnimating];
    
    // Create label
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.text = @"Un-Quieting Tags...";
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    [loadingLabel sizeToFit];
    loadingLabel.center = CGPointMake(overlay.center.x, spinner.center.y + 40);
    
    [overlay addSubview:spinner];
    [overlay addSubview:loadingLabel];
    [self.view addSubview:overlay];
    
    // Auto-dismiss after specified seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            overlay.alpha = 0.0;
        } completion:^(BOOL finished) {
            [overlay removeFromSuperview];
            if (completion) {
                completion();
            }
        }];
    });
}

- (void)presentAlertWithMessage:(NSString *)alertMsg completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"ZebraGen2X Alert"
                                              message:alertMsg
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
            if (completion) {
                completion();
            }
        }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

// Loading Bar for Tag Quiet and Un-quiet
- (void)showLoadingForSeconds:(NSInteger)seconds
                      message:(NSString *)message
                   completion:(void (^)(void))completion {
    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    overlay.tag = 9999;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    spinner.color = [UIColor whiteColor];
    spinner.center = overlay.center;
    [spinner startAnimating];
    
    UILabel *loadingLabel = [[UILabel alloc] init];
    loadingLabel.text = message;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.font = [UIFont systemFontOfSize:16.0
                                          weight:UIFontWeightMedium];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    [loadingLabel sizeToFit];
    loadingLabel.center = CGPointMake(overlay.center.x, spinner.center.y + 40);
    
    [overlay addSubview:spinner];
    [overlay addSubview:loadingLabel];
    [self.view addSubview:overlay];
    
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [UIView animateWithDuration:0.3
                                        animations:^{
                           overlay.alpha = 0.0;
                       }
                                        completion:^(BOOL finished) {
                           [overlay removeFromSuperview];
                           if (completion) {
                               completion();
                           }
                       }];
                   });
}

- (void)startUITimersIfNeeded {
    //  Only start timers if they aren't already running
    if (self.countdownTimer && [self.countdownTimer isValid]) {
        return; // Already started by setTagQuietPreFilterArray — don't reset!
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"InventoryStartTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.countdownTimer = [NSTimer timerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
    
    self.uniqueTagCountAtLastInterval = [self->_tagDataInventory count];
    self.uniqueTagIntervalTimer = [NSTimer timerWithTimeInterval:10.0
                                                          target:self
                                                        selector:@selector(updateNewUniqueTagCount)
                                                        userInfo:nil
                                                         repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.uniqueTagIntervalTimer forMode:NSRunLoopCommonModes];
}

- (void)showAlert:(NSString *)alertMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.presentedViewController) {
            [self.presentedViewController
             dismissViewControllerAnimated:NO
             completion:^{
                [self presentAlertWithMessage:alertMsg];
            }];
        } else {
            [self presentAlertWithMessage:alertMsg];
        }
        
    });
}


- (void)presentAlertWithMessage:(NSString *)alertMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"ZebraGen2X Alert"
                                              message:alertMsg
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - table view Delegate
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.tagDataInventory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tagId = @"";
    
    if (indexPath.row < _tagDataInventory.count) {
        tagId = [_tagDataInventory[indexPath.row] getTagId];
    } else {
        NSLog(@"Warning: Attempted to access index %ld in array with count %lu",
              (long)indexPath.row, (unsigned long)_tagDataInventory.count);
    }
    
    NSString *tagIdString = [NSString stringWithFormat:@"%@", tagId];
    NSString *tagRSSI = @"";
    
    if (indexPath.row < _tagDataInventory.count) {
        tagRSSI = [NSString stringWithFormat:@"%hd", [_tagDataInventory[indexPath.row] getPeakRSSI]];
    } else {
        NSLog(@"Warning: Attempted to access index %ld in array with count %lu",
              (long)indexPath.row, (unsigned long)_tagDataInventory.count);
    }
    
    NSString *specificTagId = tagId;
    NSNumber *count = _tagCountDictionary[specificTagId];
    int countValue = [count intValue];
    
    // Dequeue and cast to your custom cell
    ImpinjCustomTableViewCell *cell = (ImpinjCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomCell"
                                                                                                   forIndexPath:indexPath];
    cell.delegate = self;
    
    if (indexPath.row < self.checkedStates.count) {
        cell.checked = [self.checkedStates[indexPath.row] boolValue];
    } else {
        cell.checked = NO;
    }
    
    [cell updateCheckboxImage];
    
    cell.lblImpinjTagID.text = tagIdString;
    cell.lblImpinjRSSI.text = tagRSSI;
    
    // ── Read count ──
    if (countValue == -1) {
        cell.lblImpinjReadCount.text = @"-1";
    } else {
        cell.lblImpinjReadCount.text = [NSString stringWithFormat:@"%d", countValue];
    }
    
    // ── Read rate ──
    if (countValue == -1) {
        cell.lblImpinjReadRate.text = @"0.00";
    } else {
        NSNumber *cachedRate = _tagReadRateDictionary[specificTagId];
        if (cachedRate) {
            double tagReadRate = [cachedRate doubleValue];
            int whole = (int)tagReadRate;
            int decimal = (int)((tagReadRate - whole) * 100);
            cell.lblImpinjReadRate.text = [NSString stringWithFormat:@"%d.%02d", whole, decimal];
        } else {
            cell.lblImpinjReadRate.text = @"0.00";
        }
    }
    
    // ── Determine cell background color ──
    UIColor *forcedBlackText = [UIColor blackColor];
    UIColor *dynamicText;
    
    if (@available(iOS 13.0, *)) {
        dynamicText = [UIColor labelColor]; // Black in Light Mode, White in Dark Mode
    } else {
        dynamicText = [UIColor blackColor];
    }
    
    if (countValue == -1) {
        //  Quieted tag — yellow
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0];
        
        // Force text to black so it's readable on light yellow
        cell.lblImpinjTagID.textColor = forcedBlackText;
        cell.lblImpinjRSSI.textColor = forcedBlackText;
        cell.lblImpinjReadCount.textColor = forcedBlackText;
        cell.lblImpinjReadRate.textColor = forcedBlackText;
        
        cell.checkboxButton.tintColor = forcedBlackText;
    } else {
        NSDictionary *avgRateSnapshot = [_tagAvgReadRateDictionary copy];
        
        double sum = 0.0;
        int activeCount = 0;
        
        for (NSString *key in avgRateSnapshot) {
            if ([_tagCountDictionary[key] intValue] == -1) continue;
            sum += [avgRateSnapshot[key] doubleValue];
            activeCount++;
        }
        
        double averageRate = 0.0;
        if (activeCount > 0) {
            averageRate = sum / activeCount;
        }
        
        NSNumber *specificRate = avgRateSnapshot[tagIdString];
        double rate = [specificRate doubleValue];
        
        if (rate > averageRate) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.80 green:1.0 blue:0.80 alpha:1.0];
            
            // Force text to black so it's readable on light green
            cell.lblImpinjTagID.textColor = forcedBlackText;
            cell.lblImpinjRSSI.textColor = forcedBlackText;
            cell.lblImpinjReadCount.textColor = forcedBlackText;
            cell.lblImpinjReadRate.textColor = forcedBlackText;
            
            cell.checkboxButton.tintColor = forcedBlackText;
            
            if (@available(iOS 13.0, *)) {
                cell.checkboxButton.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        } else if (rate < averageRate) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
            
            // Force text to black so it's readable on light gray
            cell.lblImpinjTagID.textColor = forcedBlackText;
            cell.lblImpinjRSSI.textColor = forcedBlackText;
            cell.lblImpinjReadCount.textColor = forcedBlackText;
            cell.lblImpinjReadRate.textColor = forcedBlackText;
            
            cell.checkboxButton.tintColor = forcedBlackText;
            
            if (@available(iOS 13.0, *)) {
                cell.checkboxButton.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        } else {
            if (@available(iOS 13.0, *)) {
                cell.contentView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                    if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                        return [UIColor systemGray5Color]; // Charcoal gray in Dark Mode
                    } else {
                        return [UIColor whiteColor]; // Pure white in Light Mode
                    }
                }];
                
                cell.checkboxButton.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
            } else {
                cell.contentView.backgroundColor = [UIColor whiteColor]; // Fallback for iOS 12 and below
            }
            
            cell.lblImpinjTagID.textColor = dynamicText;
            cell.lblImpinjRSSI.textColor = dynamicText;
            cell.lblImpinjReadCount.textColor = dynamicText;
            cell.lblImpinjReadRate.textColor = dynamicText;
            
            [cell updateCheckboxImage];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // We will manage the selection state manually
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //  Bounds check
    if (indexPath.row >= self.tagDataInventory.count) {
        NSLog(@"Warning: Row %ld out of bounds (count: %lu)", (long)indexPath.row, (unsigned long)self.tagDataInventory.count);
        return;
    }
    
    NSString *selectedTagID = [[self.tagDataInventory objectAtIndex:indexPath.row] getTagId];
    NSLog(@"Adrian Selected Tag ID: %@", selectedTagID);
    
    id selectedObject = [self.tagDataInventory objectAtIndex:indexPath.row];
    
    // If the row is already selected, deselect it
    if ([self.selectedRows containsObject:indexPath]) {
        [self.selectedRows removeObject:indexPath];
        [_currentlySelectedTagIdObjectArray removeObject:selectedObject];
    }
    // If the row is not selected, select it
    else {
        [self.selectedRows addObject:indexPath];
        [_currentlySelectedTagIdObjectArray addObject:selectedObject];
        
    }
    
    //  Toggle the checkbox state when the row is tapped
    if (indexPath.row < self.checkedStates.count) {
        BOOL newState = ![self.checkedStates[indexPath.row] boolValue];
        self.checkedStates[indexPath.row] = @(newState);
    }
    
    // Inform the delegate (ProtectedVC)
    if ([self.delegate respondsToSelector:@selector(inventoryVC:didSelectItem:)]) {
        [self.delegate inventoryVC:self didSelectItem:selectedTagID];
    }
    
    NSLog(@"Adrian currentlySelectedTagIdObjectArray Count: %lu", (unsigned long)[_currentlySelectedTagIdObjectArray count]);
    
    // Save to NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedTagID forKey:@"SelectedTagID"];
    [defaults synchronize];
    
    // Reload the row to update its appearance
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)resetReadRate {
    //    _scanStartTime = nil;
    //    _totalReadCount = 0;
    //   // [_tagCountDictionary removeAllObjects];
}

#pragma mark - CustomTableViewCellDelegate

- (void)customCellCheckBoxButtonTapped:(ImpinjCustomTableViewCell *)cell {
    
    NSIndexPath *indexPath = [self->tblImpinjInventory indexPathForCell:cell];
    if (indexPath) {
        
        //  Bounds check
        if (indexPath.row >= self.tagDataInventory.count || indexPath.row >= self.checkedStates.count) {
            NSLog(@"Warning: Row %ld out of bounds", (long)indexPath.row);
            return;
        }
        
        // Toggle the checked state in the data model
        BOOL newState = ![self.checkedStates[indexPath.row] boolValue];
        self.checkedStates[indexPath.row] = @(newState);
        
        // Update the cell's UI
        cell.checked = newState;
        [cell updateCheckboxImage];
        
        //  Sync the selection array — same logic as didSelectRowAtIndexPath:
        id selectedObject = [self.tagDataInventory objectAtIndex:indexPath.row];
        NSString *selectedTagID = [selectedObject getTagId];
        
        if (newState) {
            // Checkbox was checked — add to selections
            if (![self.selectedRows containsObject:indexPath]) {
                [self.selectedRows addObject:indexPath];
            }
            [_currentlySelectedTagIdObjectArray addObject:selectedObject];
        } else {
            // Checkbox was unchecked — remove from selections
            [self.selectedRows removeObject:indexPath];
            [_currentlySelectedTagIdObjectArray removeObject:selectedObject];
        }
        
        // Inform the delegate
        if ([self.delegate respondsToSelector:@selector(inventoryVC:didSelectItem:)]) {
            [self.delegate inventoryVC:self didSelectItem:selectedTagID];
        }
        
        // Save to NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:selectedTagID forKey:@"SelectedTagID"];
        [defaults synchronize];
        
        NSLog(@"Checkbox tapped — currentlySelectedTagIdObjectArray Count: %lu",
              (unsigned long)[_currentlySelectedTagIdObjectArray count]);
        
        // Reload the row to update background color
        [self->tblImpinjInventory reloadRowsAtIndexPaths:@[indexPath]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - IBAction Methods
- (IBAction)btnSelectAllTaggPressed:(id)sender {
    
    if (btnSlectAllTags.selected == YES) {
        // checkbox_checked_icon  checkbox_icon
        [UIView performWithoutAnimation:^{
            [btnSlectAllTags setImage:[UIImage imageNamed:@"checkbox_icon"]
                             forState:UIControlStateNormal];
            [btnSlectAllTags layoutIfNeeded];
            [btnSlectAllTags setSelected:NO];
        }];
        
        [self selectAllTagInTableView:NO];
    } else {
        // checkbox_checked_icon  checkbox_icon
        [UIView performWithoutAnimation:^{
            [btnSlectAllTags
             setImage:[UIImage imageNamed:@"checkbox_checked_icon"]
             forState:UIControlStateNormal];
            [btnSlectAllTags layoutIfNeeded];
            [btnSlectAllTags setSelected:YES];
        }];
        [self selectAllTagInTableView:YES];
    }
}
- (IBAction)btnClearInventoryPressed:(id)sender {
    
    //Wipe ALL -1 counts so resetInventoryState doesn't preserve them
    for (NSString *key in [self->_tagCountDictionary allKeys]) {
        if ([self->_tagCountDictionary[key] intValue] == -1) {
            [self->_tagCountDictionary removeObjectForKey:key];
        }
    }
    //  Full clear — including quieted tags
    [self.quietedTagIDs removeAllObjects];
    [self resetInventoryState];
    
    // Also stop all timers
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    [self.inventoryAutoStopTimer invalidate];
    self.inventoryAutoStopTimer = nil;
    [self.uniqueTagIntervalTimer invalidate];
    self.uniqueTagIntervalTimer = nil;
    
    self.secondsElapsed = 0;
    [InventoryCache sharedCache].secondsElapsed = 0;
    self->_totalReadCount = 0;
    [InventoryCache sharedCache].totalReadCount = 0;
    self->lbTimer.text = @"00:00";
    
    //  Clear saved times
    [[NSUserDefaults standardUserDefaults] setBool:NO
                                            forKey:@"IsInventoryRunning"];
    [[NSUserDefaults standardUserDefaults]
     removeObjectForKey:@"InventoryStartTime"];
    // ── Clear auto-stop date on manual clear too ──
    [[NSUserDefaults standardUserDefaults]
     removeObjectForKey:@"InventoryAutoStopDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)selectAllTagInTableView:(BOOL)enableAll {
    [self.checkedStates removeAllObjects];
    [self.selectedRows removeAllObjects];
    [_currentlySelectedTagIdObjectArray removeAllObjects];
    
    for (int i = 0; i < [_tagDataInventory count]; i++) {
        if (enableAll) {
            //  Always add to selection array (ALL tags)
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.selectedRows addObject:indexPath];
            [_currentlySelectedTagIdObjectArray addObject:_tagDataInventory[i]];
            
            //  Only show visual checkmark for first 31
            if (i < 31) {
                [self.checkedStates addObject:@(YES)];
            } else {
                [self.checkedStates addObject:@(NO)];
            }
        } else {
            [self.checkedStates addObject:@(NO)];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->tblImpinjInventory reloadData];
    });
    
    NSLog(@"Select All — %lu tags in selection array, batching will handle the rest",
          (unsigned long)_currentlySelectedTagIdObjectArray.count);
}


- (void)updateSelectAllButtonState {
    BOOL isSelectAllState = YES;
    
    if (self.tagDataInventory.count == 0) {
        isSelectAllState = NO;
    } else {
        // Check if the current state perfectly matches the "Select All" criteria
        for (int i = 0; i < self.checkedStates.count; i++) {
            BOOL isChecked = [self.checkedStates[i] boolValue];
            
            if (i < MAX_SELECTED_TAGS) {
                // If any of the first 31 tags are UNCHECKED, it's not "Select All"
                if (!isChecked) {
                    isSelectAllState = NO;
                    break;
                }
            } else {
                // If any tag AFTER the 31st is CHECKED, it's not "Select All"
                if (isChecked) {
                    isSelectAllState = NO;
                    break;
                }
            }
        }
    }
    
    if (self.isQuietCycleActive) {
        isSelectAllState = NO;
    }
    // Update the UI
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isSelectAllState) {
            if (!self->btnSlectAllTags.isSelected) {
                [UIView performWithoutAnimation:^{
                    [self->btnSlectAllTags setImage:[UIImage imageNamed:@"checkbox_checked_icon"] forState:UIControlStateNormal];
                    [self->btnSlectAllTags setSelected:YES];
                    [self->btnSlectAllTags layoutIfNeeded];
                }];
            }
        } else {
            if (self->btnSlectAllTags.isSelected) {
                [UIView performWithoutAnimation:^{
                    [self->btnSlectAllTags setImage:[UIImage imageNamed:@"checkbox_icon"] forState:UIControlStateNormal];
                    [self->btnSlectAllTags setSelected:NO];
                    [self->btnSlectAllTags layoutIfNeeded];
                }];
            }
        }
    });
}



- (IBAction)btnEnableFastID:(id)sender {
    
    if (btnFastID.isSelected) {
        
        // 1. Update UI immediately on the Main Thread
        [UIView performWithoutAnimation:^{
            [btnFastID setImage:[UIImage imageNamed:@"checkbox_icon"]
                       forState:UIControlStateNormal];
            [btnFastID setSelected:NO];
            [btnFastID layoutIfNeeded];
        }];
        
        // 2. Send hardware command on a background thread
        dispatch_async(
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           // Hardware call
                           SRFID_RESULT resConfigureFastIDFinal =
                           [[ZebraServiceEngine sharedInstance] configureFastID:NO
                                                                         status:nil];
                           if (resConfigureFastIDFinal == SRFID_RESULT_SUCCESS) {
                               [[ZebraServiceEngine sharedInstance]
                                setFastIDEnableStatue:NO];
                               [[NSUserDefaults standardUserDefaults]
                                setBool:YES
                                forKey:@"FastIDEnabled"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                           }
                           // Switch back to Main Thread for UI Alert
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (resConfigureFastIDFinal == SRFID_RESULT_SUCCESS) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Fast ID Disabled"];
                                       [self resetInventoryState];
                                       
                                   });
                                   
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Failed to Disable Fast ID"];
                                   });
                                   
                                   // Optional: If it failed, you might want to revert the
                                   // checkbox UI here
                               }
                           });
                       });
        
    } else {
        
        // 1. Update UI immediately on the Main Thread
        [UIView performWithoutAnimation:^{
            [btnFastID setImage:[UIImage imageNamed:@"checkbox_checked_icon"]
                       forState:UIControlStateNormal];
            [btnFastID setSelected:YES];
            [btnFastID layoutIfNeeded];
        }];
        
        // 2. Send hardware command on a background thread
        dispatch_async(
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                           // Do ALL hardware calls on the background thread!
                           
                           // Check the result of enabling Fast ID
                           SRFID_RESULT resConfigureFastIDFinal =
                           [[ZebraServiceEngine sharedInstance] configureFastID:YES
                                                                         status:nil];
                           
                           if (resConfigureFastIDFinal == SRFID_RESULT_SUCCESS) {
                               //[self enableFastID];
                               [[ZebraServiceEngine sharedInstance]
                                setFastIDEnableStatue:YES];
                               [[NSUserDefaults standardUserDefaults]
                                setBool:YES
                                forKey:@"FastIDEnabled"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                           }
                           
                           // Switch back to Main Thread ONLY for the UI Alert
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (resConfigureFastIDFinal == SRFID_RESULT_SUCCESS) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Fast ID Enabled"];
                                       [self resetInventoryState];
                                   });
                                   
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [self showAlert:@"Failed to Enable Fast ID"];
                                   });
                               }
                           });
                       });
    }
}

- (IBAction)btnStartStopPressed:(id)sender {
    if (self.inventoryStartStopInProgress) return;
    
    if (btnImpinjInvStart.isSelected) {
        // --- STOP ---
        self.inventoryStartStopInProgress = YES;
        
        self.isQuietCycleActive = NO;
        [self.quietCycleTimer invalidate];
        self.quietCycleTimer = nil;
        
        [UIView performWithoutAnimation:^{
            [btnImpinjInvStart setImage:[UIImage imageNamed:START_SCAN_ICON]
                               forState:UIControlStateNormal];
            [btnImpinjInvStart setSelected:NO];
            [btnImpinjInvStart layoutIfNeeded];
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[ZebraServiceEngine sharedInstance] sdkStopInventory];
            self.inventoryRunning = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopInventoryAndTimers];
            });
        });
        
    } else {
        // --- START ---
        self.inventoryStartStopInProgress = YES;

        [UIView performWithoutAnimation:^{
            [btnImpinjInvStart setImage:[UIImage imageNamed:STOP_SCAN_ICON]
                               forState:UIControlStateNormal];
            [btnImpinjInvStart setSelected:YES];
            [btnImpinjInvStart layoutIfNeeded];
        }];

        // ── Invalidate any existing timers ──
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        self.secondsElapsed = 0;
        self->lbTimer.text = @"00:00";

        [self.inventoryAutoStopTimer invalidate];
        self.inventoryAutoStopTimer = nil;

        [self.uniqueTagIntervalTimer invalidate];
        self.uniqueTagIntervalTimer = nil;
        self.uniqueTagCountAtLastInterval = [_tagDataInventory count];
        self->lbNewUniqueTagCounter.text = @"New Unique tags every 10s : 0";
        self.uniqueTagIntervalTimer = [NSTimer timerWithTimeInterval:10.0
                                                              target:self
                                                            selector:@selector(updateNewUniqueTagCount)
                                                            userInfo:nil
                                                             repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.uniqueTagIntervalTimer
                                  forMode:NSRunLoopCommonModes];

        // ── Read txtInventoryTime.text here on the main thread ──
        // Reading UIKit elements on background threads is unsafe and can
        // return nil or empty — causing autoStopSeconds to be wrong.
        NSString *inventoryTimeText = [self->txtInventoryTime.text
            stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSInteger autoStopSeconds = [inventoryTimeText integerValue];

        NSLog(@"Auto-stop seconds read from UI: %ld", (long)autoStopSeconds);

        // ── Pass autoStopSeconds directly to inventoryStart ──
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self inventoryStartWithAutoStopSeconds:autoStopSeconds];
        });    }
}

- (void)inventoryStartWithAutoStopSeconds:(NSInteger)autoStopSeconds {
    @try {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self resetInventoryState];
        });

        SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;

        if (_hasTagFocusEnabled) {
            [self setSingulationForTagFocus];
        }

        rfid_res = [[ZebraServiceEngine sharedInstance] sdkStartInventory];

        if (rfid_res == SRFID_RESULT_SUCCESS) {

            // ── Save start time to cache immediately after hardware success ──
            NSDate *now = [NSDate date];
            [InventoryCache sharedCache].inventoryStartTime = now;
            [InventoryCache sharedCache].inventoryRunning = YES;
            [InventoryCache sharedCache].autoStopSeconds = autoStopSeconds;

            if (autoStopSeconds > 0) {
                [InventoryCache sharedCache].inventoryAutoStopDate =
                    [now dateByAddingTimeInterval:autoStopSeconds];
            }

            [[NSUserDefaults standardUserDefaults] setObject:now
                                                      forKey:@"InventoryStartTime"];
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:@"IsInventoryRunning"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            // ── Start all UI timers on main thread ──
            dispatch_async(dispatch_get_main_queue(), ^{
                self.inventoryRunning = YES;

                self.countdownTimer = [NSTimer timerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateTimer)
                                                            userInfo:nil
                                                             repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.countdownTimer
                                          forMode:NSRunLoopCommonModes];

                if (autoStopSeconds > 0) {
                    self.inventoryAutoStopTimer =
                        [NSTimer timerWithTimeInterval:autoStopSeconds
                                                target:self
                                              selector:@selector(autoStopInventory)
                                              userInfo:nil
                                               repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:self.inventoryAutoStopTimer
                                              forMode:NSRunLoopCommonModes];
                }
            });

            NSLog(@"sdkStartInventory : Success");

        } else if (rfid_res == SRFID_RESULT_RESPONSE_ERROR) {
            self.inventoryRunning = NO;
            [InventoryCache sharedCache].inventoryRunning = NO;
            NSLog(@"sdkStartInventory ResponseError");
        } else if (rfid_res == SRFID_RESULT_FAILURE ||
                   rfid_res == SRFID_RESULT_RESPONSE_TIMEOUT) {
            self.inventoryRunning = NO;
            [InventoryCache sharedCache].inventoryRunning = NO;
            NSLog(@"sdkStartInventory reader prob");
        }
    } @finally {
        self.inventoryStartStopInProgress = NO;
    }
}

#pragma mark - Auto Stop Inventory

- (void)autoStopInventory {

    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self autoStopInventory];
        });
        return;
    }

    // ── Show the correct final elapsed time before stopping ──
    // The label shows N-1 seconds because updateTimer hasn't fired
    // for the last second yet when autoStopInventory is called.
    // Computing directly from the start date gives the true value.
    NSDate *startDate = [InventoryCache sharedCache].inventoryStartTime;
    if (startDate) {
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
        self.secondsElapsed = (int)elapsed;
        int minutes = self.secondsElapsed / 60;
        int seconds = self.secondsElapsed % 60;
        self->lbTimer.text = [NSString stringWithFormat:@"%02d:%02d",
                              minutes, seconds];
    }

    // ── Stop the timer from continuing to increment ──
    self.inventoryRunning = NO;

    // ── Reset button UI back to Start icon ──
    [UIView performWithoutAnimation:^{
        [btnImpinjInvStart setImage:[UIImage imageNamed:START_SCAN_ICON]
                           forState:UIControlStateNormal];
        [btnImpinjInvStart setSelected:NO];
        [btnImpinjInvStart layoutIfNeeded];
    }];

    // ── Stop and nil the timer so label stops updating ──
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;

    // ── Now stop everything else ──
    [self stopInventoryAndTimers];
}

- (void)stopInventoryAndTimers {
    self.inventoryRunning = NO;

    // ── Clear cache ──
    [InventoryCache sharedCache].inventoryRunning = NO;
    [InventoryCache sharedCache].inventoryStartTime = nil;
    [InventoryCache sharedCache].inventoryAutoStopDate = nil;
    [InventoryCache sharedCache].autoStopSeconds = 0;
    [InventoryCache sharedCache].isQuietCycleActive = NO;

    [self.countdownTimer invalidate];
    self.countdownTimer = nil;

    [self.inventoryAutoStopTimer invalidate];
    self.inventoryAutoStopTimer = nil;

    [self.uniqueTagIntervalTimer invalidate];
    self.uniqueTagIntervalTimer = nil;

    self.isQuietCycleActive = NO;
    [self.quietCycleTimer invalidate];
    self.quietCycleTimer = nil;

    [self stopUIRefreshTimer];

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InventoryStartTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"InventoryAutoStopDate"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IsInventoryRunning"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    for (int i = 0; i < self.checkedStates.count; i++) {
        self.checkedStates[i] = @(NO);
    }
    [self clearAllSelections];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSelectAllButtonState];
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self inventoryStop];
    });
}

- (void)updateTimer {
    if (!self.inventoryRunning) return;
    
    NSDate *startDate = [InventoryCache sharedCache].inventoryStartTime;
    if (startDate) {
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
        self.secondsElapsed = (int)elapsed;
    } else {
        self.secondsElapsed++;
    }
    
    // Sync to cache for
    [InventoryCache sharedCache].secondsElapsed = self.secondsElapsed;
    
    int minutes = self.secondsElapsed / 60;
    int seconds = self.secondsElapsed % 60;
    self->lbTimer.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
    if (self.readRateAlert) {
        NSTimeInterval elapsed = (NSTimeInterval)self.secondsElapsed;
        NSInteger totalReads = self->_totalReadCount;
        double readRate = (elapsed > 0) ? ((double)totalReads / elapsed) : 0.0;
        [self.readRateAlert configureWithTotalReads:totalReads
                                          totalTime:elapsed
                                           readRate:readRate];
    }
}

- (void)dealloc {
    [self.countdownTimer invalidate]; // Clean up to prevent retain cycle
    
    [self.inventoryAutoStopTimer invalidate];
    [self.uniqueTagIntervalTimer invalidate];
    [self.quietCycleTimer invalidate];
    [self.uiRefreshTimer invalidate];
}

- (void)clearAllSelections {
    // 1. Clear the array that stores the selected index paths.
    [self.selectedRows removeAllObjects];
    
    // 2. Clear the array that stores your selected tag data objects.
    [_currentlySelectedTagIdObjectArray removeAllObjects];
    
    NSLog(@"All selections have been cleared.");
}
#pragma mark - Inventory Start
- (void)inventoryStart {
    @try {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self resetInventoryState];
        });

        SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;

        if (_hasTagFocusEnabled) {
            [self setSingulationForTagFocus];
        }

        rfid_res = [[ZebraServiceEngine sharedInstance] sdkStartInventory];

        if (rfid_res == SRFID_RESULT_SUCCESS) {

            // ── Save start time to cache immediately after hardware success ──
            NSDate *now = [NSDate date];
            [InventoryCache sharedCache].inventoryStartTime = now;
            [InventoryCache sharedCache].inventoryRunning = YES;

            // ── Compute auto-stop from cache ──
            NSString *inventoryTimeText = [self->txtInventoryTime.text
                stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSInteger autoStopSeconds = [inventoryTimeText integerValue];
            [InventoryCache sharedCache].autoStopSeconds = autoStopSeconds;

            if (autoStopSeconds > 0) {
                [InventoryCache sharedCache].inventoryAutoStopDate =
                    [now dateByAddingTimeInterval:autoStopSeconds];
            }

            // ── Also persist to NSUserDefaults for app relaunch recovery ──
            [[NSUserDefaults standardUserDefaults] setObject:now
                                                      forKey:@"InventoryStartTime"];
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:@"IsInventoryRunning"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            // ── Start all UI timers on main thread ──
            dispatch_async(dispatch_get_main_queue(), ^{

                // ── inventoryRunning already YES in cache — safe to start timer ──
                self.inventoryRunning = YES;

                self.countdownTimer = [NSTimer timerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(updateTimer)
                                                            userInfo:nil
                                                             repeats:YES];
                [[NSRunLoop mainRunLoop] addTimer:self.countdownTimer
                                          forMode:NSRunLoopCommonModes];

                if (autoStopSeconds > 0) {
                    self.inventoryAutoStopTimer =
                        [NSTimer timerWithTimeInterval:autoStopSeconds
                                                target:self
                                              selector:@selector(autoStopInventory)
                                              userInfo:nil
                                               repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:self.inventoryAutoStopTimer
                                              forMode:NSRunLoopCommonModes];
                }
            });

            NSLog(@"sdkStartInventory : Success");

        } else if (rfid_res == SRFID_RESULT_RESPONSE_ERROR) {
            self.inventoryRunning = NO;
            [InventoryCache sharedCache].inventoryRunning = NO;
            NSLog(@"sdkStartInventory ResponseError");
        } else if (rfid_res == SRFID_RESULT_FAILURE ||
                   rfid_res == SRFID_RESULT_RESPONSE_TIMEOUT) {
            self.inventoryRunning = NO;
            [InventoryCache sharedCache].inventoryRunning = NO;
            NSLog(@"sdkStartInventory reader prob");
        }
    } @finally {
        self.inventoryStartStopInProgress = NO;
    }
}

- (void)inventoryStop {
    @try {
        SRFID_RESULT rfid_res = SRFID_RESULT_FAILURE;
        rfid_res = [[ZebraServiceEngine sharedInstance] sdkStopInventory];
        self.inventoryRunning = NO;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO
                                                forKey:@"IsInventoryRunning"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->tblImpinjInventory reloadData];
        });
        
        if (rfid_res == SRFID_RESULT_SUCCESS) {
            NSLog(@" inventoryStop : Success");
        } else if (rfid_res == SRFID_RESULT_RESPONSE_ERROR) {
            NSLog(@"inventoryStop ResponseError");
        } else if (rfid_res == SRFID_RESULT_FAILURE ||
                   rfid_res == SRFID_RESULT_RESPONSE_TIMEOUT) {
            NSLog(@"inventoryStop reader prob");
        }
        
        [self resetReadRate];
    } @finally {
        self.inventoryStartStopInProgress = NO;
    }
}

#pragma mark - Trigger Event

- (BOOL)onNewTriggerEvent:(BOOL)pressed typeRFID:(BOOL)isRFID {
    if (!isRFID) {
        return YES;
    }
    
    __block InventoryVC *__weak_self = self;
    
    BOOL running = self.inventoryRunning;
    BOOL busy = self.inventoryStartStopInProgress;
    
    NSLog(@"[DEBUG] Trigger pressed=%d running(flag)=%d busy=%d UISelected=%d",
          pressed, running, busy, self->btnImpinjInvStart.isSelected);
    
    if (pressed) {
        // PRESS -> START
        if (YES == [[[ZebraServiceEngine sharedInstance] sledConfiguration]
                    isStartTriggerImmediate]) {
            if (!running && !busy) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!__weak_self.inventoryRunning &&
                        !__weak_self.inventoryStartStopInProgress) {
                        if (!__weak_self->btnImpinjInvStart.isSelected) {
                            [__weak_self btnStartStopPressed:nil];
                        } else {
                            __weak_self.inventoryStartStopInProgress = YES;
                            dispatch_async(
                                           dispatch_get_global_queue(
                                                                     DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                           ^{
                                               [__weak_self inventoryStart];
                                           });
                        }
                    }
                });
            }
        }
    } else {
        // RELEASE -> STOP
        if (YES == [[[ZebraServiceEngine sharedInstance] sledConfiguration]
                    isStopTriggerImmediate]) {
            if (running && !busy) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (__weak_self.inventoryRunning &&
                        !__weak_self.inventoryStartStopInProgress) {
                        if (__weak_self->btnImpinjInvStart.isSelected) {
                            [__weak_self btnStartStopPressed:nil];
                        } else {
                            [__weak_self stopInventoryAndTimers];
                            [__weak_self->btnImpinjInvStart
                             setImage:[UIImage imageNamed:START_SCAN_ICON]
                             forState:UIControlStateNormal];
                            [__weak_self->btnImpinjInvStart setSelected:NO];
                            [__weak_self->btnImpinjInvStart layoutIfNeeded];
                            
                            __weak_self.inventoryRunning = NO;
                        }
                    }
                });
            }
        }
    }
    
    return YES;
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self->txtQuietTime) {
        [textField resignFirstResponder];
        [self showNumberInputAlertWithTitle:@"Quiet Time"
                                    message:@"Please Enter Quiet Time below."
                                placeholder:@"Quiet Time"
                                 completion:^(NSString *enteredText) {
            self->txtQuietTime.text = enteredText;
        }];
    } else if (textField == self->txtInventoryTime) {
        [textField resignFirstResponder];
        [self
         showNumberInputAlertWithTitle:@"Inventory Time"
         message:@"Please Enter Inventory Time below."
         placeholder:@"Inventory Time"
         completion:^(NSString *enteredText) {
            self->txtInventoryTime.text = enteredText;
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (textField == self->txtInventoryTime) {
        NSString *value = [textField.text stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [defaults setObject:value forKey:@"SavedInventoryTime"];
        NSLog(@"Saved inventory time: %@", value);
    } else if (textField == self->txtQuietTime) {
        NSString *value = [textField.text stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [defaults setObject:value forKey:@"SavedQuietTime"];
        NSLog(@"Saved quiet time: %@", value);
    }

    [defaults synchronize];
}

- (void)showNumberInputAlertWithTitle:(NSString *)title
                              message:(NSString *)message
                          placeholder:(NSString *)placeholder
                           completion:
(void (^)(NSString *enteredText))completion {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(
                                                  UITextField *_Nonnull textField) {
                                                      textField.keyboardType = UIKeyboardTypeNumberPad;
                                                      textField.placeholder = placeholder;
                                                  }];
    
    UIAlertAction *cancel =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
        NSString *enteredText = alert.textFields.firstObject.text;
        if (completion) {
            completion(enteredText);
        }
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
