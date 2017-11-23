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


static NSString *const HistoryAndBookmarkListTableViewCellIdentifier   = @"HistoryAndBookmarkListTableViewCellIdentifier";
@interface HistoryAndBookmarkListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) HistoryDataManager *historyDataManager;
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
    self.title = _listDataOperationKind == ListDataOperationKindHistory ? @"浏览历史" : @"书签列表";
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)historyAndBookmarkAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        //获取书签数据
    }else{
        //获取历史数据
        [self getHistoryData];
        [self.mainTableView reloadData];
    }
}
#pragma mark - ButtonAction

#pragma mark - TableViewDelegate && TableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryAndBookmarkTableViewCell *tableCell = [self.mainTableView dequeueReusableCellWithIdentifier:HistoryAndBookmarkListTableViewCellIdentifier];
    if (tableCell == nil) {
        tableCell = [[HistoryAndBookmarkTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HistoryAndBookmarkListTableViewCellIdentifier];
    }
    HistoryItemModel *itemModel = [self.historyDataManager historyModelForRowAtIndexPath:indexPath];
    tableCell.titleLabel.text = itemModel.title;
    tableCell.urlLabel.text = itemModel.url;
    
    return tableCell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_historyDataManager numberOfRowsInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}


- (void)getHistoryData{
    WEAK_REF(self)
    _historyDataManager = [[HistoryDataManager alloc] initWithCompletion:^(BOOL isNoMoreData){
        STRONG_REF(self_)
        if (self__) {
            [self__.mainTableView reloadData];
            
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
