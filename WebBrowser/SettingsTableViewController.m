//
//  SettingsTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/1/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingActivityTableViewCell.h"
#import "NSFileManager+ZWUtility.h"
#import "HistorySQLiteManager.h"
#import "UIAlertController+DXAlertController.h"
#import "SettingSwitchTableViewCell.h"
#import "ExtendedFunctionViewController.h"
typedef enum : NSUInteger {
    CellKindForCache,
} CellKind;

static NSString *const SettingActivityTableViewCellIdentifier = @"SettingActivityTableViewCellIdentifier";
static NSString *const SettingPlaceholderTableViewCellIdentifier   = @"SettingPlaceholderTableViewCellIdentifier";

@interface SettingsTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;
@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showNavWithTitle:@"设置" backBtnHiden:NO];
    
    self.dataArray = @[@"意见反馈",@"清除缓存",@"清除历史记录",@"分享给朋友",@"广告过滤"];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64) style:UITableViewStyleGrouped];
    
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];
}

- (void)handleTableViewSelectAt:(NSInteger)index{
    if (index == 1) {
        
        [UIAlertController wl_showAlertViewWithActionsName:@[@"确定"] title:@"您确定清除缓存?" message:nil callBack:^(NSString * _Nonnull btnTitle, NSInteger btnIndex) {
            
            if (btnIndex == 0) {
                [self cleanCacheWithURLs:[NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil] completionBlock:^{
                    
                }];
            } 
        }];
    }else if (index == 2){
        
        [UIAlertController wl_showAlertViewWithActionsName:@[@"确定"] title:@"您确定清除历史记录?" message:nil callBack:^(NSString * _Nonnull btnTitle, NSInteger btnIndex) {
           
            if (btnIndex == 0) {
                [[[HistorySQLiteManager alloc] init] deleteAllHistoryRecords];
            }
        }];
    }else if (index == 4){
        ExtendedFunctionViewController *vc = [[ExtendedFunctionViewController alloc] init];
        vc.extendedOperationKind = ExtendedOperationKindGUANGGAOGUOLV;
        [self.navigationController pushViewController:vc animated:NO];
    }else if (index == 5){
        ExtendedFunctionViewController *vc = [[ExtendedFunctionViewController alloc] init];
        vc.extendedOperationKind = ExtendedOperationKindGUANGGAOGUOLV;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

#pragma mark - Helper Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *tableCell = [self.tableView dequeueReusableCellWithIdentifier:SettingPlaceholderTableViewCellIdentifier];
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SettingPlaceholderTableViewCellIdentifier];
        tableCell.textLabel.font = [UIFont systemFontOfSize:14];
        
        tableCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    tableCell.textLabel.text = self.dataArray[indexPath.row];
    
    return tableCell;

}

#pragma mark - UITableViewDelegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self handleTableViewSelectAt:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Clean Cache Method

- (void)cleanCacheWithURLs:(NSArray<NSURL *> *)array completionBlock:(SettingVoidReturnNoParamsBlock)completionBlock{
    if (array.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [array enumerateObjectsUsingBlock:^(NSURL *diskCacheURL, NSUInteger idx, BOOL *stop){
            @autoreleasepool {
                NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:diskCacheURL includingPropertiesForKeys:nil options:0 error:NULL];
                foreach(path, array) {
                    if (![[path lastPathComponent] isEqualToString:@"Snapshots"]) {
                        [[NSFileManager defaultManager] removeItemAtURL:path error:NULL];
                    }
                }
            }
        }];
        
        if (completionBlock) {
            dispatch_main_safe_async(^{
                completionBlock();
            })
        }
    });
}

- (void)dealloc{
    NSLog(@"SettingsTableViewController dealloc");
}

@end
