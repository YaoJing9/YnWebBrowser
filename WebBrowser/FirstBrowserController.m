//
//  FirstBrowserControllerViewController.m
//  WebBrowser
//
//  Created by yaojing on 2017/11/21.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "FirstBrowserController.h"
#import "NightView.h"
#import "PreferenceHelper.h"
#import "SaveImageTool.h"
#import "TabManager.h"
#import "BrowserBottomToolBar.h"
#import "BrowserContainerView.h"
#import "CardMainView.h"
#import "SettingsViewController.h"
#import "SettingsTableViewController.h"
#import "HistoryTableViewController.h"
#import "HistoryAndBookmarkListViewController.h"
#import "DelegateManager+WebViewDelegate.h"
#import "BookmarkTableViewController.h"
#import "BookmarkDataManager.h"
#import "BookmarkItemEditViewController.h"
#import "FindInPageBar.h"
#import "KeyboardHelper.h"
#import "NSURL+ZWUtility.h"
#import "ExtentionsTableViewController.h"
#import "TraderCell.h"
#import "ClassifyCell.h"
#import "ClassifyBottomCell.h"
#import "MoreSettingView.h"
#import "ExtendedFunctionViewController.h"
#import "YnSearchController.h"
#import "BrowserViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "PreferenceHelper.h"
#import "ScrollCell.h"
#define kSeniverseAPI @"rzk44lplyy7hyai9"
#define kSeniverseID @"U390895EA3"


@interface FirstBrowserController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,BrowserBottomToolBarButtonClickedDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong) BrowserBottomToolBar *bottomToolBar;
@property (nonatomic, assign) BOOL isWebViewDecelerate;
@property (nonatomic, weak) id<BrowserBottomToolBarButtonClickedDelegate> browserButtonDelegate;
@property (nonatomic, strong) FindInPageBar *findInPageBar;
@property (nonatomic, weak) NSLayoutConstraint *findInPageBarbottomLayoutConstaint;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, strong) NSArray *topDataAry;
@property (nonatomic, strong) NSArray *conentDataAry;
@property (nonatomic, strong) NSArray *bottomDataAry;
@property (nonatomic, assign) CGFloat oldOffset;
@property (nonatomic, strong) NSString *cityLoca;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic,  ) UIImageView *weatherImgView;
@property (nonatomic, strong) NSMutableArray *dataAry;
@property (nonatomic, strong) NSMutableArray *topImagAry;
@property (nonatomic, strong) NSDictionary *allDataDict;

@end

@implementation FirstBrowserController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor colorWithHexString:@"#dedede"];
//        _tableView.backgroundColor = RGBColor(27, 142, 248);
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (WebModel *)getDefaultWebModel{
    WebModel *webModel = [WebModel new];
    webModel.title = DEFAULT_CARD_CELL_TITLE;
    webModel.url = DEFAULT_CARD_CELL_URL;
    webModel.isNewWebView = YES;
    webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
    return webModel;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    WebModel *webModel = [[TabManager sharedInstance] getCurrentWebModel];
    webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
    webModel.isNewWebView = YES;
    
    [[TabManager sharedInstance] setMultiWebViewOperationBlockWith:^(NSArray<WebModel *> *array) {
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:array];
        
        if (array.count == 0) {
            
            [dataArray addObject:[self getDefaultWebModel]];
        }else{
            WebModel *model = dataArray.lastObject;
            webModel.image = [[SaveImageTool sharedInstance] GetImageFromLocal:@"firstImage"];
            webModel.isNewWebView = YES;
            [dataArray replaceObjectAtIndex:dataArray.count - 1 withObject:model];
        }
        self.bottomToolBar.multiWindowItemStr = [NSString stringWithFormat:@"%ld",dataArray.count];
        [[TabManager sharedInstance] updateWebModelArray:dataArray completion:^{
            
            
            if (BrowserVC != nil && BrowserVC.browserContainerView != nil) {
                [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[@""] key:DelegateManagerBrowserContainerLoadURL];
            }else{
                [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[DEFAULT_CARD_CELL_URL] key:DelegateManagerBrowserContainerLoadURL];
            }
            
            
        }];
        
        
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDataAry];
    [self initializeView];

    [self requestLocation];
    [self createBgview];
    [self requestAllData];
    [self requestData];
    [self requestHomeData];
    
    [[DelegateManager sharedInstance] registerDelegate:self forKeys:@[DelegateManagerWebView, DelegateManagerFindInPageBarDelegate]];
    
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];
    
    self.bottomToolBar.multiWindowItemStr = @"1";
    
