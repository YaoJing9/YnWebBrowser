//
//  BrowserTopToolBar.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/12.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserWebView.h"
#import "NJKWebViewProgress.h"
#import "TopToolBarShapeView.h"
@interface BrowserTopToolBar : UIView <WebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, strong) TopToolBarShapeView *shapeView;

- (void)setTopURLOrTitle:(NSString *)urlOrTitle;

@end
