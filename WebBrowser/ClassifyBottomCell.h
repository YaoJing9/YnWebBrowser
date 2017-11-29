//
//  ClassifyBottomCell.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/28.
//  Copyright © 2017年 钟武. All rights reserved.
//

#define ClassifyBottomCellGap 15
#define ClassifyBottomViewHeight 65

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"
typedef void(^ClassifyCellClicKBlock)(NSString *);

@interface ClassifyBottomCell : UITableViewCell

@property(nonatomic, copy)ClassifyCellClicKBlock classifyCellClicKBlock;
@property(nonatomic, strong)NSArray *dataAry;
+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry;

@end
