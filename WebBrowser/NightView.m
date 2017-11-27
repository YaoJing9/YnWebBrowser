//
//  NightView.m
//  WebBrowser
//
//  Created by apple on 2017/11/27.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "NightView.h"

static NightView *_nightView;

@implementation NightView
SYNTHESIZE_SINGLETON_FOR_CLASS(NightView)
+(instancetype)showNightView{
    return [[self alloc] initWithshownNightView];
}
- (instancetype)initWithshownNightView{
    
    if (self = [super init]) {
        _nightView = self;
        _nightView.frame = UIApplication.sharedApplication.keyWindow.frame;
        _nightView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _nightView.userInteractionEnabled = NO;
        _nightView.hidden = YES;
        [_nightView createContentView];
    }
    return _nightView;
}

-(void)createContentView{
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    [UIView animateWithDuration:1 delay:0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.hidden = NO;
    } completion:^(BOOL finished) {
        
        
    }];
}
+(void)deleNightView{
    _nightView.hidden = YES;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