//    [[TabManager sharedInstance] updateWebModelArray:nil];
}

- (void)requestHomeData{
    WS(weakSelf);
    NSString *tempURLStr = [NSString stringWithFormat:@"%@browserapi/getmainconfig", YNBaseURL];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *version = [CMNetworkingTool appVersion];
    NSString *package = [CMNetworkingTool appBundleId];
    [parameters setObject:version forKey:@"version"];
    [parameters setObject:package forKey:@"package"];
    
    [[CMNetworkingTool sharedNetworkingTool] requestWithMethod:NetworkingMethodTypeGet urlString:tempURLStr parameters:parameters success:^(NSURLSessionDataTask *dataTask, id responseObject) {
        [weakSelf endRefresh];
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        weakSelf.allDataDict = [YJHelp codeWithError:error][@"data"][@"data"];
        
        if (!weakSelf.allDataDict) {
            return;
        }
        [weakSelf updataHomeData:[YJHelp codeWithError:error][@"data"][@"data"]];
        

        
        [weakSelf.tableView reloadData];
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [[SaveImageTool sharedInstance] SaveImageToLocal:[self.view snapshot] Keys:@"firstImage"];
        });
        [weakSelf endRefresh];
    }];
}

- (void)updataHeaderData{
    NSArray *topAry = _allDataDict[@"banner_top"];
    for (NSInteger i = 0;i< topAry.count;i++) {
        NSDictionary *buttonDict = topAry[i];
        ImgTitleView *button =_topImagAry[i];
        button.title = buttonDict[@"name"];
        button.imageUrl = buttonDict[@"icon"];
    }
}

- (void)updataHomeData:(NSDictionary *)dict{
    
    [self updataHeaderData];
    
    [YnSimpleInterest shareSimpleInterest].searchTopAry = dict[@"suggest"];
    
    NSMutableArray *dataAry1 = dict[@"title"];
    
    NSMutableArray *dataAryBanner = dict[@"banner_img"];

    
    NSDictionary *dataDict = dict[@"navigation"];
    
    
    NSMutableArray *dataAry3 = dict[@"banner_bottom"];

    CGFloat height1 = 0;
    if (dataAry1.count%5 == 0) {
        
        if (dataAry1.count == 5) {
            height1 = (dataAry1.count/5)*ClassifyViewHeight + 2*ClassifyCellGap;
        }else{
            height1 = (dataAry1.count/5)*ClassifyViewHeight + 3*ClassifyCellGap;
        }
    }else{
        if (dataAry1.count < 5) {
            height1 = (dataAry1.count/5 + 1)*ClassifyViewHeight + 2*ClassifyCellGap;
        }else{
            height1 = (dataAry1.count/5 + 1)*ClassifyViewHeight + 3*ClassifyCellGap;
        }
    }
    
    NSArray *ary = [dataDict allKeys];
    NSMutableArray *dataAry2 = [NSMutableArray array];
    for (NSInteger i = 0; i < ary.count; i++) {
        
        NSString *key = ary[i];
        NSArray *subary = dataDict[key];
        NSMutableArray *mary = [subary mutableCopy];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:key forKey:@"name"];
        [dict setObject:@"" forKey:@"link"];
        [dict setObject:@"" forKey:@"linktype"];
        [mary insertObject:dict atIndex:0];
        [dataAry2 addObject:mary];
    }
    
    
    CGFloat height3 = 0;
    if (dataAry3.count%5 == 0) {
        if (dataAry1.count == 5) {
            height3 = (dataAry3.count/5)*ClassifyBottomViewHeight + 2*ClassifyBottomCellGap;
        }else{
            height3 = (dataAry3.count/5)*ClassifyBottomViewHeight + 3*ClassifyBottomCellGap;
        }
    }else{
        if (dataAry1.count < 5) {
            height3 = (dataAry3.count/5 + 1)*ClassifyBottomViewHeight + 2*ClassifyBottomCellGap;
        }else{
            height3 = (dataAry3.count/5 + 1)*ClassifyBottomViewHeight + 3*ClassifyBottomCellGap;
        }
    }
    
    CGFloat heightBanner = 0;
    if ([PreferenceHelper boolForKey:KeyApproveStatus]) {
        heightBanner = 90;
    }else{
        heightBanner = 0;
    }
    
    self.dataArr = [NSMutableArray arrayWithObjects:@[@1,@(height1),dataAry1],
                                                    @[@1,@(heightBanner),dataAryBanner],
                                                    @[@(dataAry2.count),@50,dataAry2],
                                                    @[@1,@(height3),dataAry3], nil];
}

