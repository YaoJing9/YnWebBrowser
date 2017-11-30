//
//  MacroUIConstants.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#ifndef MacroConstants_h
#define MacroConstants_h

#define STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

#define BOTTOM_TOOL_BAR_HEIGHT 44
#define TOP_TOOL_BAR_HEIGHT 70
#define TOP_TOOL_BAR_THRESHOLD 45

#define Card_Cell_Close_Width 22
#define Card_Cell_Close_Height 22

#define TEXT_FIELD_PLACEHOLDER   @"搜索或输入网址"

#define BAIDU_SEARCH_URL @"http://wap.sogou.com/web/sl?keyword=%@&bid=sogou-mobb-6e3adb1ae0e02c93"

#define DEFAULT_IMAGE @"default"
#define DEFAULT_CARD_CELL_IMAGE @"baidu"
//#define DEFAULT_CARD_CELL_URL   @"about:homepage"
#define DEFAULT_CARD_CELL_URL   @"http://wap.sogou.com"
#define DEFAULT_CARD_CELL_TITLE @"搜狗搜索"

#pragma mark - Notification
// 无图模式
#define kNoImageModeChanged         @"kNoImageModeChanged"
// 护眼模式
#define kEyeProtectiveModeChanged   @"kEyeProtectiveModeChanged"

// tab Number
#define kWebTabNumber               @"kWebTabNumber"

// tab switch
#define kWebTabSwitch               @"kWebTabSwitch"
// webView navigation change
#define kWebHistoryItemChangedNotification @"WebHistoryItemChangedNotification"
// expand toolbar
#define kExpandHomeToolBarNotification @"kExpandHomeToolBarNotification"
// open in new window
#define kOpenInNewWindowNotification @"kOpenInNewWindowNotification"

#endif /* MacroConstants_h */
