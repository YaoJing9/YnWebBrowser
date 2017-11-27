//
//  HistoryRecordCell.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryRecordCell.h"


@interface HistoryRecordCell ()

@property(nonatomic ,strong)UILabel *titleLabel;
@property(nonatomic ,strong)UILabel *linkLabel;
@end
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
    
    _titleLabel = [UILabel new];
    _titleLabel.text = @"快眼看书迷";
    _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftImgView.mas_right).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.height.equalTo(@20);
        make.top.equalTo(weakSelf.contentView).offset(15);
    }];
    
    _linkLabel = [UILabel new];
//    linkLabel.text = @"baidu.com";
    _linkLabel.textColor = [UIColor colorWithHexString:@"#4b94f7"];
    _linkLabel.font = [UIFont systemFontOfSize:11];
    [self.contentView addSubview:_linkLabel];
    [_linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.right.equalTo(self.mas_right).offset(-10); make.left.equalTo(leftImgView.mas_right).offset(5);
        make.height.equalTo(@15);
        make.top.equalTo(_titleLabel.mas_bottom);
    }];
    
}

- (void)setModel:(HistoryItemModel *)model{
    self.titleLabel.text = model.title;
    self.linkLabel.text = model.url;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