- (void)requestLocation{
    self.locationManager = [[CLLocationManager alloc]init];
    //iOS8之后需要请求权限
    //判断当前手机系统是否高于8.0
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0)
    {
        //请求使用期间访问位置信息权限
        [self.locationManager requestWhenInUseAuthorization];
        //请求一直访问位置信息权限
        //[locationManager requestAlwaysAuthorization];
    }
    //定位精度 kCLLocationAccuracyBest：最精确
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //多少米之外去更新用户位置
    _locationManager.distanceFilter = 100;
    //设置代理
    self.locationManager.delegate = self;
    //开始定位
    [self.locationManager startUpdatingLocation];
    NSLog(@"开始定位");
    
    
    
}

//定位代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *location = locations.lastObject;
    
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    [self loadWeatherWith:coordinate];
    
    //反地理编码
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //放错处理
        if (placemarks.count == 0 || error) {
            //定位出错
            return;
        }
        
        for (CLPlacemark *placemark in placemarks) {
            
            //将当前位置赋给控制器属性
            self.cityLoca = [NSString stringWithFormat:@"%@%@", placemark.locality, placemark.subLocality];
            
            //根据当前位置请求天气数据
            [self loadWeatherWith:placemark.location.coordinate];
            
            
            NSString *ci = [NSString stringWithFormat:@"定位完成\n当前位置：%@", self.cityLoca];
            NSLog(@"%@", ci);
        }
        
    }];
    
    [self.locationManager stopUpdatingLocation];
    
}

//请求天气数据方法
- (void) loadWeatherWith:(CLLocationCoordinate2D)loca {
    
    
    NSString *API = kSeniverseAPI;
    NSString *language = @"zh-Hans";
    NSString *locastr = [NSString stringWithFormat:@"%.2f:%.2f", loca.latitude, loca.longitude];
    NSString *tempURLStr = [NSString stringWithFormat:@"https://api.seniverse.com/v3/weather/now.json?key=%@&location=%@&language=%@&unit=%@", API, locastr, language, @"c"];
    
    
    [[CMNetworkingTool sharedNetworkingTool] requestWithMethod:NetworkingMethodTypeGet urlString:tempURLStr parameters:nil success:^(NSURLSessionDataTask *dataTask, id responseObject) {
        [self updateWeatherView:responseObject[@"results"]];
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        
    }];
    
}


- (void)updateWeatherView:(NSArray *)responseObject{
    _temperatureLabel.text = [NSString stringWithFormat:@"%@°",  responseObject[0][@"now"][@"temperature"]];
    _cityLabel.text = [NSString stringWithFormat:@"%@",  responseObject[0][@"location"][@"name"]];
    
    
    NSInteger code = [responseObject[0][@"now"][@"code"] integerValue];
    NSString *imgStr = nil;
    switch (code) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 38:
            imgStr = @"0";
            break;
            
        case 4:
            imgStr = @"4";
            break;
        case 5:
        case 7:
            imgStr = @"5";
            
            break;
        case 6:
        case 8:
            imgStr = @"6";
            
            break;
        case 9:
            imgStr = @"9";
            
            break;
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
        case 19:
        case 20:
            imgStr = @"10";
            
            break;
        case 21:
        case 22:
        case 23:
        case 24:
        case 25:
        case 37:
            imgStr = @"22";
            break;
        case 26:
        case 27:
        case 28:
        case 29:
            imgStr = @"28";
            
            break;
        case 30:
            imgStr = @"30";
            
            break;
        case 31:
            imgStr = @"31";
            
            break;
            
        case 32:
        case 33:
            imgStr = @"32";
            
            break;
        case 34:
        case 35:
        case 36:
            imgStr = @"34";
            break;
        default:
            break;
    }
    _weatherImgView.image = [UIImage imageNamed:imgStr];
    
}

