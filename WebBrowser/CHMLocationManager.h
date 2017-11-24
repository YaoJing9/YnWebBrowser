//
//  CHMLocationManager.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/24.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHMLocationManager : NSObject
+ (instancetype)sharedInstance;
- (void)startLocation;
@end
