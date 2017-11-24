//
//  HistoryAndBookmarkListViewController.h
//  WebBrowser
//
//  Created by apple on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, ListDataOperationKind) {
    ListDataOperationKindHistory = 0,
    ListDataOperationKindBookmark
};


@interface HistoryAndBookmarkListViewController : BaseViewController
@property(nonatomic,assign)ListDataOperationKind listDataOperationKind;
@property (nonatomic, assign) FromVCComeInKind fromVCComeInKind;
@end