- (void)requestAllData{
    WS(weakSelf);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestData];
        [weakSelf requestHomeData];
    }];
}

- (void)requestData{
    WS(weakSelf);
    
    NSString *strUrl = @"http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json";
    
    [[CMNetworkingTool sharedNetworkingTool] requestWithMethod:NetworkingMethodTypeGet urlString:strUrl parameters:nil success:^(NSURLSessionDataTask *dataTask, id responseObject) {
        
        [weakSelf requestLocationData:responseObject[@"city"]];
    } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [weakSelf endRefresh];
    }];
}

- (void)requestLocationData:(NSString *)city{
    WS(weakSelf);
    CLGeocoder *myGeocoder = [[CLGeocoder alloc] init];
    [myGeocoder geocodeAddressString:city completionHandler:^(NSArray *placemarks, NSError *error) {
        if ([placemarks count] > 0 && error == nil) {
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            [weakSelf loadWeatherWith:firstPlacemark.location.coordinate];
        }
        else if ([placemarks count] == 0 && error == nil) {
        } else if (error != nil) {
        }
    }];
}

-(void)endRefresh{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MoreSettingView removeMoreSettingView];
}

- (void)initDataAry{
    [self.view addSubview:self.tableView];
    _topImagAry = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createBgview) name:@"llqAppisApprove" object:nil];
}

