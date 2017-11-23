//
//  NSObject+DXObject.m
//  WebBrowser
//
//  Created by apple on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NSObject+DXObject.h"

@implementation NSObject (DXObject)
/**
 *  获取当前显示的viewcontroller
 *
 *  @return return 当前显示的vc
 */
- (UIViewController *)obtainTopViewController{
    return [self obtainTopViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}
- (UIViewController*)obtainTopViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self obtainTopViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self obtainTopViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self obtainTopViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
@end
