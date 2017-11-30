//
//  HistoryRecordCell.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistorySQLiteManager.h"
@interface HistoryRecordCell : UITableViewCell

@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *url;
+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier;

@end
