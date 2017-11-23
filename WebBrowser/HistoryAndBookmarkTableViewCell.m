//
//  HistoryAndBookmarkTableViewCell.m
//  WebBrowser
//
//  Created by apple on 2017/11/22.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "HistoryAndBookmarkTableViewCell.h"

@implementation HistoryAndBookmarkTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"HistoryAndBookmarkTableViewCell" owner:nil options:nil] lastObject];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
