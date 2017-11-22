//
//  ClassifyCell.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/21.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ClassifyCell.h"

@implementation ClassifyCell

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
    ClassifyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[ClassifyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)createSubViews{
    
    WS(weakSelf);
    
    FL_Button *clowBtn;
    
    NSArray *buttonTitleArray = @[@"网址",@"网址",@"网址",@"网址",@"网址",@"网址",@"网址",@"网址",@"网址",@"网址"];
    
    for (int i=0; i<buttonTitleArray.count; i++) {
        FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setImage:[UIImage imageNamed:buttonTitleArray[i]] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        button.tag = 100 + i;
        button.status = FLAlignmentStatusTop;
        button.fl_padding = 10;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        button.userInteractionEnabled = NO;
        
        
        
        if (clowBtn) {
            
            
            if (i < 5) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(clowBtn);
                    make.left.equalTo(clowBtn.mas_right);
                    make.width.equalTo(clowBtn);
                    make.height.equalTo(clowBtn);
                }];
            }else if (i == 5){
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(145/2.0));
                    make.left.equalTo(weakSelf.contentView);
                    make.width.equalTo(clowBtn);
                    make.height.equalTo(clowBtn);
                }];
            }else{
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@(145/2.0));
                    make.left.equalTo(clowBtn.mas_right);
                    make.width.equalTo(clowBtn);
                    make.height.equalTo(clowBtn);
                }];
            }
            
            

        }else{
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.contentView);
                make.left.equalTo(weakSelf.contentView);
                make.width.equalTo(@(SCREENWIDTH/5));
                make.height.equalTo(@(145/2.0));
            }];
            
        }
        clowBtn = button;
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
