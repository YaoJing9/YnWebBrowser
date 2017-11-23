//
//  YnSearchController.h
//  WebBrowser
//
//  Created by yaojing on 2017/11/23.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BaseViewController.h"

@interface YnSearchController : BaseViewController
/** 搜索栏 */
@property (nonatomic, weak) UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *tagsArray;
@end