- (void)createBgview{
    WS(weakSelf);
    
    
    [_topImagAry removeAllObjects];
    
    [PreferenceHelper setBool:YES forKey:KeyHaveBookMarkModeStatus];
    UIView *bgView = [UIView new];
    
    
    
    CGFloat bgViewH = 0;
    if ([PreferenceHelper boolForKey:KeyApproveStatus]) {
        bgViewH = 225;
    }else{
        bgViewH = 180;
    }
    
    bgView.frame = CGRectMake(0, 0, SCREENWIDTH, bgViewH);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bgView.bounds];
    [bgView addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"版头"];
    _tableView.tableHeaderView = bgView;
    UIView *weatherView = [UIView new];
    [bgView addSubview:weatherView];
    [weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).offset(30);
        make.left.equalTo(bgView).offset(0);
        make.right.equalTo(bgView);
        make.height.equalTo(@70);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weatherViewClick:)];
    [weatherView addGestureRecognizer:tap];
    _temperatureLabel = [UILabel new];
    _temperatureLabel.text = @"15";
    _temperatureLabel.textColor = [UIColor whiteColor];
    _temperatureLabel.font = PFSCUltralightFont(45);
    
    [weatherView addSubview:_temperatureLabel];
    [_temperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weatherView);
        make.left.equalTo(weatherView).offset(22);
    }];
    
    _cityLabel = [UILabel new];
    _cityLabel.text = @"";
    _cityLabel.textColor = [UIColor whiteColor];
    _cityLabel.font = PFSCMediumFont(13);
    [weatherView addSubview:_cityLabel];
    [_cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.temperatureLabel).offset(12);
        make.left.equalTo(weakSelf.temperatureLabel.mas_right).offset(15);
    }];
    
    UILabel *numberLabel = [UILabel new];
    numberLabel.text = @"空气良";
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.font = PFSCMediumFont(13);
    [weatherView addSubview:numberLabel];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.cityLabel.mas_bottom).offset(0);
        make.left.equalTo(weakSelf.cityLabel);
    }];
    
    _weatherImgView = [UIImageView new];
    _weatherImgView.image = [UIImage imageNamed:@"天气云"];
    [weatherView addSubview:_weatherImgView];
    [_weatherImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weatherView);
        make.width.equalTo(@35);
        make.height.equalTo(@34);
        make.right.equalTo(weatherView.mas_right).offset(-15);
    }];
    
    UILabel *lable=[[UILabel alloc] init];
    lable.layer.cornerRadius=5;
    lable.clipsToBounds=YES;
    lable.backgroundColor=[UIColor colorWithWhite:1 alpha:0.4];
    lable.userInteractionEnabled = YES;
    [bgView addSubview:lable];
    [lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weatherView.mas_bottom);
        make.left.equalTo(bgView).offset(15);
        make.right.equalTo(weakSelf.view).offset(-15);
        make.height.equalTo(@44);
    }];
    [lable setNeedsLayout];
    UIImageView *leftImg = [UIImageView new];
    leftImg.image = [UIImage imageNamed:@"搜索"];
    [lable addSubview:leftImg];
    [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lable);
        make.left.equalTo(lable).offset(5);
        make.height.equalTo(@17);
        make.width.equalTo(@17);
    }];
    
    _textFiled=[[UITextField alloc] initWithFrame:CGRectMake(AUTOSIZEH(45), 27, SCREENWIDTH-AUTOSIZEH(130), 30)];
    _textFiled.delegate=self;
    _textFiled.textColor=[UIColor blackColor];
    _textFiled.font=PFSCMediumFont(16);
    _textFiled.placeholder=@"搜索或者输入网址";
    [_textFiled setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    _textFiled.keyboardType = UIKeyboardTypeASCIICapable;
    _textFiled.returnKeyType = UIReturnKeySearch;
    [lable addSubview:_textFiled];
    [_textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lable).offset(0);
        make.left.equalTo(leftImg.mas_right).offset(7);
        make.height.equalTo(lable);
        make.right.equalTo(lable);
    }];
    
    //监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoAction) name:UITextFieldTextDidChangeNotification object:nil];
    
    NSArray *buttonTitleArray = @[@"",@"",@"",@"",@""];
    for (int i=0; i<buttonTitleArray.count; i++) {
        
        NSInteger line = i%5;
        NSInteger clow = i/5;
        CGFloat cellWidth = SCREENWIDTH/5;
        
        CGFloat cellX = cellWidth * line;
        CGFloat cellY = 15 + (17 + 45)*clow + 145;
        ImgTitleView *button = [[ImgTitleView alloc] initWithFrame:CGRectMake(cellX, cellY, cellWidth, ClassifyViewHeight) imageView:CGSizeMake(35, 35) gap:4 font:[UIFont systemFontOfSize:11] color:[UIColor whiteColor] tag:i + 100];
        
        
        [bgView addSubview:button];
        [_topImagAry addObject:button];
        
        button.imgTitleViewBlock = ^(NSInteger index) {
            [weakSelf buttonAction:index];
        };
        
        if ([PreferenceHelper boolForKey:KeyApproveStatus]) {
            button.hidden = NO;
        }else{
            button.hidden = YES;
        }
    }
    [self updataHeaderData];
    
}

//天气跳转
- (void)weatherViewClick:(UITapGestureRecognizer *)tap{
    [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[WEATHERURL] key:DelegateManagerBrowserContainerLoadURL];
    BrowserViewController *vc = [BrowserViewController new];
    
    vc.url = WEATHERURL;
    vc.fromVCComeInKind = FromVCComeInKindROOTVC;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark-键盘的监听事件
-(void)infoAction{
    
    
    if (_textFiled.text.length == 0) {
        
        return;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    YnSearchController *vc = [[YnSearchController alloc] init];
    vc.fromVCComeInKind = FromVCComeInKindROOTVC;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav  animated:NO completion:nil];
}

- (void)buttonAction:(NSInteger)index{

    NSArray *linkAry = [_allDataDict[@"banner_top"] valueForKeyPath:@"link"];
    
    NSString *link = linkAry[index];
    
    [self pushWebViewVc:link];
}


#pragma mark - UITableViewDelegate，UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [self.dataArr[section][0] integerValue];
    return number;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = [self.dataArr[indexPath.section][1] floatValue];
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 0;
    }else{
        return 46;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *imageAry = @[@"",@"",@"快速导航", @"生活服务"];
    
    if (section == 0) {
        return nil;
    }else{
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 46)];
        bgView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        
        UIView *bottomView = [UIView new];
        [bgView addSubview:bottomView];
        bottomView.backgroundColor = [UIColor whiteColor];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bgView).offset(7);
            make.left.right.bottom.equalTo(bgView);
        }];
        
        FL_Button *btn = [FL_Button new];
        [btn setTitle:imageAry[section] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imageAry[section]] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor  colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        btn.status = FLAlignmentStatusImageLeft;
        btn.fl_padding = 7;
        [bottomView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomView);
            make.left.equalTo(bottomView).offset(15);
            make.right.bottom.equalTo(bottomView);
        }];

        UIImageView *sendLine = [UIImageView new];
        sendLine.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
        [bgView addSubview:sendLine];
        [sendLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(bgView);
            make.height.mas_equalTo(0.5);
        }];
        
        return bgView;
    }
    
}


