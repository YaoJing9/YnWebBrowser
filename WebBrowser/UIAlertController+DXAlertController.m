//
//  UIAlertController+DXAlertController.m
//  WebBrowser
//
//  Created by apple on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "UIAlertController+DXAlertController.h"
#import "NSObject+DXObject.h"

@implementation UIAlertController (DXAlertController)
/**
 *  alertView
 *  @param  nameArr 按钮的标题数组
 *  @param  title 提示框的标题
 *  @param  message 提示消息
 *  @param  callBack 点击回调包含index和内容
 *  @return return UIAlertController(AlertView)
 */
+ (nullable instancetype)wl_showAlertViewWithActionsName:(nonnull NSArray <NSString *> *)nameArr title:(nullable NSString *)title message:(nullable NSString *)message callBack:(void(^ __nullable)(NSString * _Nonnull btnTitle,NSInteger btnIndex))callBack{
    UIAlertController * alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSInteger i = 0; i < nameArr.count; i++) {
        [alertView addAction:[UIAlertAction actionWithTitle:nameArr[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callBack) {
                callBack(nameArr[i],i);
            }
        }]];
    }
    [alertView addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[NSObject obtainTopViewController] presentViewController:alertView animated:YES completion:nil];
    return alertView;
}
/**
 *  actionSheet
 *  @param  nameArr 按钮的标题数组
 *  @param  callBack 点击回调包含index和内容
 *  @return return UIAlertController(ActionSheet)
 */
+ (nullable instancetype)wl_showActionSheetWithActionsName:(nonnull NSArray <NSString *> *)nameArr callBack:(void(^ __nullable)(NSString * __nullable btnTitle,NSInteger btnIndex))callBack{
    UIAlertController * actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < nameArr.count; i++) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:nameArr[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callBack) {
                callBack(nameArr[i],i);
            }
        }]];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[NSObject obtainTopViewController] presentViewController:actionSheet animated:YES completion:nil];
    return actionSheet;
}
@end
