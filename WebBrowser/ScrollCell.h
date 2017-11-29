//
//  ScrollCell.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"
typedef void(^ScrollCellClicKBlock)(NSString *);

@interface ScrollCell : UITableViewCell
@property(nonatomic, copy)ScrollCellClicKBlock scrollCellClicKBlock;
@property(nonatomic, strong) SDCycleScrollView *cycleScrollView2;
+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry;

@end
