//
//  QHLNetworkingTool.m
//
//  Created by apple on 16/4/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "CMNetworkingTool.h"
#import <AdSupport/AdSupport.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

// 申明一个协议方法
@protocol CMNetworkingTollProxy <NSObject>

@optional
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end

@interface CMNetworkingTool ()<CMNetworkingTollProxy>

@end

@implementation CMNetworkingTool

+ (BOOL)isNullOrEmpty:(NSString *)str {
    return ([str isEqualToString:@""] || str == nil);
}

+ (instancetype)sharedNetworkingTool {
    
    static CMNetworkingTool *instance;
    
    // 执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 初始化工具
        instance = [[CMNetworkingTool alloc] init];
    });
    
    return instance;
}

- (void)requestWithMethod:(NetworkingMethodType)methodType
                urlString:(NSString *)urlString
               parameters:(id)parameters
                  success:(void (^)(NSURLSessionDataTask * dataTask, id responseObject))success
                  failure:(void (^)(NSURLSessionDataTask * dataTask, NSError * error))failure {
    
    NSString *method = nil;
    
    if (methodType == NetworkingMethodTypeGet) {
        method = @"GET";
    } else if(methodType == NetworkingMethodTypePost) {
        method = @"POST";
        parameters = [parameters mj_JSONObject];
        
    }else if (methodType == NetworkingMethodTypePut)
    {
        method = @"PUT";
    }else if (methodType == NetworkingMethodTypeDelete){
        method = @"DELETE";
    }else if (methodType == NetworkingMethodTypePatch){
        method = @"PATCH";
    }
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    self.responseSerializer = [AFJSONResponseSerializer serializer];

    // 判断 2 种不同方式的网络请求
    [[self dataTaskWithHTTPMethod:method
                        URLString:urlString
                       parameters:parameters
                   uploadProgress:nil
                 downloadProgress:nil
                          success:success
                          failure:failure] resume];
    
    
}
- (void)postWithUrlString:(NSString *)url parameters:(id)parameters
                  success:(void (^)(NSURLSessionDataTask *, id))success
                  failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
{
    
    NSURL *urls = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urls];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //设置请求头touken


    NSString *returnString=[parameters mj_JSONString];
    NSData *bodyData = [returnString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session
                                  dataTaskWithRequest:request
                                  completionHandler:^(NSData *
                                                      _Nullable data,
                                                      NSURLResponse * _Nullable response,
                                                      NSError * _Nullable error) {
                                      if ([NSThread isMainThread])
                                      {
                                          if (error) {
                                              failure(nil,error);
                                          }else{
                                              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                              success(nil,dict);
                                          }
                                      }
                                      else
                                      {
                                          dispatch_sync(dispatch_get_main_queue(), ^{
                                              if (error) {
                                                  failure(nil,error);
                                              }else{
                                                  NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                                  success(nil,dict);
                                              }
                                          });
                                      }
                                                                       }];
    [task resume];
}

//获取idfa
+ (NSString *)deviceIdfa
{
    NSString *deviceIDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
    return deviceIDFA;
}

//系统名称sysname
+ (NSString *)systemName
{
    return [NSString stringWithFormat:@"%@-%@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
}

//设备类型devtype
+ (NSString *)deviceType
{
    return [self platformString];
}
+ (NSString *) platformString{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";//添加iPhone SE
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod touch";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro";
    
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([platform isEqualToString:@"Watch1,1"])     return @"Apple Watch";
    if ([platform isEqualToString:@"Watch1,2"])     return @"Apple Watch";
    
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4G";
    
    return platform;
}

//应用bundleId
+ (NSString *)appBundleId
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

//版本号
+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

//应用名称
+ (NSString *)appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

//WiFi名称
+ (NSString *)wifiName
{
    if ([[self ssIDInfo] count] > 0) {
        
        return ((NSString *)[self ssIDInfo][@"SSID"]).length > 0 ? [self ssIDInfo][@"SSID"]:@"";
        
    }else
    {
        return @"";
    }
}
//路由信息
+ (NSDictionary *)ssIDInfo
{
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    if (!ifs) {
        return nil;
    }
    
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return info;
}

//设备名称
+ (NSString *)deviceName
{
    return [UIDevice currentDevice].name;
}


//是否在充电
+ (BOOL)isCharging
{
    NSLog(@"charging:%ld",(long)[UIDevice currentDevice].batteryState);
    if ([UIDevice currentDevice].batteryState == UIDeviceBatteryStateCharging) {
        return YES;
    }
    return NO;
}

//是否安装SIM卡
+ (BOOL)isSIMInstalled
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    if (!carrier.isoCountryCode) {
        NSLog(@"No sim present Or No cellular coverage or phone is on airplane mode.");
        return NO;
    }
    return YES;
}

//是否允许访问idfa
+ (NSNumber *)adTrackingEnabled
{
    // 1允许 0 不允许
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        return [NSNumber numberWithInteger:1];
    }else
    {
        return [NSNumber numberWithInteger:0];
    }
}

+ (NSMutableDictionary *)getPostDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    
    [dict setValue:[NSNumber numberWithBool:[self isCharging]] forKey:@"ischarging"];
    [dict setValue:[self adTrackingEnabled] forKey:@"adtrackingenabled"];
    [dict setValue:[NSNumber numberWithBool:[self isSIMInstalled]] forKey:@"issiminstalled"];

    
    
    [dict setValue:[self deviceIdfa] forKey:@"idfa"];
    [dict setValue:[self systemName] forKey:@"sysname"];
    [dict setValue:[self deviceType] forKey:@"devtype"];
    [dict setValue:[self appBundleId] forKey:@"bid"];
    [dict setValue:[self appVersion] forKey:@"appversion"];
    [dict setValue:[self appName] forKey:@"appname"];
    [dict setValue:[self wifiName] forKey:@"wifiname"];
    [dict setValue:[self deviceName] forKey:@"device_name"];
    return dict;
    
}

@end
