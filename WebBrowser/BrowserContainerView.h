//
//  BrwoserContentView.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/9.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserWebView.h"
#import "BrowserBottomToolBarHeader.h"

typedef void(^TabCompletion)(WebModel *webModel, BrowserWebView *browserWebView);

@interface BrowserContainerView : UIView <BrowserBottomToolBarButtonClickedDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly, weak) BrowserWebView *webView;
@property (nonatomic, strong) NSString *url;
- (void)restoreWithCompletionHandler:(TabCompletion)completion animation:(BOOL)animation;
- (void)startLoadWithWebView:(BrowserWebView *)webView url:(NSURL *)url;
@end
