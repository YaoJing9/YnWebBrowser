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
        
        
        NSInteger line = i%5;
        NSInteger clow = i/5;
        CGFloat cellWidth = SCREENWIDTH/5;
        
        CGFloat cellX = cellWidth * line;
        CGFloat cellY = ClassifyBottomCellGap + (ClassifyBottomCellGap + ClassifyBottomViewHeight)*clow;
        ImgTitleView *button = [[ImgTitleView alloc] initWithFrame:CGRectMake(cellX, cellY, cellWidth, ClassifyBottomViewHeight) imageView:CGSizeMake(BTNWH, BTNWH) gap:7 font:PFSCMediumFont(13) color:[UIColor colorWithHexString:@"#333333"] tag:i + 100];
        button.title = buttonTitleArray[i][@"name"];
        button.placeholderImage = @"bottomzw";
        button.imageUrl = buttonTitleArray[i][@"icon"];
        
//        FL_Button *button = [FL_Button buttonWithType:UIButtonTypeCustom];
//        button.titleLabel.font = PFSCMediumFont(13);
//        [button setTitle:buttonTitleArray[i][@"name"] forState:UIControlStateNormal];
//        [button sd_setImageWithURL:[NSURL URLWithString:buttonTitleArray[i][@"icon"]] forState:normal placeholderImage:nil];
//        [button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
//        button.tag = 100 + i;
//        button.fl_imageWidth = BTNWH;
//        button.fl_imageHeight = BTNWH;
//        button.fl_padding = 7;
//        button.status = FLAlignmentStatusTop;
//        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        button.imgTitleViewBlock = ^(NSInteger index) {
            [weakSelf buttonAction:index];
        };
//
//        [button mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(weakSelf.contentView).offset(ClassifyBottomCellGap + (ClassifyBottomCellGap + ClassifyBottomViewHeight)*clow);
//            make.left.equalTo(weakSelf.contentView).offset(cellWidth * line);
//            make.width.equalTo(@(cellWidth));
//            make.height.equalTo(@(ClassifyBottomViewHeight));
//        }];
        
        UIImageView *sendLine = [UIImageView new];
        sendLine.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
        [self addSubview:sendLine];
        [sendLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(weakSelf);
            make.height.mas_equalTo(0.5);
        }];
    }
    
}

- (void)buttonAction:(NSInteger)index{
        
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
