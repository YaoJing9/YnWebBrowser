//
//  ImgTitleView.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ImgTitleView.h"

@implementation ImgTitleView

-(instancetype)initWithFrame:(CGRect)frame imageView:(CGSize)imageSize gap:(CGFloat)gap font:(UIFont *)font color:(UIColor *)color tag:(NSInteger)tag{
    if (self = [super initWithFrame:frame]) {
        self.tag = tag;
        [self createSubViews:imageSize gap:gap font:font color:color];
    }
    return self;
}

- (void)createSubViews:(CGSize)imageSize gap:(CGFloat)gap font:(UIFont *)font color:(UIColor *)color{
    _imageView = [UIImageView new];
    _imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    _imageView.centerX = self.width/2;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = font;
    _titleLabel.textColor = color;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.userInteractionEnabled = YES;
    _titleLabel.frame = CGRectMake(0, MaxY(_imageView) + gap, self.width, self.height - gap - MaxY(_imageView));
    [self addSubview:_titleLabel];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgTitleViewClick:)];
    [self addGestureRecognizer:tap];
}

- (void)setTitle:(NSString *)title{
    _titleLabel.text = title;
//    [_titleLabel sizeToFit];
}

- (void)setPlaceholderImage:(NSString *)placeholderImage{
    _placeholderImage = placeholderImage;
}

- (void)setImageUrl:(NSString *)imageUrl{
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:_placeholderImage]];
}

- (void)imgTitleViewClick:(UITapGestureRecognizer *)tap{
    if (self.imgTitleViewBlock) {
        self.imgTitleViewBlock(tap.view.tag - 100);
    }
}

@end
