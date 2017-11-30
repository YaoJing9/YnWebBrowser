//
//  BrowserBottomToolBar.m
//  WebBrowser
//
//  Created by 钟武 on 2016/11/6.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserBottomToolBar.h"
#import "TabManager.h"
#import "DelegateManager+WebViewDelegate.h"
#import "BrowserContainerView.h"
#import "NSObject+DXObject.h"
#import "PreferenceHelper.h"
@interface BrowserBottomToolBar () <WebViewDelegate, BrowserWebViewDelegate>

@property (nonatomic, weak) UIBarButtonItem *refreshOrStopItem;
@property (nonatomic, weak) UIButton *backItem;
@property (nonatomic, weak) UIButton *forwardItem;
@property (nonatomic, weak) UIButton *flexibleItem;
@property (nonatomic, weak) UIButton *coverItem;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, weak) BrowserContainerView *containerView;

@end

@implementation BrowserBottomToolBar

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
        [[DelegateManager sharedInstance] registerDelegate:self forKey:DelegateManagerWebView];
        [[DelegateManager sharedInstance] addWebViewDelegate:self];
        [Notifier addObserver:self selector:@selector(handletabSwitch:) name:kWebTabSwitch object:nil];
        [Notifier addObserver:self selector:@selector(updateForwardBackItem) name:kWebHistoryItemChangedNotification object:nil];
        
        //监听多窗口数量[PreferenceHelper integerForKey:KeyBridgeNumber]
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:KeyBridgeNumber options:NSKeyValueObservingOptionNew context:nil];
        
    }
    
    return self;
}

- (void)initializeView{
    self.backgroundColor = [UIColor whiteColor];
    
    UIButton *backItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_BACK_HILIGHT_STRING tag:BottomToolBarBackButtonTag];
    self.backItem = backItem;
    [self.backItem setEnabled:NO];
    self.backItem.frame = CGRectMake(0, 0, self.width/5.0, self.height);
    [self addSubview:self.backItem];
    UIButton *forwardItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_FORWARD_HILIGHT_STRING tag:BottomToolBarForwardButtonTag];
    self.forwardItem = forwardItem;
    [self.forwardItem setEnabled:NO];
    self.forwardItem.frame = CGRectMake(self.width/5.0, 0, self.width/5.0, self.height);
    [self addSubview:self.forwardItem];
    
    UIButton *settingItem = [self createBottomToolBarButtonWithImage:@"菜单" tag:BottomToolBarMoreButtonTag];
    settingItem.frame = CGRectMake(self.width/5.0 * 2, 0, self.width/5.0, self.height);
    [self addSubview:settingItem];

    UIButton *flexibleItem = [self createBottomToolBarButtonWithImage:@"返回不能选中" tag:BottomToolBarFlexibleButtonTag];
    flexibleItem.frame = CGRectMake(self.width/5.0 * 3, 0, self.width/5.0, self.height);
    [self addSubview:flexibleItem];
    self.flexibleItem = flexibleItem;
    
    
    UIButton *multiWindowItem = [self createBottomToolBarButtonWithImage:@"框架" tag:BottomToolBarMultiWindowButtonTag];
    multiWindowItem.frame = CGRectMake(self.width/5.0 * 4, 0, self.width/5.0, self.height);
    [self addSubview:multiWindowItem];
    
    _multiWindowItemLabel = [UILabel new];
    _multiWindowItemLabel.frame = CGRectMake(self.width/5.0 * 4, 0, self.width/5.0, self.height);
    _multiWindowItemLabel.font = [UIFont systemFontOfSize:10];
