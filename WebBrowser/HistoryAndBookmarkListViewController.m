//
//  HistoryAndBookmarkListViewController.m
//  WebBrowser
//
//  Created by apple on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryAndBookmarkListViewController.h"
#import "HistoryAndBookmarkTableViewCell.h"
#import "HistoryDataManager.h"
#import "BookmarkDataManager.h"
#import "PreferenceHelper.h"
static NSString *const HistoryAndBookmarkListTableViewCellIdentifier   = @"HistoryAndBookmarkListTableViewCellIdentifier";
@interface HistoryAndBookmarkListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) HistoryDataManager *historyDataManager;
@property (nonatomic, strong) BookmarkDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation HistoryAndBookmarkListViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"书签列表";
    
    _mainTableView.tableFooterView = [UIView new];
    
    _listDataOperationKind = ListDataOperationKindBookmark;
    [self getBookmarkData];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}
#pragma mark - ButtonAction
-(void)rightButtonAction{
    if (_listDataOperationKind == ListDataOperationKindHistory) {
        [_historyDataManager deleleAllHistoryRecords];
        [self.mainTableView reloadData];
    }else{
        [_dataManager deleleAllBookmarkRecords];
        [self.mainTableView reloadData];
    }
}
- (IBAction)historyAndBookmarkAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        //获取书签数据
        _listDataOperationKind = ListDataOperationKindBookmark;
        [self getBookmarkData];
        self.title = @"书签列表";
        
    }else{
        
        //获取历史数据
        _listDataOperationKind = ListDataOperationKindHistory;
        [self getHistoryData];
        self.title = @"历史列表";
        
    }
}

#pragma mark - TableViewDelegate && TableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryAndBookmarkTableViewCell *tableCell = [self.mainTableView dequeueReusableCellWithIdentifier:HistoryAndBookmarkListTableViewCellIdentifier];
    if (tableCell == nil) {
        tableCell = [[HistoryAndBookmarkTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HistoryAndBookmarkListTableViewCellIdentifier];
    }
    
    if (_listDataOperationKind == ListDataOperationKindHistory) {
        HistoryItemModel *itemModel = [self.historyDataManager historyModelForRowAtIndexPath:indexPath];
        tableCell.titleLabel.text = itemModel.title;
        tableCell.urlLabel.text = itemModel.url;
    }else{
        BookmarkItemModel *itemModel = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
        tableCell.titleLabel.text = itemModel.title;
        tableCell.urlLabel.text = itemModel.url;
    }
    
    
    
    return tableCell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listDataOperationKind == ListDataOperationKindHistory ? [_historyDataManager numberOfRowsInSection:section] : [_dataManager numberOfRowsInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_listDataOperationKind == ListDataOperationKindHistory) {
        HistoryItemModel *itemModel = [self.historyDataManager historyModelForRowAtIndexPath:indexPath];
        
        [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[itemModel.url] key:DelegateManagerBrowserContainerLoadURL];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        BookmarkItemModel *model = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
        
        if (model.url.length > 0) {
            [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[model.url] key:DelegateManagerBrowserContainerLoadURL];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}
#pragma mark - getData
- (void)getHistoryData{
    WEAK_REF(self)
    
    _historyDataManager = [[HistoryDataManager alloc] initWithCompletion:^(BOOL isNoMoreData){
        STRONG_REF(self_)
        if (self__) {
            
            if ([PreferenceHelper boolForKey:KeyHistoryModeStatus]) {
                
                [self__.historyDataManager deleleAllHistoryRecords];
            }
            [self__.mainTableView reloadData];
            
        }
    }];
}
-(void)getBookmarkData{
    WEAK_REF(self)
    self.dataManager = [[BookmarkDataManager alloc] initWithCompletion:^(NSArray<BookmarkSectionModel *> *array){
        if (self_) {
            [self_.mainTableView reloadData];
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
