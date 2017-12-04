//
//  YnSimpleInterest.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/28.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YnSimpleInterest : NSObject

@property(nonatomic, strong)NSArray *searchTopAry;
@property(nonatomic, assign)BOOL isHaveNet;//是否有网络
@property(nonatomic, assign)BOOL isUpdataCache;//是否更新缓存数据

+(instancetype)shareSimpleInterest;
@end
