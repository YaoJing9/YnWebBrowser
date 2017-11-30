//
//  HistoryAndBookmarkListViewController.m
//  WebBrowser
//
//  Created by apple on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.

#import "HistoryAndBookmarkListViewController.h"
#import "HistoryAndBookmarkTableViewCell.h"
#import "HistoryDataManager.h"
#import "BookmarkDataManager.h"
#import "PreferenceHelper.h"
#import "BrowserViewController.h"
static NSString *const HistoryAndBookmarkListTableViewCellIdentifier   = @"HistoryAndBookmarkListTableViewCellIdentifier";
@interface HistoryAndBookmarkListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) HistoryDataManager *historyDataManager;
@property (nonatomic, strong) BookmarkDataManager *dataManager;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation HistoryAndBookmarkListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showNavWithTitle:@"书签列表" backBtnHiden:NO rightBtnTitle:@"清除" rightBtnImage:nil];
    
    _mainTableView.tableFooterView = [UIView new];
    
    _listDataOperationKind = ListDataOperationKindBookmark;
    [self getBookmarkData];
    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - ButtonAction
-(void)rightBtnAction{
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
        
    }else{
        
        //获取历史数据
        _listDataOperationKind = ListDataOperationKindHistory;
        [self getHistoryData];
        
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
        
    }else{
        BookmarkItemModel *model = [self.dataManager bookmarkModelForRowAtIndexPath:indexPath];
        
        if (model.url.length > 0) {
            [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[model.url] key:DelegateManagerBrowserContainerLoadURL];
        }
    }
    if (_fromVCComeInKind == FromVCComeInKindROOTVC) {
        BrowserViewController *vc = [BrowserViewController new];
        [self.navigationController pushViewController:vc animated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:NO];
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
