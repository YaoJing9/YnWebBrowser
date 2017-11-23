//
//  ClassifyCell.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/21.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassifyCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry;

@end
