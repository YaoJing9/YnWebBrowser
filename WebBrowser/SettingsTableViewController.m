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
typedef enum : NSUInteger {
    CellKindForCache,
} CellKind;

static NSString *const SettingActivityTableViewCellIdentifier = @"SettingActivityTableViewCellIdentifier";
static NSString *const SettingPlaceholderTableViewCellIdentifier   = @"SettingPlaceholderTableViewCellIdentifier";

@interface SettingsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    self.dataArray = @[@"意见反馈",@"清除缓存",@"清除历史记录",@"分享给朋友",@"启动时打开上次页面",@"广告过滤",@"版本"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.sectionHeaderHeight = 40;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

}

- (void)handleTableViewSelectAt:(NSInteger)index{
    if (index == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定清除缓存？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            
            [self cleanCacheWithURLs:[NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil] completionBlock:^{
            
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (index == 2){
        [[[HistorySQLiteManager alloc] init] deleteAllHistoryRecords];
    }
}

#pragma mark - Helper Method
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UITableViewCell *)cacheCellWithIndexPath:(NSIndexPath *)indexPath{
    SettingActivityTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SettingActivityTableViewCellIdentifier];
    
    cell.leftLabel.text = self.dataArray[indexPath.row];
    [cell.activityIndicatorView startAnimating];
    
    [cell setCalculateBlock:^{
        NSArray *urlArray = [NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil];

        long long size = [[NSFileManager defaultManager] getAllocatedSizeOfCacheDirectoryAtURLS:urlArray error:NULL];
        
        if (size == -1)
            return @"0M";
        
        NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleBinary];
        
        return sizeStr;
    }];
    
    return cell;
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
    
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case CellKindForCache:
            cell = [self cacheCellWithIndexPath:indexPath];
            break;
        default:
            //never called
            cell = [tableView dequeueReusableCellWithIdentifier:SettingPlaceholderTableViewCellIdentifier];
            break;
    }
    return cell;
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