//    _multiWindowItemLabel.layer.cornerRadius = 3;
//    //    coverItem.layer.maskedCorners = YES;
//    _multiWindowItemLabel.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
//    _multiWindowItemLabel.layer.borderWidth = 0.3;
    _multiWindowItemLabel.textColor = [UIColor blackColor];
    _multiWindowItemLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_multiWindowItemLabel];
    
    UIButton *coverItem = [UIButton new];
    coverItem.frame = CGRectMake(0, 0, self.width/5, self.height);
    coverItem.backgroundColor = [UIColor clearColor];
    [coverItem addTarget:self action:@selector(coverBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.coverItem = coverItem;
    [self addSubview:self.coverItem];
    self.coverItem.hidden = YES;
    [self.coverItem setImage:[UIImage imageNamed:TOOLBAR_BUTTON_BACK_STRING] forState:UIControlStateNormal];

}
-(void)setMultiWindowItemStr:(NSString *)multiWindowItemStr{
    _multiWindowItemLabel.text = multiWindowItemStr;
}
- (void)coverBtnClick{
    if (self.coverBtnBlock) {
        self.coverBtnBlock();
    }
}

- (UIButton *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag{
    UIButton *item = [UIButton new];
    [item setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [item addTarget:self action:@selector(handleBottomToolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    item.tag = tag;
    return item;
}

- (void)handleBottomToolBarButtonClicked:(UIBarButtonItem *)item{
    BottomToolBarButtonTag tag;
    
    if (item.tag == BottomToolBarRefreshOrStopButtonTag)
    {
        tag = self.isRefresh ? BottomToolBarRefreshButtonTag : BottomToolBarStopButtonTag;
        [self setToolBarButtonRefreshOrStop:!_isRefresh];
    }
    else
        tag = item.tag;
    
    if ([self.browserButtonDelegate respondsToSelector:@selector(browserBottomToolBarButtonClickedWithTag:)]) {
        [self.browserButtonDelegate browserBottomToolBarButtonClickedWithTag:tag];
    }
}

- (void)setToolBarButtonRefreshOrStop:(BOOL)isRefresh{
    NSString *imageName = isRefresh ? TOOLBAR_BUTTON_REFRESH_STRING : TOOLBAR_BUTTON_STOP_STRING;
    self.isRefresh = isRefresh;

    self.refreshOrStopItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)updateForwardBackItem{
    if (self.containerView.webView) {
        BOOL backItemEnabled = [self.containerView.webView canGoBack];
        BOOL forwardItemEnabled = [self.containerView.webView canGoForward];
        [self.forwardItem setEnabled:forwardItemEnabled];
        [self.backItem setEnabled:backItemEnabled];

        if (!backItemEnabled) {//返回到最底层webview
            self.coverItem.hidden = NO;
        }else{
            self.coverItem.hidden = YES;
        }
        if (_fromVCComeInKind == 0) {
            self.backItem.hidden = YES;
            [self.backItem setImage:[UIImage imageNamed:TOOLBAR_BUTTON_BACK_HILIGHT_STRING] forState:UIControlStateNormal];
        }else{
            [self.backItem setImage:[UIImage imageNamed:TOOLBAR_BUTTON_BACK_STRING] forState:UIControlStateNormal];
            [self.flexibleItem setImage:[UIImage imageNamed:@"返回首页"] forState:UIControlStateNormal];
        }
        
        [self.forwardItem setImage:[UIImage imageNamed:(forwardItemEnabled ? TOOLBAR_BUTTON_FORWARD_STRING : TOOLBAR_BUTTON_FORWARD_HILIGHT_STRING)] forState:UIControlStateNormal];
    }
}

#pragma mark - BrowserWebViewDelegate

- (void)webViewDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
        [self updateForwardBackItem];
    }
}

- (void)webView:(BrowserWebView *)webView didFailLoadWithError:(NSError *)error{
    if (IsCurrentWebView(webView)) {
        [self updateForwardBackItem];
//        [self setToolBarButtonRefreshOrStop:YES];
    }
}

- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
//        [self setToolBarButtonRefreshOrStop:YES];
    }
}

- (void)webViewForMainFrameDidCommitLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
//        [self setToolBarButtonRefreshOrStop:NO];
    }
}

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (IsCurrentWebView(webView)) {
        [self updateForwardBackItem];
    }
    
    return YES;
}

#pragma mark - kWebTabSwitch notification handler

- (void)handletabSwitch:(NSNotification *)notification{
    BrowserWebView *webView = [notification.userInfo objectForKey:@"webView"];
    if ([webView isKindOfClass:[BrowserWebView class]]) {
        [self updateForwardBackItem];
//        [self setToolBarButtonRefreshOrStop:webView.isMainFrameLoaded];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"webView"] && [object isKindOfClass:[BrowserContainerView class]]) {
        self.containerView = object;
    }else if([keyPath isEqualToString:KeyBridgeNumber]){
        NSString *str = [NSString stringWithFormat:@"%ld",[PreferenceHelper integerForKey:KeyBridgeNumber]];
        if ([str isEqualToString:@"0"]) {
            self.multiWindowItemLabel.text = @"1";
        }else{
            self.multiWindowItemLabel.text = [NSString stringWithFormat:@"%ld",[PreferenceHelper integerForKey:KeyBridgeNumber]];
        }
        
    }
}

#pragma mark - Dealloc

- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:KeyBridgeNumber];
    [Notifier removeObserver:self name:kWebTabSwitch object:nil];
    [Notifier removeObserver:self name:kWebHistoryItemChangedNotification object:nil];
    [[[TabManager sharedInstance] browserContainerView] removeObserver:self forKeyPath:@"webView" context:nil];
}

@end
