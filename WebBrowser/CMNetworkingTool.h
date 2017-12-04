//
//  QHLNetworkingTool.h
//
//  Created by apple on 16/4/20.
//  Copyright © 2016年 Apple. All rights reserved.
//
typedef NS_ENUM(NSInteger, NetworkingMethodType) {
    NetworkingMethodTypeGet = 0,
    NetworkingMethodTypePost,
    NetworkingMethodTypeDelete,
    NetworkingMethodTypePut,
    NetworkingMethodTypePatch
};

@interface CMNetworkingTool : AFHTTPSessionManager

+ (BOOL)isNullOrEmpty:(NSString *)str ;

+ (instancetype)sharedNetworkingTool;

- (void)requestWithMethod:(NetworkingMethodType)methodType
                urlString:(NSString *)urlString
               parameters:(id)parameters
                  success:(void (^)(NSURLSessionDataTask * dataTask, id responseObject))success
                  failure:(void (^)(NSURLSessionDataTask * dataTask, NSError * error))failure;

+ (NSMutableDictionary *)getPostDict;
+ (NSMutableDictionary *)getSearchPostDict;
+ (NSString *)appVersion;
+ (NSString *)appBundleId;
+ (NSString *)deviceName;

+ (void)isHaveNet;


@end
