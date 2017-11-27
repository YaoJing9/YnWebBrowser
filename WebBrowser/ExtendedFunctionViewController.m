//
//  ExtendedFunctionViewController.m
//  WebBrowser
//
//  Created by apple on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ExtendedFunctionViewController.h"
#import "PreferenceHelper.h"
#import "NightView.h"
@interface ExtendedFunctionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@end

@implementation ExtendedFunctionViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_extendedOperationKind == ExtendedOperationKindNOIMAGE) {
        
        [self showNavWithTitle:@"无图模式" backBtnHiden:NO];
        _leftLabel.text = @"无图模式";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyNoImageModeStatus]];
    }else if (_extendedOperationKind == ExtendedOperationKindNOHISTORY){
        [self showNavWithTitle:@"无痕模式" backBtnHiden:NO];
        _leftLabel.text = @"无痕模式";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyHistoryModeStatus]];
    }else if (_extendedOperationKind == ExtendedOperationKindYEJIAN){
        [self showNavWithTitle:@"夜间模式" backBtnHiden:NO];
        _leftLabel.text = @"夜间模式";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyEyeProtectiveStatus]];
        
        if ([PreferenceHelper boolForKey:KeyEyeProtectiveStatus]) {
            [NightView showNightView];
        } else{
            //设置亮度
            [NightView deleNightView];
        }
        
    }else if (_extendedOperationKind == ExtendedOperationKindTOOPENURL){
        [self showNavWithTitle:@"打开上次页面" backBtnHiden:NO];
        _leftLabel.text = @"打开上次页面";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyBlockBaiduADStatus]];
    }else if (_extendedOperationKind == ExtendedOperationKindGUANGGAOGUOLV){
        [self showNavWithTitle:@"广告过滤" backBtnHiden:NO];
        _leftLabel.text = @"广告过滤";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyBlockBaiduADStatus]];
    }else if (_extendedOperationKind == ExtendedOperationKindFULLSCREEN){
        [self showNavWithTitle:@"全屏显示" backBtnHiden:NO];
        _leftLabel.text = @"全屏显示";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyFullScreenModeStatus]];

    }
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)switchAction:(UISwitch *)sender {
    if (_extendedOperationKind == ExtendedOperationKindNOIMAGE) {
        [Notifier postNotification:[NSNotification notificationWithName:kNoImageModeChanged object:nil]];
        [PreferenceHelper setBool:sender.on forKey:KeyNoImageModeStatus];
    }else if (_extendedOperationKind == ExtendedOperationKindNOHISTORY){
        [PreferenceHelper setBool:sender.on forKey:KeyHistoryModeStatus];
    }else if(_extendedOperationKind == ExtendedOperationKindYEJIAN){
        
        [PreferenceHelper setBool:sender.on forKey:KeyEyeProtectiveStatus];
        
        [Notifier postNotificationName:kEyeProtectiveModeChanged object:nil];
        [PreferenceHelper setInteger:1 forKey:KeyEyeProtectiveColorKind];
        if ([PreferenceHelper boolForKey:KeyEyeProtectiveStatus]) {
            [NightView showNightView];
        } else{
            //设置亮度
            [NightView deleNightView];
        }
    }else if (_extendedOperationKind == ExtendedOperationKindTOOPENURL){
        [PreferenceHelper setBool:sender.on forKey:KeyBlockBaiduADStatus];
    }else if(_extendedOperationKind == ExtendedOperationKindGUANGGAOGUOLV){
        [PreferenceHelper setBool:sender.on forKey:KeyBlockBaiduADStatus];
    }else if (_extendedOperationKind == ExtendedOperationKindFULLSCREEN){
        [PreferenceHelper setBool:sender.on forKey:KeyFullScreenModeStatus];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
