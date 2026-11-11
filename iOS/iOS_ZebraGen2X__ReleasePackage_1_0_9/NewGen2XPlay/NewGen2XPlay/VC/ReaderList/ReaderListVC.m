//
//  ReaderListVC.m
//  NewGen2XPlay
//
//  Created by Dhanushka, Adrian on 2026-02-17.
//

#import "ReaderListVC.h"
#import "MenuVC.h"
#import "ZebraServiceEngine.h"
#import "ReaderModel.h"
#import "AlertViewHelper.h"

#define IMPINJ_TAG_CONFIG_STORYBOARD_NAME   @"Main"

@interface ReaderListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSMutableArray *selectedStates;  // Track selection states for each cell
@property (nonatomic, strong, nullable) NSIndexPath *connectedIndexPath;
@property (nonatomic, strong) NSArray<srfidReaderInfo *> *readerList;

@end



@implementation ReaderListVC

#pragma mark - LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationBarLeft];
   
    NSString *Title = @"ZebraGen2X";
    [self setTitle:Title];
    
    [[ZebraServiceEngine sharedInstance] initializeRfidSdkWithAppSettings];
    [[ZebraServiceEngine sharedInstance] getSDKVersion];
    
    
    readerListTableView.delegate = self;
    readerListTableView.dataSource = self;
    [self refreshReaderListPage];
     
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self navigationBarRight];
    [self refreshReaderListPage];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[ZebraServiceEngine sharedInstance] initializeRfidSdkWithAppSettings];
    [[ZebraServiceEngine sharedInstance] getSDKVersion];
    
    readerListTableView.delegate = self;
    readerListTableView.dataSource = self;
    [ZebraServiceEngine sharedInstance].delegateReaderEvent = self;
    [self refreshReaderListPage];
}

- (void)didTapRefresh:(id)sender
{
    [self refreshReaderListPage];
    [self showRefreshPopUp];
}

- (void)didTapMenu:(id)sender
{
        MenuVC *menuVc = nil;
        menuVc = (MenuVC*)[[UIStoryboard storyboardWithName:IMPINJ_TAG_CONFIG_STORYBOARD_NAME bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"IMPINJ_MENU_ID"];
        [self.navigationController pushViewController:menuVc animated:YES];
    
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@""
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        
}

-(void)navigationBarRight {
    
UIBarButtonItem *refreshItem =
[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(didTapRefresh:)];

self.navigationItem.rightBarButtonItems = @[refreshItem];
    
}

-(void)navigationBarLeft {
    UIImage *sideMenuIcon = [UIImage systemImageNamed:@"line.3.horizontal"];
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:sideMenuIcon
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapMenu:)];
    self.navigationItem.leftBarButtonItem = menuItem;

    self.navigationController.navigationBar.tintColor = UIColor.labelColor;
}

-(void)refreshReaderListPage {
    NSArray<srfidReaderInfo *> *readersInfo = (NSArray<srfidReaderInfo *> *)[[ZebraServiceEngine sharedInstance] getAvialbleReaders];
    self.readerList = readersInfo ?: @[];
    for (id r in readersInfo) NSLog(@"Reader obj class: %@", NSStringFromClass([r class]));
    [readerListTableView reloadData];
}

- (void)showRefreshPopUp {
    if ([[ZebraServiceEngine sharedInstance] getConnectedReaderId] != -1) {
        [AlertViewHelper showAlertOn:self
                           title: @"Reader is connected. Please disconnect the reader before refreshing the list."
                         message:nil];
    }
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.readerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReaderListVCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    srfidReaderInfo *info = self.readerList[indexPath.row];
    
    int connectedId = [[ZebraServiceEngine sharedInstance] getConnectedReaderId];
    BOOL isConnectedRow = ([info getReaderID] == connectedId);
    NSString *name = [info getReaderName] ?: @"(Unnamed Reader)";

        cell.textLabel.text = isConnectedRow ? [NSString stringWithFormat:@"%@ - connected", name]
                                             : [NSString stringWithFormat:@"%@ - disconnected", name];
    
    

//    cell.contentView.backgroundColor = isConnectedRow ? [UIColor colorWithRed:0.80 green:1.0 blue:0.80 alpha:1.0]
//                                                      : [UIColor whiteColor];
    
    if (isConnectedRow) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.80 green:1.0 blue:0.80 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        
    } else {
        if (@available(iOS 13.0, *)) {
            cell.contentView.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [UIColor systemGray6Color];
                } else {
                    return [UIColor whiteColor];
                }
            }];
            
            cell.textLabel.textColor = [UIColor labelColor];
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    srfidReaderInfo *selectedInfo = self.readerList[indexPath.row];
    int selectedReaderID = [selectedInfo getReaderID];

    int currentlyConnectedID = [[ZebraServiceEngine sharedInstance] getConnectedReaderId];

    // Tap same connected reader -> disconnect
    if (currentlyConnectedID == selectedReaderID) {
        [[ZebraServiceEngine sharedInstance] disconnect:selectedReaderID];
        return;
    }

    // Disconnect previous if any
    if (currentlyConnectedID != -1) {
        [[ZebraServiceEngine sharedInstance] disconnect:currentlyConnectedID];
    }

    // Connect new
    [[ZebraServiceEngine sharedInstance] connect:selectedReaderID];
}

-(BOOL)isReaderConnected{
    return isConnected;
}

#pragma mark - Zebra Sevice Engine Delegate
- (void)didConnected:(ZebraServiceEngine *)zebraServiceEngine didConnectedDevice:(srfidReaderInfo *)availableReader{
    [self refreshReaderListPage];
    NSLog(@"Connected Reader Reader Name:  %@",[availableReader getReaderName]);
    NSLog(@"Connected Reader Id:  %d",[availableReader getReaderID]);
}

- (void)didDisconnect:(ZebraServiceEngine *)zebraServiceEngine didDisconnectedDevice:(NSString *)readerId{
    [self refreshReaderListPage];
    NSLog(@"Disconnected Reader Id :  %@",readerId);
}

- (void)didDeviceAppear:(ZebraServiceEngine *)zebraServiceEngine didFinishDeviceAppear:(srfidReaderInfo *)availableReader{
    [self refreshReaderListPage];
    NSLog(@"ReaderAppear Event : %@",[availableReader getReaderName]);
}

- (void)didDisappear:(ZebraServiceEngine *)zebraServiceEngine didDeviceDisappear:(NSString *)readerId{
    isConnected = NO;
    [self refreshReaderListPage];
    NSLog(@"Disconnected Reader  Event:  %@",readerId);
}


@end
