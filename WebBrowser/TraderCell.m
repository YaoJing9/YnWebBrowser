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
    
    _dataAry = buttonTitleArray;
    
    for (int i=0; i<buttonTitleArray.count; i++) {
        
        NSDictionary *dict = buttonTitleArray[i];
        
        FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
        [button setTitle:dict[@"name"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
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
            button.enabled = NO;
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
    
    UIImageView *sendLine = [UIImageView new];
    sendLine.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self addSubview:sendLine];
    [sendLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(weakSelf);
        make.left.equalTo(weakSelf).offset(15);
        make.height.mas_equalTo(0.5);
    }];
    
}

- (void)buttonAction:(FL_Button *)btn{
    
    NSInteger index = btn.tag - 100;
    
    NSString *link = _dataAry[index][@"link"];
    
    if (self.traderCellClicKBlock) {
        self.traderCellClicKBlock(link);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
