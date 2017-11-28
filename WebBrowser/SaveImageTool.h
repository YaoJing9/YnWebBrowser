//
//  SaveImageTool.h
//  WebBrowser
//
//  Created by apple on 2017/11/28.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveImageTool : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SaveImageTool)

//将图片保存到本地
- (void)SaveImageToLocal:(UIImage*)image Keys:(NSString*)key;

//本地是否有相关图片
- (BOOL)LocalHaveImage:(NSString*)key;

//从本地获取图片
- (UIImage*)GetImageFromLocal:(NSString*)key;
@end
