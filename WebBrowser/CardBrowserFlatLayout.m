//
//  CardBrowserFlatLayout.m
//  WebBrowser
//
//  Created by 钟武 on 2017/3/1.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "CardBrowserFlatLayout.h"

@interface CardBrowserFlatLayout ()

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributes;
@property (nonatomic, assign) CGSize contentSize;

@end

@implementation CardBrowserFlatLayout

- (instancetype)init{
    if (self = [super init]) {
        _attributes = [NSMutableArray array];
    }
    return self;
}

#pragma mark - UICollectionViewLayout (UISubclassingHooks)

- (void)prepareLayout
{
    [super prepareLayout];
    
    
    CGFloat width = roundf(300);
    CGFloat height = roundf(width * 1.5);
    
    CGFloat top = (self.collectionView.frame.size.height - height) / 2;
    CGFloat left = 10.0f;

    [self.attributes removeAllObjects];
    
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:0]; item++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGRect frame = CGRectMake(left, top, width, height);
        attributes.frame = frame;
        attributes.zIndex = item;
        
        [self.attributes addObject:attributes];
        
        left += width;
    }
    
    if (self.attributes.count)
    {
        UICollectionViewLayoutAttributes *lastItemAttributes = [self.attributes lastObject];
        self.contentSize = CGSizeMake(lastItemAttributes.frame.origin.x + lastItemAttributes.frame.size.width + 10, height);
    }
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributesInRect = [NSMutableArray array];
    
    foreach(attributes, self.attributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesInRect addObject:attributes];
        }
    }
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.attributes.count) {
        return self.attributes[indexPath.item];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    if (itemIndexPath.item < self.attributes.count) {
        return self.attributes[itemIndexPath.item];
    }
    return nil;
}

@end
