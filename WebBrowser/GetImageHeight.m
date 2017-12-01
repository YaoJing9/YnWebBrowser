//
//  GetImageHeight.m
//  WebBrowser
//
//  Created by zhxixh_pc on 2017/12/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "GetImageHeight.h"

@implementation GetImageHeight
SYNTHESIZE_SINGLETON_FOR_CLASS(GetImageHeight)

+(CGFloat)getImageHeight:(CGFloat)imageWidth{
    CGFloat imageHeight = (166 / 750.0) * imageWidth;
    return imageHeight;
}


@end
