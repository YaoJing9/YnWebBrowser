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
        
        CGFloat bgViewLeft;
        CGFloat bgViewTop;
        CGFloat bgViewW;
        CGFloat bgViewH;
        
        bgViewLeft = (SCREENWIDTH - 351)/2;
        bgViewTop = (SCREENHEIGHT - 516)/2;
        bgViewW = 351.0;
        bgViewH = 516.0;
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(bgViewLeft, bgViewTop, bgViewW, bgViewH)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.userInteractionEnabled = YES;
        bgView.clipsToBounds = YES;
        bgView.layer.cornerRadius = 15;
        [bgBigView addSubview:bgView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:bgBigView action:@selector(clickBannerView:)];
        [bgView addGestureRecognizer:tapGesture];
        
    }
}

- (void)clickBannerView:(UITapGestureRecognizer *)tap{
    
    
    if (_insertionGgView.clickBlock) {
        _insertionGgView.clickBlock();
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
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


