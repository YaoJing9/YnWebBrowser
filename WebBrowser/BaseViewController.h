//
//  BaseViewController.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/14.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
@property (nonatomic, strong) NSMutableDictionary *loadingUrlDict;
@property (nonatomic, strong) UIView *NAVview;
@property (nonatomic, strong) UIView *NAVLine;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *centreLabel;
@property (nonatomic, strong) UITableView *supTableView;


-(void)backClick:(UIButton*)btn;

-(void)rightBtnAction;

- (void)showNavWithTitle:(NSString *)str backBtnHiden:(BOOL)hiden;

- (void)showNavWithTitle:(NSString *)str backBtnHiden:(BOOL)hiden rightBtnTitle:(NSString *)rightBtnTitle rightBtnImage:(NSString *)rightBtnImage;

- (void)showCustomeNavBackBtnHiden:(BOOL)hiden;


@end
