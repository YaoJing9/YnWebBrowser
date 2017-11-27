//
//  BrowserViewController.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "PreferenceHelper.h"
#import "WebViewHistoryItem.h"
#import "TabManager.h"
#import "BrowserViewController.h"
#import "BrowserContainerView.h"
#import "BrowserTopToolBar.h"
#import "BrowserHeader.h"
#import "BrowserBottomToolBar.h"
#import "CardMainView.h"
#import "SettingsTableViewController.h"
#import "HistoryTableViewController.h"
#import "DelegateManager+WebViewDelegate.h"
#import "BookmarkTableViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkItemEditViewController.h"
#import "FindInPageBar.h"
#import "KeyboardHelper.h"
#import "NSURL+ZWUtility.h"
#import "ExtentionsTableViewController.h"
#import "MoreSettingView.h"
#import "HistoryAndBookmarkListViewController.h"
#import "ExtendedFunctionViewController.h"

static NSString *const kBrowserViewControllerAddBookmarkSuccess = @"添加书签成功";
static NSString *const kBrowserViewControllerAddBookmarkFailure = @"添加书签失败";

@interface BrowserViewController () <BrowserBottomToolBarButtonClickedDelegate,  UIViewControllerRestoration, KeyboardHelperDelegate>


@property (nonatomic, strong) BrowserBottomToolBar *bottomToolBar;
@property (nonatomic, strong) BrowserTopToolBar *browserTopToolBar;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) BOOL isWebViewDecelerate;
@property (nonatomic, assign) ScrollDirection webViewScrollDirection;
@property (nonatomic, weak) id<BrowserBottomToolBarButtonClickedDelegate> browserButtonDelegate;
@property (nonatomic, strong) FindInPageBar *findInPageBar;
@property (nonatomic, weak) NSLayoutConstraint *findInPageBarbottomLayoutConstaint;

@end

@implementation BrowserViewController

