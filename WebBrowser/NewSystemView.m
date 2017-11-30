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

+ (void)showInsertionViewtitle:(NSString *)title clickBlock:(ClickBlock)ClickBlock
{
    
    UIWindow *keyW = [UIApplication sharedApplication].keyWindow;
    NewSystemView *bgBigView = [[NewSystemView alloc] initWithFrame:keyW.bounds];
    
    if (bgBigView) {
        bgBigView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [keyW addSubview:bgBigView];
        bgBigView.clickBlock = ClickBlock;
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.clipsToBounds = YES;
        bgView.layer.cornerRadius = 15;
        [bgBigView addSubview:bgView];
        bgView.frame = CGRectMake(0, 0, (SCREENWIDTH - -345)/2, 222);
        bgView.centerX = bgBigView.centerX;
        bgView.centerY= bgBigView.centerY;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:bgBigView action:@selector(bgViewClick:)];
        [bgView addGestureRecognizer:tap];
        _bgView = bgView;
        
        UIImageView *imgView = [UIImageView new];
        imgView.userInteractionEnabled = YES;
        imgView.image = [UIImage imageNamed:@"更新图片"];
        imgView.frame = CGRectMake(0, 0, viewWidth(bgView), 150);
        [_bgView addSubview:imgView];
        
        UIButton *cancelBtn = [UIButton new];
        [cancelBtn setImage:[UIImage imageNamed:@"更新关闭"] forState:UIControlStateNormal];
        [cancelBtn addTarget:bgBigView action:@selector(cancelBtClick) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.frame = CGRectMake(viewWidth(bgView) - 50, 0, 50, 50);
        [_bgView addSubview:cancelBtn];
        
        UILabel *titleLable= [UILabel new];
        titleLable.frame = CGRectMake(0, MaxY(imgView), viewWidth(_bgView), viewHeight(_bgView) - MaxY(imgView));
        if ([YJHelp replaceNullValue:title].length != 0) {
            titleLable.text = title;
        }else{
            titleLable.text = @"浏览器更新";
        }
        titleLable.textColor = [UIColor colorWithHexString:@"#333333"];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.font = [UIFont systemFontOfSize:16];
        [_bgView addSubview:titleLable];
    }
}



- (void)bgViewClick:(UITapGestureRecognizer *)tap{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)cancelBtClick{
    [self removeBtnClick];
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
