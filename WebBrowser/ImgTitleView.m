//
//  ImgTitleView.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ImgTitleView.h"

@implementation ImgTitleView

-(instancetype)initWithFrame:(CGRect)frame imageView:(CGSize)imageSize gap:(CGFloat)gap{
    if (self = [super initWithFrame:frame]) {
        [self createSubViews:imageSize gap:gap];
    }
    return self;
}

- (void)createSubViews:(CGSize)imageSize gap:(CGFloat)gap{
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    imageView.centerX = self.centerX;
}

@end
