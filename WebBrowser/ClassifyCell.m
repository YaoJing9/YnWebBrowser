//
//  ClassifyCell.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/21.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ClassifyCell.h"
@implementation ClassifyCell
#define BTNWH 28

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
    ClassifyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[ClassifyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier imageAry:imageAry];
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
        CGFloat cellY = ClassifyCellGap + (ClassifyCellGap + ClassifyViewHeight)*clow;
        ImgTitleView *button = [[ImgTitleView alloc] initWithFrame:CGRectMake(cellX, cellY, cellWidth, ClassifyViewHeight) imageView:CGSizeMake(BTNWH, BTNWH) gap:7 font:PFSCMediumFont(11) color:[UIColor colorWithHexString:@"#333333"] tag:i + 100];
        button.title = buttonTitleArray[i][@"name"];
        button.placeholderImage = @"topzw";
        button.imageUrl = buttonTitleArray[i][@"icon"];
        [self.contentView addSubview:button];
        button.imgTitleViewBlock = ^(NSInteger index) {
            [weakSelf buttonAction:index];
        };
    
    }
    
//    UIImageView *sendLine = [UIImageView new];
//    sendLine.backgroundColor = [UIColor colorWithHexString:@"#E2E2E2"];
//    [self addSubview:sendLine];
//    [sendLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(weakSelf);
//        make.height.mas_equalTo(0.5);
//    }];
    
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
