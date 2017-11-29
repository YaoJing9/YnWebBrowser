//
//  NewSystemView.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NewSystemView.h"

static NewSystemView *_insertionGgView;
static UIView *_bgView;

@implementation NewSystemView
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

+ (void)showInsertionView:(ClickBlock)clickBlock
{
    
    UIWindow *keyW = [UIApplication sharedApplication].keyWindow;
    NewSystemView *bgBigView = [[NewSystemView alloc] initWithFrame:keyW.bounds];
    
    if (bgBigView) {
        bgBigView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [keyW addSubview:bgBigView];
        
        bgBigView.clickBlock = clickBlock;
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.clipsToBounds = YES;
        bgView.layer.cornerRadius = 15;
        [bgBigView addSubview:bgView];
        bgView.frame = CGRectMake(0, 0, SCREENWIDTH - 20, 200);
        bgView.centerX = bgBigView.centerX;
        bgView.centerY= bgBigView.centerY;
        _bgView = bgView;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:bgBigView action:@selector(clickBannerView:)];
        [bgBigView addGestureRecognizer:tapGesture];
    }
}



- (void)clickBannerView:(UITapGestureRecognizer *)tap{
    [self removeBtnClick];
    
    if (self.clickBlock) {
        self.clickBlock();
    }
    
}

- (void)removeBtnClick{

    [_insertionGgView removeFromSuperview];
    _insertionGgView = nil;
}

+ (void)removeMoreSettingView{
    [_insertionGgView removeFromSuperview];
    _insertionGgView = nil;
}

- (void)showMoreSettingView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        _bgView.mj_y = SCREENHEIGHT - 263;
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
