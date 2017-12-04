//
//  YnSimpleInterest.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/28.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "YnSimpleInterest.h"

@implementation YnSimpleInterest
+(instancetype)shareSimpleInterest
{
    static YnSimpleInterest *simpleInterest = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        simpleInterest = [[self alloc]init];
        simpleInterest.isHaveNet = YES;
        simpleInterest.isUpdataCache = YES;
    });
    return simpleInterest;
}

@end
