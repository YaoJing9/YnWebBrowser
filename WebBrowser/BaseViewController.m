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
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏

}

@end
