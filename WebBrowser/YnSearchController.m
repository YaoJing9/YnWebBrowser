//
//  YnSearchController.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "YnSearchController.h"
#import "TabManager.h"
#import "MLSearchResultsTableViewController.h"
#import "HistoryRecordCell.h"
#import "BrowserViewController.h"
#import "HttpHelper.h"
#import "HistorySQLiteManager.h"
#import "SaveImageTool.h"
#define PYSEARCH_SEARCH_HISTORY_CACHE_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MLSearchhistories.plist"] // 搜索历史存储路径

@interface YnSearchController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tagsView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITextField *searchBar;

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

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self showNavWithTitle:@"" backBtnHiden:YES];
    self.NAVLine.hidden = YES;
    self.searchHistoriesCount = 5;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 64) style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self createSearchBar];
    
    [self createHeaderView];
    [self tagsViewWithTag];
}

- (void)createSearchBar{
    WS(weakSelf);
    UILabel *lable=[[UILabel alloc] init];
    lable.layer.cornerRadius=5;
    lable.clipsToBounds=YES;
    lable.backgroundColor=[UIColor colorWithHexString:@"#f2f2f2"];
    lable.userInteractionEnabled = YES;
    
    [self.NAVview addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.NAVview).offset(12);
        make.right.equalTo(weakSelf.NAVview).offset(-60);
        make.height.equalTo(@36);
        make.bottom.equalTo(weakSelf.NAVview.mas_bottom);
    }];
    
    UIImageView *leftImg = [UIImageView new];
    leftImg.image = [UIImage imageNamed:@"搜索icon"];
    [lable addSubview:leftImg];
    [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lable);
        make.left.equalTo(lable).offset(8);
        make.height.equalTo(@17);
        make.width.equalTo(@17);
    }];
    
    
    _searchBar=[[UITextField alloc] init];
    _searchBar.delegate=self;
    
    _searchBar.clearButtonMode = UITextFieldViewModeAlways;
    _searchBar.textColor=[UIColor blackColor];
    _searchBar.font=PFSCRegularFont(16);
    _searchBar.text = _origTextFieldString;
    _searchBar.placeholder=@"搜索或者输入网址";
    [_searchBar setValue:[UIColor colorWithHexString:@"#555555"] forKeyPath:@"_placeholderLabel.textColor"];
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.returnKeyType = UIReturnKeySearch;
    [lable  addSubview:_searchBar];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lable).offset(0);
        make.left.equalTo(leftImg.mas_right).offset(5);
        make.height.equalTo(lable);
        make.right.equalTo(lable);
    }];
    //监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoAction) name:UITextFieldTextDidChangeNotification object:nil];
    
    UIButton *canceBtn = [UIButton new];
    [canceBtn setTitle:@"取消" forState:UIControlStateNormal];
    [canceBtn setTitleColor:[UIColor colorWithHexString:@"#2696ff"] forState:UIControlStateNormal];
    canceBtn.titleLabel.font = PFSCMediumFont(16);
    [canceBtn addTarget:self action:@selector(canceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.NAVview addSubview:canceBtn];
    [canceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lable).offset(0);
        make.right.equalTo(weakSelf.NAVview.mas_right);
        make.height.equalTo(lable);
        make.width.equalTo(@60);
    }];
}

