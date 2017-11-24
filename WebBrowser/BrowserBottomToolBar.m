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

@interface BrowserBottomToolBar () <WebViewDelegate, BrowserWebViewDelegate>

@property (nonatomic, weak) UIBarButtonItem *refreshOrStopItem;
@property (nonatomic, weak) UIBarButtonItem *backItem;
@property (nonatomic, weak) UIBarButtonItem *forwardItem;
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
    }
    
    return self;
}

- (void)initializeView{
    self.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_BACK_HILIGHT_STRING tag:BottomToolBarBackButtonTag];
    self.backItem = backItem;
    [self.backItem setEnabled:NO];

    UIBarButtonItem *forwardItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_FORWARD_HILIGHT_STRING tag:BottomToolBarForwardButtonTag];
    self.forwardItem = forwardItem;
    [self.forwardItem setEnabled:NO];
    
    UIBarButtonItem *refreshOrStopItem = [self createBottomToolBarButtonWithImage:TOOLBAR_BUTTON_STOP_STRING tag:BottomToolBarRefreshOrStopButtonTag];
    self.isRefresh = NO;
    self.refreshOrStopItem = refreshOrStopItem;
    
    UIBarButtonItem *settingItem = [self createBottomToolBarButtonWithImage:@"菜单" tag:BottomToolBarMoreButtonTag];

    UIBarButtonItem *flexibleItem = [self createBottomToolBarButtonWithImage:@"返回首页" tag:BottomToolBarFlexibleButtonTag];

    
    UIBarButtonItem *multiWindowItem = [self createBottomToolBarButtonWithImage:@"框架" tag:BottomToolBarMultiWindowButtonTag];
    

    
    [self setItems:@[backItem, forwardItem, settingItem,flexibleItem, multiWindowItem] animated:NO];
    
    
    UIButton *coverItem = [UIButton new];
    coverItem.frame = CGRectMake(0, 0, self.width/5, self.height);
    [coverItem addTarget:self action:@selector(coverBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.coverItem = coverItem;
    [self addSubview:self.coverItem];
    self.coverItem.hidden = YES;
}

- (void)coverBtnClick{
    if (self.coverBtnBlock) {
        self.coverBtnBlock();
    }
}

- (UIBarButtonItem *)createBottomToolBarButtonWithImage:(NSString *)imageName tag:(NSInteger)tag{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(handleBottomToolBarButtonClicked:)];
    item.tag = tag;
    item.width = self.width / 5.0f;
    return item;
}



- (void)handleBottomToolBarButtonClicked:(UIBarButtonItem *)item{
    BottomToolBarButtonTag tag;
    
    if (item.tag == BottomToolBarRefreshOrStopButtonTag){
        tag = self.isRefresh ? BottomToolBarRefreshButtonTag : BottomToolBarStopButtonTag;
        [self setToolBarButtonRefreshOrStop:!_isRefresh];
    }else if (item.tag == BottomToolBarFlexibleButtonTag){
        [self coverBtnClick];
    }else{
        tag = item.tag;

    }
    
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
        [self.backItem setEnabled:backItemEnabled];
        [self.forwardItem setEnabled:forwardItemEnabled];
        
        if (!backItemEnabled) {//返回到最底层webview
            self.coverItem.hidden = NO;
        }else{
            self.coverItem.hidden = YES;
        }
        
        [self.backItem setImage:[[UIImage imageNamed:(backItemEnabled ?TOOLBAR_BUTTON_BACK_STRING : TOOLBAR_BUTTON_BACK_HILIGHT_STRING)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.forwardItem setImage:[[UIImage imageNamed:(forwardItemEnabled ? TOOLBAR_BUTTON_FORWARD_STRING : TOOLBAR_BUTTON_FORWARD_HILIGHT_STRING)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
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
        [self setToolBarButtonRefreshOrStop:YES];
    }
}

- (void)webViewForMainFrameDidFinishLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
        [self setToolBarButtonRefreshOrStop:YES];
    }
}

- (void)webViewForMainFrameDidCommitLoad:(BrowserWebView *)webView{
    if (IsCurrentWebView(webView)) {
        [self setToolBarButtonRefreshOrStop:NO];
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
        [self setToolBarButtonRefreshOrStop:webView.isMainFrameLoaded];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"webView"] && [object isKindOfClass:[BrowserContainerView class]]) {
        self.containerView = object;
    }
}

#pragma mark - Dealloc

- (void)dealloc{
    [Notifier removeObserver:self name:kWebTabSwitch object:nil];
    [Notifier removeObserver:self name:kWebHistoryItemChangedNotification object:nil];
    [[[TabManager sharedInstance] browserContainerView] removeObserver:self forKeyPath:@"webView" context:nil];
}

@end
