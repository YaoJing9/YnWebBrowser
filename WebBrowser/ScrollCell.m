//
//  ScrollCell.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/29.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ScrollCell.h"

@interface ScrollCell () <SDCycleScrollViewDelegate>

@end


@implementation ScrollCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        [self createSubViews:imageAry];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier imageAry:(NSArray *)imageAry;
{
    ScrollCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[ScrollCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier imageAry:imageAry];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)createSubViews:(NSArray *)buttonTitleArray{
    WS(weakSelf);
    NSArray *imageAry = [buttonTitleArray valueForKeyPath:@"icon"];
    NSArray *titleAry = [buttonTitleArray valueForKeyPath:@"name"];
    NSArray *urlAry = [buttonTitleArray valueForKeyPath:@"link"];
    _cycleScrollView2 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake((SCREENWIDTH - 320)/2, 7, 320, 83) delegate:self placeholderImage:nil];
    
    _cycleScrollView2.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _cycleScrollView2.titlesGroup = titleAry;
    _cycleScrollView2.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    _cycleScrollView2.clipsToBounds = YES;
    _cycleScrollView2.layer.cornerRadius = 5;

    [self addSubview:_cycleScrollView2];
    //         --- 模拟加载延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.cycleScrollView2.imageURLStringsGroup = imageAry;
    });
    
     _cycleScrollView2.clickItemOperationBlock = ^(NSInteger index) {

         if (weakSelf.scrollCellClicKBlock) {
             weakSelf.scrollCellClicKBlock(urlAry[index]);
         }
     
     };
 }

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