SYNTHESIZE_SINGLETON_FOR_CLASS(BrowserViewController)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeView];
    
    [self initializeNotification];

    self.lastContentOffset = - TOP_TOOL_BAR_HEIGHT;
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerWebView, DelegateManagerFindInPageBarDelegate]];
    
    [[KeyboardHelper sharedInstance] addDelegate:self];
    
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MoreSettingView removeMoreSettingView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.browserContainerView == nil) {
        self.browserContainerView = ({
            BrowserContainerView *browserContainerView = [[BrowserContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
            browserContainerView.url = self.url;
            [self.view addSubview:browserContainerView];
            
            self.browserButtonDelegate = browserContainerView;
            
            browserContainerView;
        });
        [self.view sendSubviewToBack:self.browserContainerView];
    }
}
- (void)initializeView{
    self.view.backgroundColor = UIColorFromRGB(0xF8F8F8);
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    self.browserContainerView = ({
        BrowserContainerView *browserContainerView = [[BrowserContainerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        browserContainerView.url = self.url;
        [self.view addSubview:browserContainerView];
        
        self.browserButtonDelegate = browserContainerView;

        browserContainerView;
    });
    
    self.browserTopToolBar = ({
        BrowserTopToolBar *browserTopToolBar = [[BrowserTopToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TOP_TOOL_BAR_HEIGHT)];
        [self.view addSubview:browserTopToolBar];
        
        browserTopToolBar.backgroundColor = UIColorFromRGB(0xF8F8F8);
        
        browserTopToolBar;
    });
    
    self.bottomToolBar = ({
        BrowserBottomToolBar *toolBar = [[BrowserBottomToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOL_BAR_HEIGHT, self.view.width, BOTTOM_TOOL_BAR_HEIGHT)];
        toolBar.fromVCComeInKind = 1;
        [self.view addSubview:toolBar];
        
        toolBar.browserButtonDelegate = self;
        
        [self.browserContainerView addObserver:toolBar forKeyPath:@"webView" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
        toolBar;
    });
    WS(weakSelf);
    self.bottomToolBar.coverBtnBlock = ^{
        if (weakSelf.fromVCComeInKind == FromVCComeInKindSEARCH) {
            [weakSelf dismissViewControllerAnimated:NO completion:^{
                
            }];
        }else{
            [weakSelf.navigationController popViewControllerAnimated:NO];
        }
    };
}

#pragma mark - Notification

- (void)initializeNotification{
    [Notifier addObserver:self selector:@selector(recoverToolBar) name:kExpandHomeToolBarNotification object:nil];
    [Notifier addObserver:self selector:@selector(recoverToolBar) name:kWebTabSwitch object:nil];
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (![PreferenceHelper boolForKey:KeyFullScreenModeStatus]) {
        return;
    }
    //点击新链接或返回时，scrollView会调用该方法
    if (!(!scrollView.decelerating && !scrollView.dragging && !scrollView.tracking)) {
        CGFloat yOffset = scrollView.contentOffset.y - self.lastContentOffset;
        
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if (_isWebViewDecelerate || (scrollView.contentOffset.y >= -TOP_TOOL_BAR_HEIGHT && scrollView.contentOffset.y <= 0)) {
                //浮点数不能做精确匹配，不过此处用等于满足我的需求
                if (!(self.browserTopToolBar.height == TOP_TOOL_BAR_HEIGHT)) {
                    [self recoverToolBar];
                }
            }
            self.webViewScrollDirection = ScrollDirectionDown;
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y >= - TOP_TOOL_BAR_HEIGHT)
        {
            if (!(scrollView.contentOffset.y < 0 && scrollView.decelerating)) {
                [self handleToolBarWithOffset:yOffset];
            }
            self.webViewScrollDirection = ScrollDirectionUp;
        }
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
    
}

- (void)recoverToolBar{
    [UIView animateWithDuration:.2 animations:^{
        self.browserTopToolBar.height = TOP_TOOL_BAR_HEIGHT;
        CGRect bottomRect = self.bottomToolBar.frame;
        bottomRect.origin.y = self.view.height - BOTTOM_TOOL_BAR_HEIGHT;
        self.bottomToolBar.frame = bottomRect;
        self.browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, BOTTOM_TOOL_BAR_HEIGHT, 0);
    }];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.webViewScrollDirection == ScrollDirectionDown) {
        self.isWebViewDecelerate = decelerate;
    }
    else
        self.isWebViewDecelerate = NO;
}

#pragma mark - Handle TopToolBar Scroll
- (void)handleToolBarWithOffset:(CGFloat)offset{
    
    CGRect bottomRect = self.bottomToolBar.frame;
    //缩小toolbar
    if (offset > 0) {
        if (self.browserTopToolBar.height - offset <= TOP_TOOL_BAR_THRESHOLD) {
            self.browserTopToolBar.height = TOP_TOOL_BAR_THRESHOLD;
            self.browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_THRESHOLD, 0, 0, 0);

            bottomRect.origin.y = self.view.height;
        }
        else
        {
            self.browserTopToolBar.height -= offset;
            CGFloat bottomRectYoffset = BOTTOM_TOOL_BAR_HEIGHT * offset / (TOP_TOOL_BAR_HEIGHT - TOP_TOOL_BAR_THRESHOLD);
            bottomRect.origin.y += bottomRectYoffset;
            UIEdgeInsets insets = self.browserContainerView.scrollView.contentInset;
            insets.top -= offset;
            insets.bottom -= bottomRectYoffset;
            self.browserContainerView.scrollView.contentInset = insets;
        }
    }
    else{
        if (self.browserTopToolBar.height + (-offset) >= TOP_TOOL_BAR_HEIGHT) {
            self.browserTopToolBar.height = TOP_TOOL_BAR_HEIGHT;
            bottomRect.origin.y = self.view.height - BOTTOM_TOOL_BAR_HEIGHT;
            self.browserContainerView.scrollView.contentInset = UIEdgeInsetsMake(TOP_TOOL_BAR_HEIGHT, 0, BOTTOM_TOOL_BAR_HEIGHT, 0);
        }
        else
        {
            self.browserTopToolBar.height += (-offset);
            CGFloat bottomRectYoffset = BOTTOM_TOOL_BAR_HEIGHT * (-offset) / (TOP_TOOL_BAR_HEIGHT - TOP_TOOL_BAR_THRESHOLD);
            bottomRect.origin.y -= bottomRectYoffset;
            UIEdgeInsets insets = self.browserContainerView.scrollView.contentInset;
            insets.top += (-offset);
            insets.bottom += bottomRectYoffset;
            self.browserContainerView.scrollView.contentInset = insets;
        }
    }
    
    self.bottomToolBar.frame = bottomRect;
}

#pragma mark - BrowserBottomToolBarButtonClickedDelegate

- (void)browserBottomToolBarButtonClickedWithTag:(BottomToolBarButtonTag)tag{
    
    WS(weakSelf);

    if ([self.browserButtonDelegate respondsToSelector:@selector(browserBottomToolBarButtonClickedWithTag:)]) {
        [self.browserButtonDelegate browserBottomToolBarButtonClickedWithTag:tag];
    }

    if (tag == BottomToolBarMoreButtonTag) {
        [MoreSettingView showInsertionViewSuccessBlock:^{
            
        } clickBlock:^{
            
        } removeBlock:^{
            
        } btnClickBlock:^(NSInteger index) {
            [weakSelf moreSettingClick:index];
        }];
    }
    
//    if (tag == BottomToolBarBackButtonTag) {
//        if (_fromVCComeInKind == FromVCComeInKindSEARCH) {
//            WebViewBackForwardList *listModel = self.browserContainerView.webView.webViewBackForwardList;
//            WebViewHistoryItem *itemModel = [listModel.backList lastObject];
////            NSString *urlStr = self.browserContainerView
//            if ( [urlStr isEqualToString:@"about:blank"] ) {
//                if (![self.browserContainerView.webView canGoBack]) {
//
//                    [self dismissViewControllerAnimated:NO completion:^{
//
//                    }];
//                }
//            }else{
//                if (![self.browserContainerView.webView canGoBack]) {
//                    [self.navigationController popViewControllerAnimated:YES];
//                }
//
//            }
//            }
//
//    }
    
    if (tag == BottomToolBarFlexibleButtonTag ) {
        
        if (_fromVCComeInKind == FromVCComeInKindSEARCH) {
            [self dismissViewControllerAnimated:NO completion:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    if (tag == BottomToolBarMultiWindowButtonTag) {
        CardMainView *cardMainView = [[CardMainView alloc] initWithFrame:self.view.bounds];
        [cardMainView reloadCardMainViewWithCompletionBlock:^(WebModel *model){
            UIImage *image = [self.view snapshot];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = cardMainView.bounds;
            [cardMainView addSubview:imageView];
            [self.view addSubview:cardMainView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.navigationController popViewControllerAnimated:YES];
                [imageView removeFromSuperview];
                [cardMainView changeCollectionViewLayout];
            });
        }];
    }
}


- (void)moreSettingClick:(NSInteger)index{
    
    SettingsTableViewController *settingVc = [[SettingsTableViewController alloc] init];
    HistoryAndBookmarkListViewController *historyAndBookmarkVc = [[HistoryAndBookmarkListViewController alloc] init];
    ExtendedFunctionViewController *extendedFVC = [[ExtendedFunctionViewController alloc] init];
    switch (index) {
        case 0:
            extendedFVC.extendedOperationKind = ExtendedOperationKindFULLSCREEN;
            [self.navigationController pushViewController: extendedFVC animated:NO];
            break;
        case 1:
            extendedFVC.extendedOperationKind = ExtendedOperationKindYEJIAN;
            [self.navigationController pushViewController: extendedFVC animated:NO];
            break;
        case 2:
            extendedFVC.extendedOperationKind = ExtendedOperationKindNOIMAGE;
            [self.navigationController pushViewController: extendedFVC animated:NO];
            break;
        case 3:
            extendedFVC.extendedOperationKind = ExtendedOperationKindNOHISTORY;
            [self.navigationController pushViewController: extendedFVC animated:NO];
            break;
        case 4:
            
            break;
        case 5:
            
            historyAndBookmarkVc.listDataOperationKind = ListDataOperationKindBookmark;
            historyAndBookmarkVc.fromVCComeInKind = FromVCComeInKindWEBVIEW;
            [self.navigationController pushViewController: historyAndBookmarkVc animated:NO];
            break;
        case 6:
            [self addBookmark];
            break;
        case 7:
            
            break;
        case 8:
            [self.navigationController pushViewController: settingVc animated:NO];
            break;
            
        default:
        {
            NSURL *url = self.browserContainerView.webView.request.URL;
            if ([url isErrorPageURL]) {
                NSURL *url = [self.browserContainerView.webView.request.URL originalURLFromErrorURL];
                [self.browserContainerView startLoadWithWebView:self.browserContainerView.webView url:url];
            }
            else if (!url || [url.absoluteString isEqualToString:@""]){
                WebModel *webModel = [[TabManager sharedInstance] getCurrentWebModel];
                url = [NSURL URLWithString:webModel.url];
                [self.browserContainerView startLoadWithWebView:self.browserContainerView.webView url:url];
            }
            else{
                [self.browserContainerView.webView reload];
            }
            [MoreSettingView removeMoreSettingView];
            break;
        }
            break;
    }
}
- (void)pushTableViewControllerWithControllerName:(Class)class style:(UITableViewStyle)style{
    if (![class isSubclassOfClass:[UITableViewController class]]) {
        return;
    }
    UITableViewController *vc = [[class alloc] initWithStyle:style];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)handleCopyURLButtonClicked{
    NSURL *url = [NSURL URLWithString:self.browserContainerView.webView.mainFURL];
    BOOL success = NO;
    
    if (url) {
        if ([url isErrorPageURL]) {
            url = [url originalURLFromErrorURL];
        }
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.URL = url;
        success = YES;
    }

    [self.view showHUDWithMessage:success ? @"拷贝成功" : @"拷贝失败"];
}

- (void)addBookmark{
    BrowserWebView *webView = self.browserContainerView.webView;
    NSString *title = webView.mainFTitle;
    NSString *url = webView.mainFURL;
    
    if (title.length == 0 || url.length == 0) {
        [self.view showHUDWithMessage:kBrowserViewControllerAddBookmarkFailure];
        return;
    }
    
    BookmarkDataManager *dataManager = [[BookmarkDataManager alloc] init];
    
    BookmarkItemEditViewController *editVC = [[BookmarkItemEditViewController alloc] initWithDataManager:dataManager item:[BookmarkItemModel bookmarkItemWithTitle:title url:url] sectionIndex:[NSIndexPath indexPathForRow:0 inSection:0] operationKind:BookmarkItemOperationKindItemAdd completion:nil];
    
    [self.navigationController pushViewController: editVC animated:NO];
    
}

#pragma mark - Preseving and Restoring State

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    BrowserViewController *controller = BrowserVC;
    return controller;
}

#pragma mark - FindInPageBarDelegate

- (void)findInPage:(FindInPageBar *)findInPage didFindPreviousWithText:(NSString *)text{
    [self.findInPageBar endEditing:YES];
}

- (void)findInPage:(FindInPageBar *)findInPage didFindNextWithText:(NSString *)text{
    [self.findInPageBar endEditing:YES];
}

- (void)findInPageDidPressClose:(FindInPageBar *)findInPage{
    [self updateFindInPageVisibility:NO];
}

- (void)updateFindInPageVisibility:(BOOL)visible{
    if (visible) {
        if (!self.findInPageBar) {
            FindInPageBar *findInPageBar = [FindInPageBar new];
            findInPageBar.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:findInPageBar];
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[findInPageBar]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(findInPageBar)]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[findInPageBar(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(findInPageBar)]];
            NSLayoutConstraint *bottomConstaint = [NSLayoutConstraint constraintWithItem:findInPageBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_bottomToolBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
            [self.view addConstraint:bottomConstaint];
            self.findInPageBarbottomLayoutConstaint = bottomConstaint;
            
            self.findInPageBar = findInPageBar;
        }
    }
    else if (self.findInPageBar){
        [self.findInPageBar endEditing:YES];
        [self.findInPageBar removeFromSuperview];
        self.findInPageBar = nil;
    }
}

