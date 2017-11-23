//
//  ExtendedFunctionViewController.m
//  WebBrowser
//
//  Created by apple on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ExtendedFunctionViewController.h"
#import "PreferenceHelper.h"
@interface ExtendedFunctionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@end

@implementation ExtendedFunctionViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_extendedOperationKind == ExtendedOperationKindNOIMAGE) {
        self.title = _leftLabel.text = @"无图模式";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyNoImageModeStatus]];
    }else if (_extendedOperationKind == ExtendedOperationKindNOHISTORY){
        self.title = _leftLabel.text = @"无痕模式";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyHistoryModeStatus]];
    }else{
        self.title = _leftLabel.text = @"夜间模式";
        [self.switchButton setOn:[PreferenceHelper boolForKey:KeyEyeProtectiveStatus]];
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
    }else{
        
        [PreferenceHelper setBool:sender.on forKey:KeyEyeProtectiveStatus];
        
        [Notifier postNotificationName:kEyeProtectiveModeChanged object:nil];
        [PreferenceHelper setInteger:1 forKey:KeyEyeProtectiveColorKind];
//        [[UIScreen mainScreen] setBrightness: 0.2];
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
