//
//  YnSearchController.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "YnSearchController.h"
#import "MLSearchResultsTableViewController.h"
#import "HistoryRecordCell.h"
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

- (MLSearchResultsTableViewController *)searchSuggestionVC
{
    if (!_searchSuggestionVC) {
        MLSearchResultsTableViewController *searchSuggestionVC = [[MLSearchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        __weak typeof(self) _weakSelf = self;
        searchSuggestionVC.didSelectText = ^(NSString *didSelectText) {
            
            if ([didSelectText isEqualToString:@""]) {
                [self.searchBar resignFirstResponder];
            }
            else
            {
                // 设置搜索信息
                _weakSelf.searchBar.text = didSelectText;
                
                // 缓存数据并且刷新界面
                [_weakSelf saveSearchCacheAndRefreshView];
            }
            
            
        };
        searchSuggestionVC.view.frame = CGRectMake(0, 64, self.view.width, self.view.height);
        searchSuggestionVC.view.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:searchSuggestionVC.view];
        [self addChildViewController:searchSuggestionVC];
        _searchSuggestionVC = searchSuggestionVC;
    }
    return _searchSuggestionVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showNavWithTitle:@"" backBtnHiden:YES];
    self.NAVLine.hidden = YES;
    self.searchHistoriesCount = 20;
    
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
        make.left.equalTo(weakSelf.NAVview).offset(15);
        make.right.equalTo(weakSelf.NAVview).offset(-60);
        make.height.equalTo(@32);
        make.bottom.equalTo(weakSelf.NAVview.mas_bottom);
    }];
    
    UIImageView *leftImg = [UIImageView new];
    leftImg.image = [UIImage imageNamed:@"搜索icon"];
    [lable addSubview:leftImg];
    [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lable);
        make.left.equalTo(lable).offset(5);
        make.height.equalTo(@17);
        make.width.equalTo(@17);
    }];
    
    
    _searchBar=[[UITextField alloc] init];
    _searchBar.delegate=self;
    _searchBar.textColor=[UIColor blackColor];
    _searchBar.font=[UIFont fontWithName:@"PingFangSC-Regular" size:15];
    _searchBar.text = _origTextFieldString;
    _searchBar.placeholder=@"搜索或者输入网址";
    [_searchBar setValue:[UIColor colorWithHexString:@"#555555"] forKeyPath:@"_placeholderLabel.textColor"];
    _searchBar.keyboardType = UIKeyboardTypeASCIICapable;
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
    canceBtn.titleLabel.font = [UIFont systemFontOfSize:16];
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
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENHEIGHT, 235)];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, SCREENWIDTH-20, 30)];
    titleLabel.text = @"推荐网址";
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    [titleLabel sizeToFit];
    [self.headerView addSubview:titleLabel];
                       
    self.tagsView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREENWIDTH, 195)];
    [self.headerView addSubview:self.tagsView];
    self.tableView.tableHeaderView = self.headerView;
    
    
    
    FL_Button *clowBtn;
    
    NSArray *buttonTitleArray = @[@"全屏模式",@"夜间模式",@"无图模式",@"无痕模式",@"我的视频",@"书签／历史",@"添加书签",@"分享"];
    NSInteger btnW = (SCREENWIDTH)/4.0;
    for (int i=0; i<buttonTitleArray.count; i++) {
        FL_Button *flbutton = [FL_Button new];
        [flbutton setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
        flbutton.titleLabel.font = [UIFont systemFontOfSize:13];
        [flbutton setImage:[UIImage imageNamed:buttonTitleArray[i]] forState:UIControlStateNormal];
        [flbutton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        flbutton.tag = 100 + i;
        flbutton.status = FLAlignmentStatusTop;
        flbutton.fl_padding = 10;
        [flbutton addTarget:self action:@selector(flbuttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.tagsView addSubview:flbutton];
        if (clowBtn) {
            if (i < 4) {
                [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(clowBtn);
                    make.left.equalTo(clowBtn.mas_right);
                    make.width.equalTo(clowBtn);
                    make.height.equalTo(clowBtn);
                }];
            }else if (i == 4){
                [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(195/2.0));
                    make.left.equalTo(weakSelf.tagsView);
                    make.width.equalTo(clowBtn);
                    make.height.equalTo(clowBtn);
                }];
            }else{
                [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(clowBtn);
                    make.left.equalTo(clowBtn.mas_right);
                    make.width.equalTo(clowBtn);
                    make.height.equalTo(clowBtn);
                }];
            }
        }else{
            [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.tagsView);
                make.left.equalTo(weakSelf.tagsView);
                make.width.equalTo(@(btnW));
                make.height.equalTo(@(195/2.0));
            }];
        }
        clowBtn = flbutton;
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
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self searchUrlForWebView:textField.text];
    return YES;
}

-(void)searchUrlForWebView:(NSString *)text{
    if (text.length != 0) {
        [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[text] key:DelegateManagerBrowserContainerLoadURL];
        // 缓存数据并且刷新界面
        [self saveSearchCacheAndRefreshView];
    }else{
        
    }
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
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    // 缓存数据并且刷新界面
    [self searchUrlForWebView:self.searchHistories[indexPath.row]];

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
        _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
        
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

/** 进入搜索状态调用此方法 */
- (void)saveSearchCacheAndRefreshView
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)closeDidClick:(UIButton *)sender
{
    // 获取当前cell
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    // 移除搜索信息
    [self.searchHistories removeObject:cell.textLabel.text];
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:PYSEARCH_SEARCH_HISTORY_CACHE_PATH];
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
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    
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