- (void)createHeaderView{
    WS(weakSelf);
    
    
    CGFloat height1 = 0;
    if ([YnSimpleInterest shareSimpleInterest].searchTopAry.count%5 == 0) {
        
        if ([YnSimpleInterest shareSimpleInterest].searchTopAry.count == 5) {
            height1 = ([YnSimpleInterest shareSimpleInterest].searchTopAry.count/5)*45 + 2*17;
        }else{
            height1 = ([YnSimpleInterest shareSimpleInterest].searchTopAry.count/5)*45 + 3*17;
        }
    }else{
        if ([YnSimpleInterest shareSimpleInterest].searchTopAry.count < 5) {
            height1 = ([YnSimpleInterest shareSimpleInterest].searchTopAry.count/5 + 1)*45 + 2*17;
        }else{
            height1 = ([YnSimpleInterest shareSimpleInterest].searchTopAry.count/5 + 1)*45 + 3*17;
        }
    }
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENHEIGHT, 40 + height1)];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, SCREENWIDTH-20, 30)];
    titleLabel.text = @"推荐网址";
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    [titleLabel sizeToFit];
    [self.headerView addSubview:titleLabel];
    
    
    self.tagsView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREENWIDTH, height1)];
    [self.headerView addSubview:self.tagsView];
    self.tableView.tableHeaderView = self.headerView;    
    
    
    NSInteger btnW = (SCREENWIDTH)/5.0;
        for (int i=0; i<[YnSimpleInterest shareSimpleInterest].searchTopAry.count; i++) {
            
            
            NSInteger line = i%5;
            NSInteger clow = i/5;
            CGFloat cellWidth = SCREENWIDTH/5;
            
            CGFloat cellX = cellWidth * line;
            CGFloat cellY = 17 + (17 + 45)*clow;
            ImgTitleView *button = [[ImgTitleView alloc] initWithFrame:CGRectMake(cellX, cellY, cellWidth, 45) imageView:CGSizeMake(28, 28) gap:7 font:PFSCMediumFont(11) color:[UIColor colorWithHexString:@"#333333"] tag:i + 100];
            button.title = [YnSimpleInterest shareSimpleInterest].searchTopAry[i][@"name"];
            button.placeholderImage = @"topzw";
            button.imageUrl = [YnSimpleInterest shareSimpleInterest].searchTopAry[i][@"icon"];
            [self.tagsView addSubview:button];
            button.imgTitleViewBlock = ^(NSInteger index) {
                [weakSelf flbuttonAction:index];
            };
        }
    
//    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
//    UILabel *footLabel = [[UILabel alloc] initWithFrame:footView.frame];
//    footLabel.textColor = [UIColor grayColor];
//    footLabel.font = [UIFont systemFontOfSize:13];
//    footLabel.userInteractionEnabled = YES;
//    footLabel.text = @"清空搜索记录";
//    footLabel.textAlignment = NSTextAlignmentCenter;
//    [footLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptySearchHistoryDidClick)]];
//    [footView addSubview:footLabel];
//    self.tableView.tableFooterView = footView;
    
}

