//
//  MoreSettingView.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "MoreSettingView.h"

static MoreSettingView *_insertionGgView;
static UIView *_bgView;

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

+ (void)showInsertionViewSuccessBlock:(InsertionSuccessBlock)successBlock clickBlock:(ClickBlock)clickBlock removeBlock:(RemoveBlock)removeBlock btnClickBlock:(BtnClickBlock)btnClickBlock isFirsr:(BOOL)isFirst
{
    
    UIWindow *keyW = [UIApplication sharedApplication].keyWindow;
    MoreSettingView *bgBigView = [[MoreSettingView alloc] initWithFrame:keyW.bounds];
    
    if (bgBigView) {
        bgBigView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [keyW addSubview:bgBigView];
        
        bgBigView.clickBlock = clickBlock;
        bgBigView.removeBlock = removeBlock;
        bgBigView.successBlock = successBlock;
        bgBigView.btnClickBlock = btnClickBlock;
        
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.clipsToBounds = YES;
        bgView.layer.cornerRadius = 15;
        [bgBigView addSubview:bgView];
        bgView.frame = CGRectMake(10, SCREENHEIGHT, SCREENWIDTH - 20, 253);

        _bgView = bgView;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:bgBigView action:@selector(clickBannerView:)];
        [bgBigView addGestureRecognizer:tapGesture];
        FL_Button *clowBtn;
        
        NSArray *buttonTitleArray = @[@"全屏模式",@"夜间模式",@"无图模式",@"无痕模式",@"书签／历史",@"添加书签",@"设置", @"刷新"];
        NSInteger btnW = (SCREENWIDTH - 20)/5.0;
        for (int i=0; i<buttonTitleArray.count; i++) {
            FL_Button *flbutton = [FL_Button new];
            [flbutton setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
            flbutton.titleLabel.font = [UIFont systemFontOfSize:12];
            [flbutton setImage:[UIImage imageNamed:buttonTitleArray[i]] forState:UIControlStateNormal];
            [flbutton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
            
            if (i == 0) {
                [flbutton setImage:[UIImage imageNamed:@"全屏模式选中"] forState:UIControlStateSelected];
                flbutton.selected = [PreferenceHelper boolForKey:KeyFullScreenModeStatus];

            }
            if (i == 1) {
                [flbutton setImage:[UIImage imageNamed:@"夜间模式选中"] forState:UIControlStateSelected];
                flbutton.selected = [PreferenceHelper boolForKey:KeyEyeProtectiveStatus];

            }
            if (i == 2) {
                [flbutton setImage:[UIImage imageNamed:@"无图模式选中"] forState:UIControlStateSelected];
                flbutton.selected = [PreferenceHelper boolForKey:KeyNoImageModeStatus];

            }
            if (i == 3) {
                [flbutton setImage:[UIImage imageNamed:@"无痕模式选中"] forState:UIControlStateSelected];
                flbutton.selected = [PreferenceHelper boolForKey:KeyHistoryModeStatus];
            }
            
            if (i == 5) {
                [flbutton setImage:[UIImage imageNamed:@"添加书签选中"] forState:UIControlStateSelected];
                if (isFirst) {
                    flbutton.selected = YES;
                    flbutton.enabled = NO;
                }else{
                    BOOL se = [PreferenceHelper boolForKey:KeyHaveBookMarkModeStatus];
                    flbutton.selected = se;
                }

            }
            
            flbutton.tag = 100 + i;
            flbutton.fl_imageWidth = 45;
            flbutton.fl_imageHeight = 45;
            flbutton.status = FLAlignmentStatusTop;
            flbutton.fl_padding = 0;
            [flbutton addTarget:bgBigView action:@selector(flbuttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:flbutton];            
            
            
            if (clowBtn) {
                
                
                if (i < 5) {
                    [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(clowBtn);
                        make.left.equalTo(clowBtn.mas_right);
                        make.width.equalTo(clowBtn);
                        make.height.equalTo(clowBtn);
                    }];
                }else if (i == 5){
                    [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(@(253/3.0 + 20));
                        make.left.equalTo(bgView);
                        make.width.equalTo(clowBtn);
                        make.height.equalTo(clowBtn);
                    }];
                }else{
                    [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(clowBtn);
                        make.left.equalTo(clowBtn.mas_right);
                        make.width.equalTo(clowBtn);
                        make.height.equalTo(clowBtn);
                    }];
                }
                
            }else{
                [flbutton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(bgView).offset(20);
                    make.left.equalTo(bgView);
                    make.width.equalTo(@(btnW));
                    make.height.equalTo(@(253/3.0));
                }];
                
            }
            clowBtn = flbutton;
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
    
    [bgBigView showMoreSettingView];
}

- (void)flbuttonAction:(FL_Button *)btn{
    
    NSInteger index = btn.tag - 100;
    
    switch (index) {
        case 0:
            btn.selected = !btn.selected;
            break;
        case 1:
            btn.selected = !btn.selected;
            break;
        case 2:
            btn.selected = !btn.selected;
            break;
        case 3:
            btn.selected = !btn.selected;
            break;
        default:
            break;
    }
    
    
    if (_insertionGgView.btnClickBlock) {
        _insertionGgView.btnClickBlock(index);
    }
}

- (void)clickBannerView:(UITapGestureRecognizer *)tap{
    [self removeBtnClick];
}

- (void)removeBtnClick{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _bgView.mj_y = SCREENHEIGHT;
        
    } completion:^(BOOL finished) {
        [_insertionGgView removeFromSuperview];
        if (_insertionGgView.removeBlock) {
            _insertionGgView.removeBlock();
        }
        _insertionGgView = nil;
    }];
    

}

+ (void)removeMoreSettingView{
    [_insertionGgView removeFromSuperview];
    if (_insertionGgView.removeBlock) {
        _insertionGgView.removeBlock();
    }
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


