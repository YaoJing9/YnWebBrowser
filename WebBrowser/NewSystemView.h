//
//  NewSystemView.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBlock)(void);
@interface NewSystemView : UIView
@property (nonatomic,copy) ClickBlock clickBlock;

+ (void)showInsertionViewtitle:(NSString *)title clickBlock:(ClickBlock)ClickBlock;
+ (void)removeMoreSettingView;

@end
