//
//  BookmarkEditBaseViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/10.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BookmarkEditBaseViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkEditTextFieldTableViewCell.h"

NSString *const kBookmarkEditTextFieldCellIdentifier = @"kBookmarkEditTextFieldCellIdentifier";

@interface BookmarkEditBaseViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BookmarkEditBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self showNavWithTitle:@"添加书签" backBtnHiden:NO rightBtnTitle:@"保存" rightBtnImage:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - 64) style:UITableViewStyleGrouped];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookmarkEditTextFieldTableViewCell class]) bundle:nil] forCellReuseIdentifier:kBookmarkEditTextFieldCellIdentifier];
    
    _tableView.tableFooterView = [UIView new];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}
-(void)rightBtnAction{
    
}
- (void)initData{
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView reloadData];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Handle NavigationItem Clicked

- (void)handleDoneItemClicked{}

- (void)exit{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - Dealloc

- (void)dealloc{
    //DDLogDebug(@"%@ dealloced",NSStringFromClass([self class]));
}

@end
