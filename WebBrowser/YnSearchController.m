//
//  YnSearchController.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "YnSearchController.h"

@interface YnSearchController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tagsView;
@property (nonatomic, strong) UIView *headerView;
/** 搜索历史 */
@property (nonatomic, strong) NSMutableArray *searchHistories;
/** 搜索历史缓存保存路径, 默认为PYSEARCH_SEARCH_HISTORY_CACHE_PATH(PYSearchConst.h文件中的宏定义) */
@property (nonatomic, copy) NSString *searchHistoriesCachePath;
/** 搜索历史记录缓存数量，默认为20 */
@property (nonatomic, assign) NSUInteger searchHistoriesCount;
/** 搜索建议（推荐）控制器 */
@property (nonatomic, weak) MLSearchResultsTableViewController *searchSuggestionVC;
@end

@implementation YnSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
