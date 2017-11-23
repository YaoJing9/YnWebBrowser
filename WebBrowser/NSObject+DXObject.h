//
//  NSObject+DXObject.h
//  WebBrowser
//
//  Created by apple on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DXObject)
/**
 *  获取当前显示的viewcontroller
 *
 *  @return return 当前显示的vc
 */
- (UIViewController *)obtainTopViewController;
- (UIViewController*)obtainTopViewControllerWithRootViewController:(UIViewController*)rootViewController;
@end
