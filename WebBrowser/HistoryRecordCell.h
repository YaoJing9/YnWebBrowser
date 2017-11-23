//
//  HistoryRecordCell.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryRecordCell : UITableViewCell
@property(nonatomic ,strong)NSString *title;
+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier;

@end