- (void)moreSettingClick:(NSInteger)index{
    
    SettingsTableViewController *settingVc = [[SettingsTableViewController alloc] init];
    HistoryAndBookmarkListViewController *historyAndBookmarkVc = [[HistoryAndBookmarkListViewController alloc] init];
    
    
    switch (index) {
        case 0:
            [PreferenceHelper setBool:![PreferenceHelper boolForKey:KeyFullScreenModeStatus] forKey:KeyFullScreenModeStatus];

            break;
        case 1:
            
            [PreferenceHelper setBool:![PreferenceHelper boolForKey:KeyEyeProtectiveStatus] forKey:KeyEyeProtectiveStatus];
            if ([PreferenceHelper boolForKey:KeyEyeProtectiveStatus]) {
                [NightView showNightView];
            } else{
                //设置亮度
                [NightView deleNightView];
            }
            break;
        case 2:
            [PreferenceHelper setBool:![PreferenceHelper boolForKey:KeyNoImageModeStatus] forKey:KeyNoImageModeStatus];
            break;
        case 3:
            [PreferenceHelper setBool:![PreferenceHelper boolForKey:KeyHistoryModeStatus] forKey:KeyHistoryModeStatus];
            break;
        case 4:
            historyAndBookmarkVc.listDataOperationKind = ListDataOperationKindBookmark;
            historyAndBookmarkVc.fromVCComeInKind = FromVCComeInKindROOTVC;
            [self.navigationController pushViewController: historyAndBookmarkVc animated:YES];
            break;
        case 5:
            
            [self addBookmark];

            break;
        case 6:
            [self.navigationController pushViewController: settingVc animated:YES];

            break;
        case 7:
            break;
        case 8:
            break;
            
        default:
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf);
    if (indexPath.section == 0) {
        ClassifyCell *classifyCell = [ClassifyCell cellWithTableView:tableView reuseIdentifier:@"ClassifyCell" imageAry:self.dataArr[indexPath.section][2]];
        classifyCell.classifyCellClicKBlock = ^(NSString *link) {
            [weakSelf pushWebViewVc:link];
        };
        return classifyCell;
    }else if (indexPath.section == 1){
        ScrollCell *cell = [ScrollCell cellWithTableView:tableView reuseIdentifier:@"ScrollCell" imageAry:self.dataArr[indexPath.section][2]];
        cell.scrollCellClicKBlock = ^(NSString *link) {
            [weakSelf pushWebViewVc:link];
        };
        return cell;
    }else if (indexPath.section == 2){
        TraderCell *cell = [TraderCell cellWithTableView:tableView reuseIdentifier:@"VoiceCell" titleAry:self.dataArr[indexPath.section][2][indexPath.row]];
        cell.traderCellClicKBlock = ^(NSString *link) {
            [weakSelf pushWebViewVc:link];
        };
        return cell;
    }else{
        ClassifyBottomCell *classifyCell = [ClassifyBottomCell cellWithTableView:tableView reuseIdentifier:@"ClassifyBottomCell" imageAry:self.dataArr[indexPath.section][2]];
        classifyCell.classifyCellClicKBlock = ^(NSString *link) {
            [weakSelf pushWebViewVc:link];
        };
        return classifyCell;
    }
}

