//
//  BaseViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/14.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.navigationController.navigationBar.barTintColor = MyColor;
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏
    self.view.backgroundColor = appBgColor;
}

- (void)naLeftButtonClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 *设置导航条
 */
- (void)showNavWithTitle:(NSString *)str backBtnHiden:(BOOL)hiden{
    _NAVview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    _NAVview.backgroundColor=[UIColor whiteColor];
    _NAVview.alpha = 1.0;
    WS(weakSelf);
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.view addSubview:_NAVview];
    });
    
    if (hiden){}else {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 20, 44, 44);
        [btn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeCenter;
        [btn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [_NAVview addSubview:btn];
        _leftBtn = btn;
        //打开右划交互
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
    
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(44, 20, SCREENWIDTH-88, 44)];
    lab.textAlignment=NSTextAlignmentCenter;
    lab.text=str;
    lab.font=APPFont(7);
    lab.textColor=[UIColor colorWithHexString:@"#333333"];
    [_NAVview addSubview:lab];
    _centreLabel = lab;
    _NAVLine = [YJHelp addLiveViewTo:_NAVview frame:CGRectMake(0, 63.5, SCREENWIDTH, 0.5)];
}

- (void)showCustomeNavBackBtnHiden:(BOOL)hiden{
    _NAVview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    _NAVview.backgroundColor=[UIColor whiteColor];
    _NAVview.alpha = 1.0;
    [self.view addSubview:_NAVview];
    
    if (hiden){}else {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 20, 44, 44);
        [btn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeCenter;
        [btn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [_NAVview addSubview:btn];
        _leftBtn = btn;
        //打开右划交互
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
        _NAVLine = [YJHelp addLiveViewTo:_NAVview frame:CGRectMake(0, 63.5, SCREENWIDTH, 0.5)];
    
    
}


/**
 *设置带右按钮导航条
 */
- (void)showNavWithTitle:(NSString *)str backBtnHiden:(BOOL)hiden rightBtnTitle:(NSString *)rightBtnTitle rightBtnImage:(NSString *)rightBtnImage;
{
    _NAVview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    _NAVview.backgroundColor=[UIColor whiteColor];
    _NAVview.alpha = 1.0;
    if (hiden){}else{
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 20, 44, 44);
        [btn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeCenter;
        [btn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
        [_NAVview addSubview:btn];
        _leftBtn = btn;
        //打开右划交互
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.titleLabel.font = APPFont(4);
    NSDictionary *dict = @{NSFontAttributeName:APPFont(4)};
    CGSize size = [rightBtnTitle sizeWithAttributes:dict];
    rightBtn.frame = CGRectMake(SCREENWIDTH - size.width - 15, 20, size.width + 15, 44);
    [rightBtn setImage:[UIImage imageNamed:rightBtnImage] forState:UIControlStateNormal];
    [rightBtn setTitle:rightBtnTitle forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_NAVview addSubview:rightBtn];
    _rightBtn = rightBtn;
    
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 44)];
    lab.textAlignment=NSTextAlignmentCenter;
    lab.text=str;
    lab.font=APPFont(8);
    lab.textColor=appBlackColor;
    [_NAVview addSubview:lab];
    _centreLabel = lab;
    
    UIImageView *sendLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 63.5, SCREENWIDTH, 0.5)];
    sendLine.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [_NAVview addSubview:sendLine];
    _NAVLine = sendLine;
    
    WS(weakSelf);
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.view addSubview:weakSelf.NAVview];
    });
}

//返回按钮方法
-(void)backClick:(UIButton*)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

//右按钮方法
-(void)rightBtnAction{
    
}



-(void)dealloc
{
    NSLog(@"qwdoqwdiowqjdi");
}
@end

