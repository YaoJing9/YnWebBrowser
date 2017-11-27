//
//  NightView.h
//  WebBrowser
//
//  Created by apple on 2017/11/27.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NightView : UIView

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(NightView)
+(instancetype)showNightView;
+(void)deleNightView;
@end
