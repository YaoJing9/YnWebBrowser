//
//  MoreSettingView.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^RemoveBlock)(void);
typedef void(^ClickBlock)(void);
typedef void(^InsertionSuccessBlock)(void);
@interface MoreSettingView : UIView
@property (nonatomic,copy) RemoveBlock removeBlock;//移除insertion广告
@property (nonatomic,copy) ClickBlock clickBlock;//点击insertion广告
@property (nonatomic,copy) InsertionSuccessBlock successBlock;//加载insertion广告成功
+ (void)showInsertionViewSuccessBlock:(InsertionSuccessBlock)successBlock clickBlock:(ClickBlock)clickBlock removeBlock:(RemoveBlock)removeBlock;

@end
