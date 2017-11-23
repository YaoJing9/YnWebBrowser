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
typedef void(^BtnClickBlock)(NSInteger);
@interface MoreSettingView : UIView
@property (nonatomic,copy) RemoveBlock removeBlock;
@property (nonatomic,copy) ClickBlock clickBlock;
@property (nonatomic,copy) InsertionSuccessBlock successBlock;
@property (nonatomic,copy) BtnClickBlock btnClickBlock;
+ (void)showInsertionViewSuccessBlock:(InsertionSuccessBlock)successBlock clickBlock:(ClickBlock)clickBlock removeBlock:(RemoveBlock)removeBlock btnClickBlock:(BtnClickBlock)btnClickBlock;

@end