#pragma mark-键盘的监听事件
-(void)infoAction{
    if (_searchBar.text.length == 0) {
        return;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_searchBar.text.length != 0 && _fromVCComeInKind == FromVCComeInKindWEBVIEW) {
        [_searchBar selectAll:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchUrlForWebView:textField.text];
    return YES;
}
#pragma mark - 主要回调方法
-(void)searchUrlForWebView:(NSString *)text{
    
    if (text.length != 0) {
        [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[text] key:DelegateManagerBrowserContainerLoadURL];
        // 缓存数据并且刷新界面
        [self saveSearchCacheAndRefreshView:text];
    }else{
        
    }
}
- (WebModel *)getDefaultWebModel{
    WebModel *webModel = [WebModel new];
    webModel.title = DEFAULT_CARD_CELL_TITLE;
    webModel.url = DEFAULT_CARD_CELL_URL;
    webModel.isNewWebView = YES;
    webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
    return webModel;
}
/** 进入搜索状态调用此方法 */
- (void)saveSearchCacheAndRefreshView:(NSString *)text
{
    UITextField *searchBar = self.searchBar;
    // 回收键盘
    [searchBar resignFirstResponder];
    // 先移除再刷新
    [self.searchHistories removeObject:searchBar.text];
    [self.searchHistories insertObject:searchBar.text atIndex:0];
    
    // 移除多余的缓存
    if (self.searchHistories.count > self.searchHistoriesCount) {
        // 移除最后一条缓存
        [self.searchHistories removeLastObject];
    }
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];

    
    if (_fromVCComeInKind == FromVCComeInKindROOTVC) {
        
        NSString *url = [self rootSearchStrWebViewWithSug:text];
        
        [[TabManager sharedInstance] setMultiWebViewOperationBlockWith:^(NSArray<WebModel *> *array) {
            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:array];
            if (array.count == 0) {
                
                [dataArray addObject:[self getDefaultWebModel]];
            }else{
                WebModel *webModel = dataArray.lastObject;
                webModel.isNewWebView = NO;
                [dataArray replaceObjectAtIndex:dataArray.count - 1 withObject:webModel];
                
                [[TabManager sharedInstance] updateWebModelArray:dataArray completion:^{
                    BrowserViewController *vc = [BrowserViewController new];
                    
                    vc.url = url;
                    vc.fromVCComeInKind = FromVCComeInKindSEARCH;
                    [self.navigationController pushViewController:vc animated:NO];
                    
                    [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[url] key:DelegateManagerBrowserContainerLoadURL];
                    
                }];
            }
            
            
            
           
        }];
    }else{
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
}
//解决冲首页第一次搜索不显示的问题
- (NSString *)rootSearchStrWebViewWithSug:(NSString *)text{
    
    NSString *urlString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![HttpHelper isURL:urlString]) {
        urlString = [NSString stringWithFormat:BAIDU_SEARCH_URL,[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else{
        if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
            urlString = [NSString stringWithFormat:@"http://%@",urlString];
        }
    }
    return urlString;
}

#pragma mark - 分割线
-(void)flbuttonAction:(NSInteger)index{
    
    NSArray *linkAry = [[YnSimpleInterest shareSimpleInterest].searchTopAry valueForKeyPath:@"link"];
    
    NSString *link = linkAry[index];
    
    [self searchUrlForWebView:link];
}
- (void)canceBtnClick{
    
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (void)tagsViewWithTag
{
    
}

/** 选中标签 */
- (void)tagDidCLick:(UITapGestureRecognizer *)gr
{
    UILabel *label = (UILabel *)gr.view;
    self.searchBar.text = label.text;
    
    // 缓存数据并且刷新界面
    [self searchUrlForWebView:label.text];
    
   
}



- (void)cancelDidClick
{
    
    [self dismissViewControllerAnimated:NO completion:nil];

}

/** 视图完全显示 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
}

/** 视图即将消失 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 回收键盘
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.tableFooterView.hidden = self.searchHistories.count == 0;
    return self.searchHistories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryRecordCell *historyRecordCell = [HistoryRecordCell cellWithTableView:tableView reuseIdentifier:@"HistoryRecordCell"];
    historyRecordCell.title = self.searchHistories[indexPath.row];
    return historyRecordCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.searchHistories.count != 0) {
        
        return @"搜索历史";
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 0, SCREENWIDTH-10, 30)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:view.frame];
    titleLabel.text = @"搜索历史";
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    [view addSubview:titleLabel];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *url = self.searchHistories[indexPath.row];
    // 缓存数据并且刷新界面
    [self searchUrlForWebView:url];

}

- (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width+10;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 滚动时，回收键盘
    [self.searchBar resignFirstResponder];
}

- (NSMutableArray *)searchHistories
{
    
    if (!_searchHistories) {
        self.searchHistoriesCachePath = PYSEARCH_SEARCH_HISTORY_CACHE_PATH;
        NSArray *array = [NSArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
        _searchHistories = [NSMutableArray array];
        for (NSString *str in array) {
            if (_searchHistories.count == 5) {
                break;
            }
            [_searchHistories addObject:str];
            
        }
    }
    return _searchHistories;
}

- (void)setSearchHistoriesCachePath:(NSString *)searchHistoriesCachePath
{
    _searchHistoriesCachePath = [searchHistoriesCachePath copy];
    // 刷新
    self.searchHistories = nil;
    
    [self.tableView reloadData];
}



- (void)closeDidClick:(UIButton *)sender
{
    // 获取当前cell
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    // 移除搜索信息
    [self.searchHistories removeObject:cell.textLabel.text];
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];

    if (self.searchHistories.count == 0) {
        self.tableView.tableFooterView.hidden = YES;
    }
    // 刷新
    [self.tableView reloadData];
}

/** 点击清空历史按钮 */
- (void)emptySearchHistoryDidClick
{
    
    self.tableView.tableFooterView.hidden = YES;
    // 移除所有历史搜索
    [self.searchHistories removeAllObjects];
    // 移除数据缓存
    [[HistorySQLiteManager alloc] deleteAllHistoryRecords];
    
    [self.tableView reloadData];
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UITextField *)searchBar
{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.searchSuggestionVC.view.hidden = YES;
        self.tableView.hidden = NO;
    }
    else
    {
        self.searchSuggestionVC.view.hidden = NO;
        self.tableView.hidden = YES;
        [self.view bringSubviewToFront:self.searchSuggestionVC.view];
        
        //创建一个消息对象
        NSNotification * notice = [NSNotification notificationWithName:@"searchBarDidChange" object:nil userInfo:@{@"searchText":searchText}];
        //发送消息
        [[NSNotificationCenter defaultCenter]postNotification:notice];
    }
    
    
}

@end

