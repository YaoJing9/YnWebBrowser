//
//  FirstBrowserControllerViewController.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/21.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "FirstBrowserController.h"
#import "TraderCell.h"
#import "BrowserBottomToolBar.h"
#import "ClassifyCell.h"
@interface FirstBrowserController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,BrowserBottomToolBarButtonClickedDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) BrowserBottomToolBar *bottomToolBar;
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, weak) id<BrowserBottomToolBarButtonClickedDelegate> browserButtonDelegate;

@end

@implementation FirstBrowserController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 44)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithObjects:@[@1,@145], @[@5,@50], @[@1,@173], nil];

    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self createHeaderView];
    [self creatteBottomView];
}

- (void)createHeaderView{
    UIView *bgView = [UIView new];
    bgView.frame = CGRectMake(0, 0, SCREENWIDTH, 215);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bgView.bounds];
    [bgView addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"版头"];
    _tableView.tableHeaderView = bgView;
    
    
    
        
    UILabel *lable=[[UILabel alloc] init];
    lable.layer.cornerRadius=5;
    lable.clipsToBounds=YES;
    lable.backgroundColor=[UIColor colorWithWhite:1 alpha:0.5];
    lable.userInteractionEnabled = YES;
    [bgView addSubview:lable];
    WS(weakSelf);
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(90);
        make.left.equalTo(bgView).offset(15);
        make.right.equalTo(weakSelf.view).offset(-15);
        make.height.equalTo(@32);
    }];
    
    UIImageView *leftImg = [UIImageView new];
    leftImg.image = [UIImage imageNamed:@"搜索"];
    [lable addSubview:leftImg];
    [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lable);
        make.left.equalTo(lable).offset(5);
        make.height.equalTo(@17);
        make.width.equalTo(@17);
    }];
    
    _textFiled=[[UITextField alloc] initWithFrame:CGRectMake(AUTOSIZEH(45), 27, SCREENWIDTH-AUTOSIZEH(130), 30)];
    _textFiled.delegate=self;
    _textFiled.textColor=[UIColor blackColor];
    _textFiled.font=[UIFont fontWithName:@"PingFangSC-Regular" size:15];
    _textFiled.placeholder=@"搜索或者输入网址";
    [_textFiled setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    _textFiled.keyboardType = UIKeyboardTypeASCIICapable;
    _textFiled.returnKeyType = UIReturnKeySearch;
    [lable addSubview:_textFiled];
    [_textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lable).offset(0);
        make.left.equalTo(leftImg.mas_right).offset(5);
        make.height.equalTo(lable);
        make.right.equalTo(lable);
    }];

    //监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoAction) name:UITextFieldTextDidChangeNotification object:nil];
    
    FL_Button *clowBtn;
    
    NSArray *buttonTitleArray = @[@"网址",@"小说",@"视频",@"奇趣",@"漫画"];
    
    for (int i=0; i<buttonTitleArray.count; i++) {
        FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setImage:[UIImage imageNamed:buttonTitleArray[i]] forState:UIControlStateNormal];
        button.tag = 100 + i;
        button.status = FLAlignmentStatusTop;
        button.fl_padding = 10;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:button];
        
        
        if (clowBtn) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(clowBtn);
                make.left.equalTo(clowBtn.mas_right);
                make.width.equalTo(clowBtn);
                make.height.equalTo(clowBtn);
            }];
        }else{
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lable.mas_bottom);
                make.left.equalTo(bgView);
                make.width.equalTo(@(SCREENWIDTH/5));
                make.bottom.equalTo(bgView);
            }];
            
        }
        clowBtn = button;
    }
    
    
}

- (void)buttonAction:(UIButton *)btn{
    
    
}

#pragma mark-键盘的监听事件
-(void)infoAction{
    
    if (_textFiled.text.length == 0) {

        return;
    }
    
}

- (void)creatteBottomView{
        self.bottomToolBar = [[BrowserBottomToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOL_BAR_HEIGHT, self.view.width, BOTTOM_TOOL_BAR_HEIGHT)];
//        self.bottomToolBar.delegate = self;
        [self.view addSubview:self.bottomToolBar];
        [self.view addSubview:self.bottomToolBar];
}

#pragma mark - UITableViewDelegate，UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [self.dataArr[section][0] integerValue];
    return number;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = [self.dataArr[indexPath.section][1] floatValue];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else{
        return 46;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *imageAry = @[@"",@"快速导航", @"生活服务"];
    
    if (section == 0) {
        return nil;
    }else{
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 46)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        
        
        UIView *bottomView = [UIView new];
        [bgView addSubview:bottomView];
        bottomView.backgroundColor = [UIColor whiteColor];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgView).offset(7);
            make.left.right.bottom.equalTo(bgView);
        }];
        
        FL_Button *btn = [FL_Button new];
        [btn setTitle:imageAry[section] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imageAry[section]] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor  colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        btn.status = FLAlignmentStatusImageLeft;
        btn.fl_padding = 7;
        [bottomView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomView);
            make.left.equalTo(bottomView).offset(15);
            make.right.bottom.equalTo(bottomView);
        }];
        
        UIImageView *sendLine = [UIImageView new];
        sendLine.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        [bgView addSubview:sendLine];
        [sendLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(bgView);
            make.height.mas_equalTo(0.5);
        }];
        
        return bgView;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        NSArray *buttonTitleArray = @[@"新浪",@"百度",@"微博",@"二手车",@"同城",@"淘宝",@"携程",@"苏宁",@"优酷"];

        ClassifyCell *classifyCell = [ClassifyCell cellWithTableView:tableView reuseIdentifier:@"ClassifyCell" imageAry:buttonTitleArray];
        return classifyCell;
    }else if (indexPath.section == 1){
//        TraderCell *cell = [TraderCell cellWithTableView:tableView reuseIdentifier:@"VoiceCell" titleAry:_];
        return nil;
    }else{
        NSArray *buttonTitleArray = @[@"订酒店",@"订机票",@"火车票",@"电影票",@"美食",@"同城",@"租房",@"找工作",@"家政服务",@"兼职"];

        ClassifyCell *classifyCell = [ClassifyCell cellWithTableView:tableView reuseIdentifier:@"ClassifyCell" imageAry:buttonTitleArray];
        return classifyCell;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
