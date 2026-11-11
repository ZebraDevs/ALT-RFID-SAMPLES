//
//  InventoryVC.h
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-23.
//

#import <UIKit/UIKit.h>
#import "ZebraServiceEngine.h"
#import "BaseViewController.h"
#import "ImpinjCustomTableViewCell.h"


@class InventoryVC;

@protocol InventoryVCDelegate <NSObject>
- (void)inventoryVC:(InventoryVC *)controller didSelectItem:(NSString *)item;
@end

@interface InventoryVC : BaseViewController<TagDataEventDelegate,UITableViewDelegate, UITableViewDataSource,CustomTableViewCellDelegate,UITextFieldDelegate, zt_IZebraServiceEngineTriggerEventDelegate>{
    
    IBOutlet UIButton *btnImpinjInvStart;
    IBOutlet UIButton *btnSlectAllTags;
    IBOutlet UIButton *btnFastID;
    
    
    
    __weak IBOutlet UIButton *btnTagUnquiet;
    IBOutlet UIButton *btnTagFocus;
    IBOutlet UITableView *tblImpinjInventory;
    IBOutlet UILabel *lbUniqeCount;
    IBOutlet UILabel *lbTimer;
    IBOutlet UITextField *txtQuietTime;
    IBOutlet UITextField *txtInventoryTime;
    
    IBOutlet UILabel *lbNewUniqueTagCounter;
    
    //Green: Tags which have the read / sec greater than the average
    IBOutlet UILabel *lbGreenCount;
    //Grey: Tags which have read/sec less than the average
    IBOutlet UILabel *lbGrayCount;
    //White: Non quieted tags which are not participating in the current round
    IBOutlet UILabel *lbWhiteCount;
    //Yellow: Tags which were quieted
    IBOutlet UILabel *lbYellowCount;
    int coutGreen;
    int coutGray;
    int coutWhite;
    int coutYellow;
}

@property (nonatomic, strong) NSMutableArray<NSNumber *> *checkedStates;

@property (nonatomic, strong) NSMutableArray *tagDataInventory;
@property (nonatomic, strong) NSMutableDictionary *tagCountDictionary;
@property (nonatomic, strong) NSMutableArray *currentlySelectedTagIdObjectArray;
@property (nonatomic, strong) NSMutableArray *selectedRows;
@property (nonatomic, strong) NSMutableDictionary *tagReadRateDictionary;

@property (nonatomic, weak) id<InventoryVCDelegate> delegate;
@property (nonatomic, strong) NSArray<NSString *> *items;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) int secondsElapsed;

@property (nonatomic, strong) NSDate *scanStartTime;
@property (nonatomic, assign) NSInteger totalReadCount;


@property (nonatomic, assign) CGFloat averageReadRate;

@property (nonatomic, strong) NSMutableDictionary *tagAvgReadRateDictionary;

@property (nonatomic, assign) BOOL hasTagFocusEnabled;
@property (nonatomic, assign) BOOL hasTagQuietEnabled;

@property (nonatomic, strong) NSTimer *inventoryAutoStopTimer;

@property (nonatomic, strong) NSMutableSet *quietedTagIDs;

@property (nonatomic, strong) NSTimer *uniqueTagIntervalTimer;
@property (nonatomic, assign) NSInteger uniqueTagCountAtLastInterval;

@end


