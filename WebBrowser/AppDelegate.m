//
//  AppDelegate.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NightView.h"
#import "SaveImageTool.h"
#import "AppDelegate.h"
#import "KeyboardHelper.h"
#import "MenuHelper.h"
#import "FirstBrowserController.h"
#import "WebServer.h"
#import "ErrorPageHelper.h"
#import "SessionRestoreHelper.h"
#import "TabManager.h"
#import "PreferenceHelper.h"
#import "BaseNavigationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BaiduMobAdSDK/BaiduMobAdSplash.h"
#import "BaiduMobAdSDK/BaiduMobAdSetting.h"
static NSString * const UserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1";

@interface AppDelegate ()<BaiduMobAdSplashDelegate>

@property (nonatomic, assign) NSInteger pasteboardChangeCount;
@property (nonatomic, strong) BaiduMobAdSplash *splash;
@property (nonatomic, retain) UIView *customSplashView;
@end

@implementation AppDelegate

- (void)dealloc{
    [Notifier removeObserver:self name:UIPasteboardChangedNotification object:nil];
}

- (void)setAudioPlayInBackgroundMode{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
}

- (void)handlePasteboardNotification:(NSNotification *)notify{
    self.pasteboardChangeCount = [UIPasteboard generalPasteboard].changeCount;
}

- (void)applicationStartPrepare{
    [self setAudioPlayInBackgroundMode];
    [[KeyboardHelper sharedInstance] startObserving];
    [[MenuHelper sharedInstance] setItems];
    
    [Notifier addObserver:self selector:@selector(handlePasteboardNotification:) name:UIPasteboardChangedNotification object:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:32 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    


    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([PreferenceHelper boolForKey:KeyEyeProtectiveStatus]) {
        [NightView showNightView];
    } else{
        
    }
    
    [ErrorPageHelper registerWithServer:[WebServer sharedInstance]];
    [SessionRestoreHelper registerWithServer:[WebServer sharedInstance]];
    
    [[WebServer sharedInstance] start];
    
    //解决UIWebView首次加载页面时间过长问题,设置UserAgent减少跳转和判断
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : UserAgent}];
    
    
    WebModel *webModel = [WebModel new];
    webModel.title = DEFAULT_CARD_CELL_TITLE;
    webModel.url = DEFAULT_CARD_CELL_URL;
    webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
    webModel.isNewWebView = YES;   //load archive data ahead
    [TabManager sharedInstance];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self applicationStartPrepare];
    });
    
    
    [self locationQuester];
    
    //激活接口
    [self requestActivation];
    //系统配置
    [self requestSystem];
    
    UIViewController *browserViewController = [UIViewController new];
    browserViewController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = browserViewController;
    
    return YES;
}

- (void)baidugg{
    [BaiduMobAdSetting sharedInstance].supportHttps = YES;

    //    设置视频缓存阀值，单位M, 取值范围15M-100M,默认30M
    [BaiduMobAdSetting setMaxVideoCacheCapacityMb:30];

    //    自定义开屏
    //
    BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;
    splash.AdUnitTag = @"2058492";
    splash.canSplashClick = YES;
    self.splash = splash;

    //可以在customSplashView上显示包含icon的自定义开屏
    self.customSplashView = [[UIView alloc]initWithFrame:self.window.frame];
    self.customSplashView.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:self.customSplashView];

    CGFloat screenWidth = self.window.frame.size.width;
    CGFloat screenHeight = self.window.frame.size.height;

    //在baiduSplashContainer用做上展现百度广告的容器，注意尺寸必须大于200*200，并且baiduSplashContainer需要全部在window内，同时开机画面不建议旋转
    UIView * baiduSplashContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 40)];
    [self.customSplashView addSubview:baiduSplashContainer];

    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight - 40, screenWidth, 20)];
    label.text = @"浏览器";
    label.textAlignment = NSTextAlignmentCenter;
    [self.customSplashView addSubview:label];
    //
    //在的baiduSplashContainer里展现百度广告
    [splash loadAndDisplayUsingContainerView:baiduSplashContainer];
}

