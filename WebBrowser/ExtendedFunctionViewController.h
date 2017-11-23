//
//  ExtendedFunctionViewController.h
//  WebBrowser
//
//  Created by apple on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, ExtendedOperationKind) {
    ExtendedOperationKindYEJIAN = 0,
    ExtendedOperationKindNOIMAGE = 1,
    ExtendedOperationKindNOHISTORY = 2
};
@interface ExtendedFunctionViewController : BaseViewController
@property(nonatomic,assign)ExtendedOperationKind extendedOperationKind;
@end
