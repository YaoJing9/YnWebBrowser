//
//  ClassifyCell.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/21.
//  Copyright © 2017年 钟武. All rights reserved.
//


#define ClassifyCellGap 17
#define ClassifyViewHeight 45

#import <UIKit/UIKit.h>
typedef void(^ClassifyCellClicKBlock)(NSString *);

@interface ClassifyCell : UITableViewCell

@property(nonatomic, copy)ClassifyCellClicKBlock classifyCellClicKBlock;
@property(nonatomic, strong)NSArray *dataAry;
+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry;

@end
