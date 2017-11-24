//
//  QHLNetworkingTool.m
//
//  Created by apple on 16/4/20.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "CMNetworkingTool.h"

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


@end
