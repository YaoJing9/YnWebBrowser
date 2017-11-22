//
//  HistoryAndBookmarkListViewController.m
//  WebBrowser
//
//  Created by apple on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryAndBookmarkListViewController.h"

static NSString *const HistoryAndBookmarkListTableViewCellIdentifier   = @"HistoryAndBookmarkListTableViewCellIdentifier";
@interface HistoryAndBookmarkListViewController ()<UITableViewDelegate,UITableViewDataSource>
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
#pragma mark - TableViewDelegate && TableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tableCell = [self.mainTableView dequeueReusableCellWithIdentifier:HistoryAndBookmarkListTableViewCellIdentifier];
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:HistoryAndBookmarkListTableViewCellIdentifier];
        
        tableCell.textLabel.font = [UIFont systemFontOfSize:14];
        tableCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    }
    tableCell.textLabel.text = @"1";
    tableCell.detailTextLabel.text = @"2";
    tableCell.imageView.image = [UIImage imageNamed:@"compas"];
    
    return tableCell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
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
