//
//  CardMainBottomView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/22.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardMainBottomView.h"

@interface CardMainBottomView ()

@property (nonatomic, strong) UIButton * returnButton;
@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, strong) UIButton * closeAllButton;

@end

@implementation CardMainBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit{
    self.backgroundColor = ColorRedGreenBlue(48, 48, 48);
    
    self.closeAllButton = [self createBottomToolBarButtonWithTitle:@"关闭全部" tag:CloseAllButtonClicked yFrame:0];
    [self addSubview:self.closeAllButton];
    
    self.addButton = [self createBottomToolBarButtonWithImage:@"card-add" tag:AddButtonClicked yFrame:self.width/3];
    [self addSubview:self.addButton];

    self.returnButton = [self createBottomToolBarButtonWithTitle:@"完成" tag:ReturnButtonClicked yFrame:self.width/3*2];
    [self addSubview:self.returnButton];
}


- (UIButton *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag yFrame:(NSInteger)yFrame{
    UIButton *item = [[UIButton alloc] init];
    item.frame = CGRectMake(yFrame, 0, self.width/3, self.height);
    [item setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    item.tag = tag;
    [item addTarget:self action:@selector(handleButtonClickedWithButton:) forControlEvents:UIControlEventTouchUpInside];
    return item;
}

- (UIButton *)createBottomToolBarButtonWithTitle:(NSString *)imageName tag:(NSInteger)tag yFrame:(NSInteger)yFrame{
    UIButton *item = [[UIButton alloc] init];
    item.frame = CGRectMake(yFrame, 0, self.width/3, self.height);
    [item setTitle:imageName forState:UIControlStateNormal];
    item.tag = tag;
    [item addTarget:self action:@selector(handleButtonClickedWithButton:) forControlEvents:UIControlEventTouchUpInside];
    return item;
}



- (void)handleButtonClickedWithButton:(UIButton *)button{
    if ([self.bottomDelegate respondsToSelector:@selector(cardBottomBtnClickedWithTag:)]) {
        [self.bottomDelegate cardBottomBtnClickedWithTag:button.tag];
    }
}

@end
