//
//  BrowserBottomToolBar.h
//  WebBrowser
//
//  Created by 钟武 on 2016/11/6.
//  Copyright © 2016年 钟武. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "BrowserWebView.h"
#import "BrowserBottomToolBarHeader.h"
typedef void(^CoverBtnBlock)(void);

@interface BrowserBottomToolBar : UIView

@property (nonatomic, weak) id<BrowserBottomToolBarButtonClickedDelegate> browserButtonDelegate;
@property (nonatomic, copy) CoverBtnBlock coverBtnBlock;

@end
