//
//  CardMainView.h
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardCollectionViewCell;
@class WebModel;

typedef void(^CompletionBlock)(WebModel *model);

@interface CardMainView : UIView

@property(nonatomic,assign)BOOL isFirstVC;
/**
typedef NS_ENUM(NSInteger, FromVCComeInKind) {
    FromVCComeInKindROOTVC = 0,
    FromVCComeInKindWEBVIEW = 1,
    FromVCComeInKindSEARCH = 2
};*/
@property(nonatomic,assign)NSInteger fromVCComeInKind;
- (void)reloadCardMainViewWithCompletionBlock:(CompletionBlock)completion;
- (void)changeCollectionViewLayout;

@end
