//
//  HistoryRecordCell.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryRecordCell.h"

@implementation HistoryRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier;
{
    HistoryRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[HistoryRecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)createSubViews{
    WS(weakSelf);
    UIImageView *leftImgView = [UIImageView new];
    leftImgView.image = [UIImage imageNamed:@"可能性ICON"];
    [self.contentView addSubview:leftImgView];
    [leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.contentView);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.width.equalTo(@16);
        make.height.equalTo(@16);
    }];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
