//
//  MoreSettingView.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "MoreSettingView.h"

static MoreSettingView *_insertionGgView;

@implementation MoreSettingView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (_insertionGgView) {
        return nil;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        _insertionGgView = self;
    }
    return self;
}


+ (void)showInsertionViewSuccessBlock:(InsertionSuccessBlock)successBlock clickBlock:(ClickBlock)clickBlock removeBlock:(RemoveBlock)removeBlock
{
    
    UIWindow *keyW = [UIApplication sharedApplication].keyWindow;
    MoreSettingView *bgBigView = [[MoreSettingView alloc] initWithFrame:keyW.bounds];
    
    if (bgBigView) {
        bgBigView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [keyW addSubview:bgBigView];
        
        bgBigView.clickBlock = clickBlock;
        bgBigView.removeBlock = removeBlock;
        bgBigView.successBlock = successBlock;
    
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.userInteractionEnabled = YES;
        bgView.clipsToBounds = YES;
        bgView.layer.cornerRadius = 15;
        [bgBigView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.right.equalTo(@-10);
            make.height.equalTo(@250);
            make.bottom.equalTo(bgBigView.mas_bottom).offset(-44);
        }];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:bgBigView action:@selector(clickBannerView:)];
        [bgBigView addGestureRecognizer:tapGesture];
        
        
        WS(weakSelf);
        
        FL_Button *clowBtn;
        
        NSArray *buttonTitleArray = @[@"全屏模式",@"夜间模式",@"无图模式",@"无痕模式",@"我的视频",@"书签／历史",@"添加书签",@"分享",@"设置"];
        NSInteger btnW = (SCREENWIDTH - 20)/5.0;
        for (int i=0; i<buttonTitleArray.count; i++) {
            FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
            [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            [button setImage:[UIImage imageNamed:buttonTitleArray[i]] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
            button.tag = 100 + i;
            button.status = FLAlignmentStatusTop;
            button.backgroundColor = [UIColor redColor];
            button.fl_padding = 10;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:button];
            
            
            
            
            if (clowBtn) {
                
                
                if (i < 5) {
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(clowBtn);
                        make.left.equalTo(clowBtn.mas_right);
                        make.width.equalTo(clowBtn);
                        make.height.equalTo(clowBtn);
                    }];
                }else if (i == 5){
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(@(250/3.0 + 20));
                        make.left.equalTo(bgView);
                        make.width.equalTo(clowBtn);
                        make.height.equalTo(clowBtn);
                    }];
                }else{
                    [button mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(clowBtn);
                        make.left.equalTo(clowBtn.mas_right);
                        make.width.equalTo(clowBtn);
                        make.height.equalTo(clowBtn);
                    }];
                }
                
            }else{
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(bgView).offset(20);
                    make.left.equalTo(bgView);
                    make.width.equalTo(@(btnW));
                    make.height.equalTo(@(250/3.0));
                }];
                
            }
            clowBtn = button;
        }
        
        FL_Button *closeBtn = [FL_Button buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"下拉"] forState:UIControlStateNormal];
        [bgView addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(bgView.mas_bottom).offset(-20);
            make.centerX.equalTo(bgView);
        }];
        closeBtn.userInteractionEnabled = NO;

        
    }
}

- (void)clickBannerView:(UITapGestureRecognizer *)tap{
    [self removeBtnClick];
}

- (void)removeBtnClick{
    
    [_insertionGgView removeFromSuperview];
    if (_insertionGgView.removeBlock) {
        _insertionGgView.removeBlock();
    }
    _insertionGgView = nil;
}

@end


