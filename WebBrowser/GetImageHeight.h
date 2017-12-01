//
//  GetImageHeight.h
//  WebBrowser
//
//  Created by zhxixh_pc on 2017/12/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GetImageHeight : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GetImageHeight)
+(CGFloat)getImageHeight:(CGFloat)imageWidth;
@end
