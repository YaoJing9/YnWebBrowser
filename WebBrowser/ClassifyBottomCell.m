//
//  ClassifyBottomCell.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/28.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ClassifyBottomCell.h"

@implementation ClassifyBottomCell
#define BTNWH 40

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createSubViews:imageAry];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry;
{
    ClassifyBottomCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[ClassifyBottomCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier imageAry:imageAry];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)createSubViews:(NSArray *)buttonTitleArray{
    
    WS(weakSelf);
    
    _dataAry = buttonTitleArray;
    
    for (int i=0; i<buttonTitleArray.count; i++) {
        FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
        [button setTitle:buttonTitleArray[i][@"name"] forState:UIControlStateNormal];
        button.titleLabel.font = PFSCMediumFont(13);
        [button sd_setImageWithURL:[NSURL URLWithString:buttonTitleArray[i][@"icon"]] forState:normal placeholderImage:nil];
        [button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        button.tag = 100 + i;
        button.fl_imageWidth = BTNWH;
        button.fl_imageHeight = BTNWH;
        button.fl_padding = 7;
        button.status = FLAlignmentStatusTop;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        
        NSInteger line = i%5;
        NSInteger clow = i/5;
        CGFloat cellWidth = SCREENWIDTH/5;        

        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.contentView).offset(ClassifyBottomCellGap + (ClassifyBottomCellGap + ClassifyBottomViewHeight)*clow);
            make.left.equalTo(weakSelf.contentView).offset(cellWidth * line);
            make.width.equalTo(@(cellWidth + 5));
            make.height.equalTo(@(ClassifyBottomViewHeight));
        }];
    }
    
}

- (void)buttonAction:(FL_Button *)btn{
    
    NSInteger index = btn.tag - 100;
    
    NSString *link = _dataAry[index][@"link"];
    
    if (self.classifyCellClicKBlock) {
        self.classifyCellClicKBlock(link);
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
