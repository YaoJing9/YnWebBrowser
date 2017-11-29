//
//  ImgTitleView.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//


#import <UIKit/UIKit.h>
typedef void(^ImgTitleViewBlock)(NSInteger);

@interface ImgTitleView : UIView
@property(nonatomic, copy)ImgTitleViewBlock imgTitleViewBlock;
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *placeholderImage;
@property(nonatomic, copy)NSString *imageUrl;
-(instancetype)initWithFrame:(CGRect)frame imageView:(CGSize)imageSize gap:(CGFloat)gap font:(UIFont *)font color:(UIColor *)color tag:(NSInteger)tag;



@end
