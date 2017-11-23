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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier titleAry:(NSArray *)titleAry
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews:titleAry];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier titleAry:(NSArray *)titleAry
{
    TraderCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[TraderCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier titleAry:titleAry];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)createSubViews:(NSArray *)buttonTitleArray{

    WS(weakSelf);
    FL_Button *clowBtn;
    for (int i=0; i<buttonTitleArray.count; i++) {
        FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithHexString:@"#999999"] forState:UIControlStateNormal];
        }else{
            [button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        }
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (clowBtn) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(clowBtn);
                make.left.equalTo(clowBtn.mas_right);
                make.width.equalTo(clowBtn);
                make.height.equalTo(clowBtn);
            }];
    
            
        }else{
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.contentView);
                make.left.equalTo(weakSelf.contentView);
                make.width.equalTo(@(SCREENWIDTH/5));
                make.height.equalTo(@(50));
            }];
            
            UILabel *lineLabel = [UILabel new];
            [button addSubview:lineLabel];
            lineLabel.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
            [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(button.mas_top).offset(15);
                make.right.equalTo(button);
                make.width.equalTo(@(1));
                make.height.equalTo(@(20));
            }];
            
        }
        clowBtn = button;
    }
    
}
- (void)buttonAction:(FL_Button *)nbtn{
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
