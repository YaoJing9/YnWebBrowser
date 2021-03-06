//
//  BrowserViewController.h
//  WebBrowser
//
//  Created by 钟武 on 16/7/30.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BrowserContainerView.h"
@interface BrowserViewController : BaseViewController<UIScrollViewDelegate>

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BrowserViewController)

- (void)findInPageDidUpdateCurrentResult:(NSInteger)currentResult;
- (void)findInPageDidUpdateTotalResults:(NSInteger)totalResults;
- (void)findInPageDidSelectForSelection:(NSString *)selection;
@property (nonatomic, strong) BrowserContainerView *browserContainerView;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,assign)FromVCComeInKind fromVCComeInKind;
@end
