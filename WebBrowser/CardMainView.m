//
//  CardMainView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/12/20.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "CardMainView.h"
#import "SaveImageTool.h"
#import "CardBrowserFlatLayout.h"
#import "CardBrowserCollectionViewLayout.h"
#import "CardCollectionViewCell.h"
#import "CardMainBottomView.h"
#import "BrowserHeader.h"
#import "TabManager.h"
#import "BrowserWebView.h"
#import "BrowserContainerView.h"
#import "BrowserViewController.h"
#import "NSObject+DXObject.h"
#define CardCellIdentifier @"cell"
#define CollectionViewTopMargin 50
#define CollectionViewSideMargin 50

@interface CardMainView () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate,  CardBottomClickedDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<WebModel *> *cardArr;
@property (nonatomic, strong) CardMainBottomView *cardBottomView;
@property (nonatomic, strong) CardBrowserFlatLayout *flatLayout;
@property (nonatomic, strong) CardBrowserCollectionViewLayout *browserLayout;

@end

@implementation CardMainView
@synthesize cardArr = _cardArr;

- (NSMutableArray<WebModel *> *)cardArr{
    if (!_cardArr) {
        _cardArr = [NSMutableArray array];
    }
    return _cardArr;
}

- (void)setCardsWithArray:(NSArray<WebModel *> *)array{
    [self.cardArr removeAllObjects];
    [self.cardArr addObjectsFromArray:array];
    
    dispatch_main_safe_async(^{
        [self.collectionView reloadData];
    })
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInitWithFrame:frame];
    }
    
    return self;
}

- (void)commonInitWithFrame:(CGRect)frame{
    self.backgroundColor = [UIColor whiteColor];
    
    self.collectionView = ({
        self.flatLayout = [CardBrowserFlatLayout new];
        self.browserLayout = [CardBrowserCollectionViewLayout new];
    
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.flatLayout];

        collectionView.backgroundColor = [UIColor blackColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.alwaysBounceVertical = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[CardCollectionViewCell class] forCellWithReuseIdentifier:CardCellIdentifier];
        
        [self addSubview:collectionView];
        
//        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
//        panGestureRecognizer.minimumNumberOfTouches = 1;
//        panGestureRecognizer.maximumNumberOfTouches = 1;
//        panGestureRecognizer.delegate = self;
//        [collectionView addGestureRecognizer:panGestureRecognizer];

        collectionView;
    });
    
    self.cardBottomView = ({
        CardMainBottomView *bottomView = [[CardMainBottomView alloc] initWithFrame:CGRectMake(0, self.height - BOTTOM_TOOL_BAR_HEIGHT, self.width, BOTTOM_TOOL_BAR_HEIGHT)];
        [self addSubview:bottomView];
        bottomView.bottomDelegate = self;
        
        bottomView;
    });
}

- (void)reloadCardMainViewWithCompletionBlock:(CompletionBlock)completion{
    WEAK_REF(self)
    [[TabManager sharedInstance] setMultiWebViewOperationBlockWith:^(NSArray<WebModel *> *modelArray){
        STRONG_REF(self_)
        if (self__) {
            [self__ setCardsWithArray:modelArray];
            if (self__.cardArr.count != 0) {
                [self__.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self__.cardArr.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }
            
            WebModel*model = modelArray[self__.cardArr.count - 1];
            if (completion) {
                completion(model);
            }
        }
    }];
}

- (void)changeCollectionViewLayout{
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout == self.flatLayout ? self.browserLayout : self.flatLayout;
    [self.collectionView setCollectionViewLayout:layout animated:YES completion:^(BOOL finished){
        
        
    }];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item < [self collectionView:collectionView numberOfItemsInSection:0]) {
        WebModel *webModel = [self.cardArr objectAtIndex:indexPath.item];
        //将原来微博本地数据源当前位置的model删除 然后加到最后一个
        [self.cardArr removeObjectAtIndex:indexPath.item];
        [self.cardArr addObject:webModel];
        WEAK_REF(self)
        //更新数据源s
        [[TabManager sharedInstance] updateWebModelArray:self.cardArr completion:^{
            STRONG_REF(self_)
        
            [self__ removeSelfFromSuperViewWith:webModel];
        }];
    }
    else{
        [self removeSelfFromSuperViewWith:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.cardArr.count;
}

- (CardCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CardCollectionViewCell *cell = (CardCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CardCellIdentifier forIndexPath:indexPath];
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    cell.collectionView = collectionView;
    
    WEAK_REF(self)
    cell.closeBlock = ^(NSIndexPath *index){
        STRONG_REF(self_)
        if (self__) {
            [self__.cardArr removeObjectAtIndex:index.item];
            [[TabManager sharedInstance] updateWebModelArray:self__.cardArr];
            [self__.collectionView performBatchUpdates:^{
            [self__.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index.item inSection:0]]];
            }completion:nil];
        }
    };
    WebModel *webModel = self.cardArr[indexPath.item];
    if (webModel.isNewWebView == YES) {
        webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
        
    }
    [cell updateWithWebModel:webModel];
    
    return cell;
}

