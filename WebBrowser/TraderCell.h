//
//  TraderCell.h
//  XDLitchi
//
//  Created by yaojing on 2017/10/16.
//  Copyright © 2017年 YaoJing. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TraderCellClicKBlock)(NSString *);

@interface TraderCell : UITableViewCell

@property(nonatomic, copy)TraderCellClicKBlock traderCellClicKBlock;
@property(nonatomic, strong)NSArray *dataAry;

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier titleAry:(NSArray *)titleAry;

@end
