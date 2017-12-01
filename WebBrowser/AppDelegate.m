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

#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import <UserNotifications/UserNotifications.h>


static NSString * const UserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1";

@interface AppDelegate ()<BaiduMobAdSplashDelegate, JPUSHRegisterDelegate>

@property (nonatomic, assign) NSInteger pasteboardChangeCount;
@property (nonatomic, strong) BaiduMobAdSplash *splash;
@property (nonatomic, strong) UIView *customSplashView;
@property (nonatomic, strong) UIImageView *label;

@property (nonatomic, strong) UIView *appCustomSplashView;
@property (nonatomic, strong) UIImageView *appLabel;
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

    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
//    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
//                                                         diskCapacity:32 * 1024 * 1024
//                                                             diskPath:nil];
//    [NSURLCache setSharedURLCache:URLCache];
    
    
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
//    
//    NSURLCache * cache = [NSURLCache sharedURLCache];
//    
//    [cache removeAllCachedResponses];
//    
//    [cache setDiskCapacity:0];
//    
//    [cache setMemoryCapacity:0];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    FirstBrowserController *browserViewController = [FirstBrowserController new];
    BaseNavigationViewController *navigationController = [[BaseNavigationViewController alloc] initWithRootViewController:browserViewController];
    self.window.rootViewController = navigationController;
    
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
    
    //系统配置
    [self requestSystem];
    
    [self applicationStartPrepare];
    
    [self locationQuester];
    
    //激活接口
    [self requestActivation];
    
    if ([PreferenceHelper boolForKey:KeyApproveStatus]) {
        [self baidugg];
    }else{
        
    }
    
    [self registJpush:launchOptions];
    
    return YES;
}

- (void)baidugg{
    [BaiduMobAdSetting sharedInstance].supportHttps = YES;

    //    设置视频缓存阀值，单位M, 取值范围15M-100M,默认30M
//    [BaiduMobAdSetting setMaxVideoCacheCapacityMb:30];

    //    自定义开屏
    //
    BaiduMobAdSplash *splash = [[BaiduMobAdSplash alloc] init];
    splash.delegate = self;
    splash.AdUnitTag = @"5347710";
    splash.canSplashClick = YES;
    self.splash = splash;

    //可以在customSplashView上显示包含icon的自定义开屏
    self.customSplashView = [[UIView alloc] initWithFrame:self.window.frame];
    self.customSplashView.backgroundColor = [UIColor whiteColor];
    [self.window addSubview:self.customSplashView];

    UIImageView *label = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - 126, SCREENWIDTH, 126)];
    label.image = [UIImage imageNamed:@"全屏启动广告"];
    label.hidden = NO;
    [self.customSplashView addSubview:label];
    self.label = label;
//   在baiduSplashContainer用做上展现百度广告的容器，注意尺寸必须大于200*200，并且baiduSplashContainer需要全部在window内，同时开机画面不建议旋转
    UIView * baiduSplashContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 126)];
    [self.customSplashView addSubview:baiduSplashContainer];
    //在的baiduSplashContainer里展现百度广告
    [splash loadAndDisplayUsingContainerView:baiduSplashContainer];
}

- (NSString *)publisherId {
    return @"ea041065";
}

- (void)locationQuester{
    
    if(![CLLocationManager locationServicesEnabled]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位服务未打开" preferredStyle:UIAlertControllerStyleAlert];
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

    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        NSLog(@"%@", [YJHelp codeWithError:error]);

        if ([[YJHelp codeWithError:error][@"isApprove"] boolValue] && ![PreferenceHelper boolForKey:KeyApproveStatus]) {
            [PreferenceHelper setBool:[[YJHelp codeWithError:error][@"isApprove"] boolValue] forKey:KeyApproveStatus];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"llqAppisApprove" object:nil];
        }

        if ([[YJHelp codeWithError:error][@"bUpdate"] boolValue]) {
            [NewSystemView showInsertionViewtitle:[YJHelp codeWithError:error][@"updateDes"] clickBlock:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[YJHelp codeWithError:error][@"updateUrl"]]];
            }];
        }
        
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self removeSplash];
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    self.label.hidden = NO;
    NSLog(@"splashSuccessPresentScreen");
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSLog(@"splashlFailPresentScreen withError %d", reason);
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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

- (void)registJpush:(NSDictionary *)launchOptions{
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
        }
    }];
}


//极光推送
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
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


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //清空icon数目
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService setBadge:0];
}
@end