- (void)pushWebViewVc:(NSString *)link{
    
    [[TabManager sharedInstance] setMultiWebViewOperationBlockWith:^(NSArray<WebModel *> *array) {
        NSMutableArray *dataArray = [NSMutableArray arrayWithArray:array];
        
        WebModel *model = array.lastObject;
        model.isNewWebView = NO;
        [dataArray replaceObjectAtIndex:dataArray.count - 1 withObject:model];
        
        [[TabManager sharedInstance] updateWebModelArray:dataArray completion:^{
            BrowserViewController *vc = [BrowserViewController new];
            
            vc.url = link;
            vc.fromVCComeInKind = FromVCComeInKindROOTVC;
            [self.navigationController pushViewController:vc animated:NO];
            [[DelegateManager sharedInstance] performSelector:@selector(browserContainerViewLoadWebViewWithSug:) arguments:@[link] key:DelegateManagerBrowserContainerLoadURL];
            
        }];
        
    }];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


    
}

- (void)initializeView{
    self.bottomToolBar = ({
        BrowserBottomToolBar *toolBar = [[BrowserBottomToolBar alloc] initWithFrame:CGRectMake(0, self.view.height - BOTTOM_TOOL_BAR_HEIGHT, self.view.width, BOTTOM_TOOL_BAR_HEIGHT)];
        toolBar.fromVCComeInKind = 0;
        [self.view addSubview:toolBar];
        
        toolBar.browserButtonDelegate = self;
        
        toolBar;
    });
}


#pragma mark - BrowserBottomToolBarButtonClickedDelegate

- (void)browserBottomToolBarButtonClickedWithTag:(BottomToolBarButtonTag)tag{
    WS(weakSelf);
    
    if ([self.browserButtonDelegate respondsToSelector:@selector(browserBottomToolBarButtonClickedWithTag:)]) {
        [self.browserButtonDelegate browserBottomToolBarButtonClickedWithTag:tag];
    }
    
    if (tag == BottomToolBarMoreButtonTag) {
        [MoreSettingView showInsertionViewSuccessBlock:^{
            
        } clickBlock:^{
            
        } removeBlock:^{
            
        } btnClickBlock:^(NSInteger index) {
            [weakSelf moreSettingClick:index];
        }];
    }
    
    if (tag == BottomToolBarMultiWindowButtonTag) {
        CardMainView *cardMainView = [[CardMainView alloc] initWithFrame:self.view.bounds];
        cardMainView.isFirstVC = YES;
        
        cardMainView.block = ^(WebModel *model) {
            
        };
        
        [cardMainView reloadCardMainViewWithCompletionBlock:^(WebModel *model){
            UIImage *image = [self.view snapshot];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = cardMainView.bounds;
            [cardMainView addSubview:imageView];
            [self.view addSubview:cardMainView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imageView removeFromSuperview];
                [cardMainView changeCollectionViewLayout];
            });
        }];
    }
}

#pragma mark - UIScrollViewDelegate Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (![PreferenceHelper boolForKey:KeyFullScreenModeStatus]) {
        self.tableView.mj_h = SCREENHEIGHT - BOTTOM_TOOL_BAR_HEIGHT;
        return;
    }
    self.tableView.mj_h = SCREENHEIGHT;
    if (scrollView.contentOffset.y > self.oldOffset && scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.mj_h)) {//向上滑动
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.bottomToolBar.mj_y = self.view.mj_h;
        }];
        
    }else if (scrollView.contentOffset.y < self.oldOffset && scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y < scrollView.contentSize.height - scrollView.mj_h)){//向上滑动
        [UIView animateWithDuration:0.5 animations:^{
            
            self.bottomToolBar.mj_y = self.view.height - BOTTOM_TOOL_BAR_HEIGHT;
        }];
    }
    self.oldOffset = scrollView.contentOffset.y;
}

- (void)addBookmark{
    
}

#pragma mark - Dealloc Method

- (void)dealloc{
    [Notifier removeObserver:self];
}

@end


