//
//  TraderCell.m
//  XDLitchi
//
//  Created by yaojing on 2017/10/16.
//  Copyright © 2017年 YaoJing. All rights reserved.
//

#import "TraderCell.h"

@interface TraderCell()
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIImageView *leftImageView;
@property(nonatomic,strong)UILabel *downMoneyLabel;
@property(nonatomic,strong)UILabel *informationLabel;
@property(nonatomic,strong)UILabel *omLabel;
@property(nonatomic,strong)UILabel *igoldLabel;
@property(nonatomic,strong)UILabel *rmbLabel;
@property(nonatomic,strong)UILabel *aLabel;
@property(nonatomic,strong)UILabel *bottomLabel1;
@property(nonatomic,strong)UILabel *bottomLabel2;
@property(nonatomic,strong)UILabel *bottomLabel3;
@end

@implementation TraderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier
{
    TraderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[TraderCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)createSubViews{

    WS(weakSelf);
    _nameLabel = [UILabel new];
    _nameLabel.numberOfLines = 1;
    _nameLabel.text = @"泰豪";
    [self addSubview:_nameLabel];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(10);
        make.left.equalTo(weakSelf).offset(10);
        make.width.lessThanOrEqualTo(@(self.width - 10));
    }];
    

    [_bottomLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.bottomLabel1);
        make.right.equalTo(weakSelf).offset(-10);
        make.left.equalTo(weakSelf.bottomLabel2.mas_right).offset(10);

    }];
    
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