#pragma mark - FindInPageUpdateDelegate

- (void)findInPageDidUpdateCurrentResult:(NSInteger)currentResult{
    self.findInPageBar.currentResult = currentResult;
}

- (void)findInPageDidUpdateTotalResults:(NSInteger)totalResults{
    self.findInPageBar.totalResults = totalResults;
}

- (void)findInPageDidSelectForSelection:(NSString *)selection{
    [self updateFindInPageVisibility:YES];
    self.findInPageBar.text = selection;
}

#pragma mark - KeyboardHelperDelegate

- (void)keyboardHelper:(KeyboardHelper *)keyboardHelper keyboardWillShowWithState:(KeyboardState *)state{
    [self changeSearchInputViewPoint:state isShow:YES];
}

- (void)keyboardHelper:(KeyboardHelper *)keyboardHelper keyboardWillHideWithState:(KeyboardState *)state{
    [self changeSearchInputViewPoint:state isShow:NO];
}

- (void)changeSearchInputViewPoint:(KeyboardState *)state isShow:(BOOL)isShow{
    if (!(self.navigationController.topViewController == self && !self.presentedViewController && self.findInPageBar)) {
        return;
    }
    
    CGFloat keyBoardEndY = self.view.height - [state intersectionHeightForView:self.view];
    
    // 添加移动动画，使视图跟随键盘移动
    [UIView animateWithDuration:state.animationDuration animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:state.animationCurve];
        [self.findInPageBarbottomLayoutConstaint setActive:NO];
        if (isShow) {
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.findInPageBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:keyBoardEndY];
            self.findInPageBarbottomLayoutConstaint = bottomConstraint;
            [self.view addConstraint:bottomConstraint];
        }
        else{
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.findInPageBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomToolBar attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
            self.findInPageBarbottomLayoutConstaint = bottomConstraint;
            [self.view addConstraint:bottomConstraint];
        }
    }];
}


#pragma mark - Dealloc Method

- (void)dealloc{
    [Notifier removeObserver:self];
}

@end