#pragma mark - CardBottomClickedDelegate

- (void)cardBottomBtnClickedWithTag:(ButtonClicked)tag{
    switch (tag) {
        case ReturnButtonClicked:
        {
            if ([self.collectionView numberOfItemsInSection:0]) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:[self.collectionView numberOfItemsInSection:0] - 1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }

            
            
            [self removeSelfFromSuperViewWith:nil];
            break;
        }
        case AddButtonClicked:
            [self addCollectionViewCell];
            break;
        case CloseAllButtonClicked:
            [self closseAllCollectionViewCell];
            break;
        default:
            break;
    }
}
-(void)popMainViewWithCompletionBlock:(PopBlock)completion{
    self.block = completion;
}
- (void)removeSelfFromSuperViewWith:(WebModel *)webModel{
    
    [PreferenceHelper setInteger:self.cardArr.count forKey:KeyBridgeNumber];
    
    [[TabManager sharedInstance].browserContainerView restoreWithCompletionHandler:^(WebModel *webModel, BrowserWebView *browserWebView){
        NSNotification *notify = [NSNotification notificationWithName:kWebTabSwitch object:self userInfo:@{@"webView":browserWebView}];
        [Notifier postNotification:notify];
    } animation:NO];
    
    if (webModel == nil) {
        
    }
    
    WEAK_REF(self)
    [self.collectionView setCollectionViewLayout:self.flatLayout animated:YES completion:^(BOOL finished){
        STRONG_REF(self_)
        if (self__) {
            if (webModel != nil) {
                
                if (webModel.isNewWebView == YES) {
                    if (_isFirstVC == YES) {
                        
                    }else{
                        if (self__.block) {
                            dispatch_main_safe_async(^{
                                self__.block(webModel);
                            })
                        }
                    }
                    
                }else{
                    
                    if (_isFirstVC == YES) {
                        
                        [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[webModel.url] key:DelegateManagerBrowserContainerLoadURL];
                        
                        BrowserViewController *vc = [BrowserViewController new];
                        
                        vc.url = webModel.url;
                        vc.fromVCComeInKind = FromVCComeInKindROOTVC;
                        [[self__ obtainTopViewController].navigationController pushViewController:vc animated:NO];
                    }else{
                        
                    }
                    
                }
            }else{
                
//                self__.block(webModel);
            }
            
            
            [self__ removeFromSuperview];
        }
        [[TabManager sharedInstance] saveWebModelData];
    }];
}

- (void)addCollectionViewCell{
    NSInteger num = [self.collectionView numberOfItemsInSection:0];

    if (num >= 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:num - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        WebModel *webModel = [WebModel new];
        webModel.title = DEFAULT_CARD_CELL_TITLE;
        webModel.url = DEFAULT_CARD_CELL_URL;
        webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
        webModel.isNewWebView = YES;
        [self.cardArr addObject:webModel];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:num inSection:0]]];
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:num inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [[TabManager sharedInstance] updateWebModelArray:self.cardArr];
    });
}

- (void)closseAllCollectionViewCell{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < self.cardArr.count; i++) {
        [array addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    [self.cardArr removeAllObjects];
    
    [[TabManager sharedInstance] updateWebModelArray:self.cardArr completion:^{
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView deleteItemsAtIndexPaths:array];
            
            
        }completion:nil];
    }];
  
}

#pragma mark - PanGesture Method

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer{    
    CGPoint point = [recognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.browserLayout.pannedItemIndexPath = indexPath;
        self.browserLayout.panStartPoint = point;
        return;
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.browserLayout.panUpdatePoint = point;
        [self.browserLayout invalidateLayout];
    } else {
        if (fabs(point.x - self.browserLayout.panStartPoint.x) > self.collectionView.frame.size.width / 4 && point.x < self.browserLayout.panStartPoint.x && self.browserLayout.pannedItemIndexPath) {
            NSIndexPath *copyPannedIndexPath = self.browserLayout.pannedItemIndexPath;
            self.browserLayout.pannedItemIndexPath = nil;
            CardCollectionViewCell *cell = (CardCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:copyPannedIndexPath];
            if (cell.closeBlock) {
                cell.closeBlock(copyPannedIndexPath);
                cell.closeBlock = nil;
            }
        }
        else{
            self.browserLayout.pannedItemIndexPath = nil;
            [self.collectionView performBatchUpdates:^{
            } completion:nil];
        }
        
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.collectionView];
    if (fabs(velocity.x) > fabs(velocity.y)) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Dealloc Method

- (void)dealloc{
   // DDLogDebug(@"CardMainView dealloced");
}

@end