- (NSString *)publisherId {
    return @"ccb60059";
}


- (void)getFontNames
{
    NSArray *familyNames = [UIFont familyNames];
    
    for (NSString *familyName in familyNames) {
        printf("familyNames = %s\n",[familyName UTF8String]);
        
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        
        for (NSString *fontName in fontNames) {
            printf("\tfontName = %s\n",[fontName UTF8String]);
        }
    }
}


- (void)locationQuester{
    
    if(![CLLocationManager locationServicesEnabled]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位服务未打开" preferredStyle:UIAlertControllerStyleAlert];
        //创建按钮
        //handler:点击按钮执行的事件
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        return;
    }
}

- (void)requestActivation{

    NSString *tempURLStr = [NSString stringWithFormat:@"%@ddz/activation", YNBaseURL];
    
    NSMutableDictionary *parameters = [CMNetworkingTool getPostDict];
    
    [[CMNetworkingTool sharedNetworkingTool] requestWithMethod:NetworkingMethodTypeGet urlString:tempURLStr parameters:parameters success:^(NSURLSessionDataTask *dataTask, id responseObject) {
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        NSLog(@"%@", [YJHelp codeWithError:error]);
    }];
}
- (void)requestSystem{
    
    NSString *tempURLStr = [NSString stringWithFormat:@"%@/ddz/systemconfig", YNBaseURL];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    NSString *version = [CMNetworkingTool appVersion];
    NSString *package = [CMNetworkingTool appBundleId];

    [parameters setObject:version forKey:@"version"];
    [parameters setObject:package forKey:@"package"];

    [[CMNetworkingTool sharedNetworkingTool] requestWithMethod:NetworkingMethodTypeGet urlString:tempURLStr parameters:parameters success:^(NSURLSessionDataTask *dataTask, id responseObject) {
        FirstBrowserController *browserViewController = [FirstBrowserController new];
        BaseNavigationViewController *navigationController = [[BaseNavigationViewController alloc] initWithRootViewController:browserViewController];
        self.window.rootViewController = navigationController;
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [YnSimpleInterest shareSimpleInterest].isApprove = [[YJHelp codeWithError:error][@"isApprove"] boolValue];
        NSLog(@"%@", [YJHelp codeWithError:error]);
        FirstBrowserController *browserViewController = [FirstBrowserController new];
        BaseNavigationViewController *navigationController = [[BaseNavigationViewController alloc] initWithRootViewController:browserViewController];
        self.window.rootViewController = navigationController;
        
        [self baidugg];

//        if ([YnSimpleInterest shareSimpleInterest].isApprove) {
//            [NewSystemView showInsertionView:^{
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[YJHelp codeWithError:error][@"shareUrl"]]];
//
//            }];
//
//        }
        
    }];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidClicked");
}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissLp");
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"splashDidDismissScreen");
    [self removeSplash];
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"splashSuccessPresentScreen");
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSLog(@"splashlFailPresentScreen withError %d", reason);
    [self removeSplash];
}

/**
 *  展示结束or展示失败后, 手动移除splash和delegate
 */
- (void) removeSplash {
    if (self.splash) {
        self.splash.delegate = nil;
        self.splash = nil;
        [self.customSplashView removeFromSuperview];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (self.pasteboardChangeCount != pasteboard.changeCount) {
        self.pasteboardChangeCount = pasteboard.changeCount;
        NSURL *url = pasteboard.URL;
        if (url && ![[PreferenceHelper URLForKey:KeyPasteboardURL] isEqual:url]) {
            [PreferenceHelper setURL:url forKey:KeyPasteboardURL];
//            [self presentPasteboardChangedAlertWithURL:url];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Enable UIWebView video landscape
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    static NSString *kAVFullScreenViewControllerStr = @"AVFullScreenViewController";
    UIViewController *presentedViewController = [window.rootViewController presentedViewController];

    if (presentedViewController && [presentedViewController isKindOfClass:NSClassFromString(kAVFullScreenViewControllerStr)] && [presentedViewController isBeingDismissed] == NO) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Preseving and Restoring State

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    return YES;
}

@end

