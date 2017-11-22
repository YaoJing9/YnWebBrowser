//
//  TopToolBarShapeView.h
//  WebBrowser
//
//  Created by 钟武 on 2016/10/12.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopToolBarShapeView : UIView

@property (nonatomic, readonly) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UITextField *textField;

- (void)setTopURLOrTitle:(NSString *)urlOrTitle;

@end
