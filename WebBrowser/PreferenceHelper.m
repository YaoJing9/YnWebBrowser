//
//  PreferenceHelper.m
//  WebBrowser
//
//  Created by 钟武 on 2017/2/14.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "PreferenceHelper.h"

NSString * const KeyNoImageModeStatus = @"KeyNoImageModeStatus";
NSString * const KeyBlockBaiduADStatus = @"KeyBlockBaiduADStatus";
NSString * const KeyEyeProtectiveStatus = @"KeyEyeProtectiveStatus";
NSString * const KeyEyeProtectiveColorKind = @"KeyEyeProtectiveColorKind";
NSString * const KeyPasteboardURL = @"KeyPasteboardURL";

@implementation PreferenceHelper

#pragma mark - Setter Method

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:defaultName];
}

+ (void)setURL:(NSURL *)url forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setURL:url forKey:defaultName];
}

+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:defaultName];
}

#pragma mark - Getter Method

+ (BOOL)boolForKey:(NSString *)defaultName{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
    return [number boolValue];
}

+ (BOOL)boolDefaultYESForKey:(NSString *)defaultName{
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
    
    if (number == nil) {
        [self setBool:YES forKey:defaultName];
        return YES;
    }
    
    return [number boolValue];
}

+ (NSInteger)integerDefault1ForKey:(NSString *)defaultName{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:defaultName] == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:defaultName];
        return 1;
    }
    return [self integerForKey:defaultName];
}

+ (NSInteger)integerForKey:(NSString *)defaultName{
    return [[NSUserDefaults standardUserDefaults] integerForKey:defaultName];
}

+ (NSURL *)URLForKey:(NSString *)defaultName{
    return [[NSUserDefaults standardUserDefaults] URLForKey:defaultName];
}

@end
