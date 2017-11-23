//
//  YJHelp.h
//  CnInsure
//
//  Created by yaojing on 16/4/9.
//  Copyright © 2016年 cousy. All rights reserved.
//
typedef void(^refreshBlock)();
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YJHelp : NSObject



+ (instancetype)shareHelp;

#pragma mark - 字符串不同位置显示不同的颜色 二三段式
+ (NSMutableAttributedString *)textDifferentColor:(NSString *)textStr otherStr:(NSString *)otherStr rgbColor:(UIColor *)rgbColor otherRgbColor:(UIColor *)otherRgbColor;

#pragma mark - 升级版字符串不同位置显示不同属性 二三段式
+ (NSMutableAttributedString *)textDifferentColor:(NSString *)textStr dict:(NSDictionary *)dict otherStr:(NSString *)otherStr otherDict:(NSDictionary *)otherDict;


#pragma mark - label自适应高度
+ (NSAttributedString *) attributedMessageWithString:(NSString *)message
                             constraintWithCellWidth:(CGFloat)cellWidth
                                         lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font;

+ (NSInteger)heightForAttributeString:(NSAttributedString *)attributeString constraintWithCellWidth:(CGFloat)cellWidth;

+ (NSInteger)heightForText:(NSString *)string constrainWithCellWidth:(CGFloat)cellWidth  textAttribute:(NSDictionary *)attributeDic;


#pragma mark -根据身份证获取性别
+ (NSString *)getIdentityCardSex:(NSString *)numberStr;

#pragma mark -根据身份证获取出生日期
+ (NSString *)birthdayStrFromIdentityCard:(NSString *)numberStr;

#pragma mark -获取明天的日期
+ (NSDate *)GetTomorrowDay:(NSDate *)aDate;

#pragma mark -比较两天的日期大小
+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;

#pragma mark -时间的年月日加减
+ (NSString*)getDate:(int)year month:(int)month day:(int)day selecterDate:(NSDate *)selecterDate;

#pragma mark -创建无frameLabel
+ (UILabel*)createLabelWithTitle:(NSString *)title showPlaceStyle:(NSTextAlignment)showPlaceStyle textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textFontNumber:(UIFont *)textFontNumber;

#pragma mark -创建label
+(UILabel*) createLabelWithFrame:(CGRect)frame title:(NSString *)title showPlaceStyle:(NSTextAlignment)showPlaceStyle textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textFontNumber:(CGFloat)textFontNumber;
//手势label
+ (UILabel*) createLabelWithTgrTarget:(id)target Selector:(SEL)selector Frame:(CGRect)frame title:(NSString *)title showPlaceStyle:(NSTextAlignment)showPlaceStyle textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textFontNumber:(CGFloat)textFontNumber;

#pragma mark -创建button
+ (UIButton*) createButtonWithFrame:(CGRect)frame Target:(id)target Selector:(SEL)selector title:(NSString *)title selectedTitle:(NSString *)selectedTitle backgroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor numberFot:(NSInteger)numberFot normalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName;
+(UIButton*) createButtonWithFrame:(CGRect)frame Target:(id)target Selector:(SEL)selector title:(NSString *)title selectedTitle:(NSString *)selectedTitle backgroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor numberFont:(CGFloat)numberFot;
+(UIButton*) createButtonWithFrame:(CGRect)frame Target:(id)target Selector:(SEL)selector Image:(NSString*)image ImagePressed:(NSString*)imagePressed;
+(UIButton*) createButtonWithFrame:(CGRect)frame Title:(NSString*)title titleColor:(UIColor*)titleColor Target:(id)target Selector:(SEL)selector;
+(UIButton*) createButtonWithFrame:(CGRect)frame Title:(NSString*)title imageStr:(NSString *)imageStr numberFont:(CGFloat)numberFot;

+ (UIButton*) createButtonWithTitle:(NSString*)title titleColor:(UIColor*)titleColor Target:(id)target Selector:(SEL)selector;


#pragma - mark -提示框
+ (void)alertViewShowWithMessage:(NSString *)message;

#pragma - mark －时间戳转化

+(NSString *)getTimeWith:(NSString *)str;

+ (NSDate *)getDateTimeWith:(NSString *)str;

#pragma - mark －获取现在特定时间格式的时间字符串
+ (NSString *)getCurrentTimeStr:(NSString *)timeSty;

#pragma - mark －获取今天是星期几
+ (NSString*)weekdayStringFromDate;

#pragma - mark －获取今天是否为工作日
+ (BOOL)isWorkDay;

#pragma - mark -获取服务器时间并得到有效时间距当前服务器时间的差值
+ (NSString *)getStrWithEndTime:(NSString *)endTimeStr currentTime:(NSString *)currentTime;

+ (NSString *)getJustTimeStrWith:(NSString *)createTimeStr;

#pragma - mark -各种加密
//sha1加密
+(NSString *)getSha1String:(NSString *)srcString;
//MD5字符串加密
+ (NSString *)getMD5String:(NSString *)srcString;
//MD5data加密
+(NSString *)getMD5Data:(NSData *)srcData;
//base64加密
+ (NSString *)base64EncodingWithData:(NSData *)sourceData;
//base64解密
+(id)base64EncodingWithString:(NSString *)sourceString;

#pragma - mark -获取AFN错误code码

+(id)codeWithError:(NSError *)error;

#pragma - mark -倒计时
+ (NSString *)lessSecondToDay:(NSUInteger)seconds;

#pragma - mark -距离现在的时间戳
+ (NSTimeInterval)timeStrToNow:(NSString *)startime;

#pragma - mark -空字符串的统一处理
+ (NSString *)replaceNullValue:(NSString *)string;

#pragma - mark -空字符串是否全部为数字字符
+ (BOOL)isPureNumandCharacters:(NSString *)string;

#pragma - mark -去掉字符串中的空格
+ (NSString *)deleateWhitespaceCharacter:(NSString *)string;

#pragma - mark -生成二维码
+ (UIImage *)yjGenerateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height fileName:(NSString *)fileName;


//－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－收藏－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－//

#pragma mark -  json转换
+(id )getObjectFromJsonString:(NSString *)jsonString;
+(NSString *)getJsonStringFromObject:(id)object;

#pragma mark -  NSDate互转NSString
+(NSDate *)NSStringToDate:(NSString *)dateString;
+(NSDate *)NSStringToDate:(NSString *)dateString withFormat:(NSString *)formatestr;
+(NSString *)NSDateToString:(NSDate *)dateFromString withFormat:(NSString *)formatestr;

#pragma mark -  判断字符串是否为空,为空的话返回 “” （一般用于保存字典时）
+(NSString *)IsNotNull:(id)string;
+(BOOL) isBlankString:(id)string;

#pragma mark-为空判断
+ (BOOL)noNullValue:(id)string;

#pragma mark - 如何通过一个整型的变量来控制数值保留的小数点位数。以往我们通类似@"%.2f"来指定保留2位小数位，现在我想通过一个变量来控制保留的位数
+(NSString *)newFloat:(float)value withNumber:(int)numberOfPlace;


#pragma mark - 使用subString去除float后面无效的0
+(NSString *)changeFloatWithString:(NSString *)stringFloat;

#pragma mark - 去除float后面无效的0
+(NSString *)changeFloatWithFloat:(CGFloat)floatValue;


#pragma mark -  手机号码验证
+(BOOL) isValidateMobile:(NSString *)mobile;

#pragma mark -  阿里云压缩图片
+(NSURL*)UrlWithStringForImage:(NSString*)string;
+(NSString*)removeYaSuoAttribute:(NSString*)string;

#pragma mark - 字符串类型判断
+ (BOOL)isPureInt:(NSString*)string;
+ (BOOL)isPureFloat:(NSString*)string;

#pragma mark -  计算内容文本的高度方法
+ (CGFloat)HeightForText:(NSString *)text withSizeOfLabelFont:(UIFont *)font withWidthOfContent:(CGFloat)contentWidth;

#pragma mark -  计算字符串长度
+ (CGFloat)WidthForString:(NSString *)text withSizeOfFont:(CGFloat)font;


#pragma mark -  计算两个时间相差多少秒

+(NSInteger)getSecondsWithBeginDate:(NSString*)currentDateString  AndEndDate:(NSString*)tomDateString;

#pragma mark - 根据出生日期获取年龄
+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;

#pragma mark - 根据经纬度计算两个位置之间的距离
+(double)distanceBetweenOrderBylat1:(double)lat1 lat2:(double)lat2 lng1:(double)lng1 lng2:(double)lng2;
#pragma mark -  计算后台时间和当前时间的大小

+(int)compareDate:(NSString*)date01;

#pragma mark -  比较两个时间的大小
+ (int)compareDate:(NSString*)date01 withDate:(NSString*)date02;

#pragma mark-修改图片大小和控件一致
- (UIImage *)scaleImageToSize:(UIImage *)img size:(CGSize)size;

+ (NSString *)getYiOrWang:(NSString *)str;

#pragma mark-wang
+ (NSString *)getWang:(NSString *)str;

+ (NSString *)roundFloat:(NSString *)price;

#pragma mark-判断现在是不是在今天的某个时间段
+ (BOOL)stockShouldRefresh;

#pragma mark-刷新单行cell
+ (void)reloadRowAtIndexPath:(UITableView *)tableView Row:(NSInteger)row inSection:(NSInteger)section;

#pragma mark-刷新单组cell
+ (void)reloadRowAtIndexPath:(UITableView *)tableView inSection:(NSInteger)section;

#pragma mark-加阴影
+ (void)addshadow:(UIView *)view;

#pragma mark-网络标签分组
+ (NSString *)getZZwithString:(NSString *)string;

#pragma mark-去除网络标签
+ (NSString *)getStringDelectHtmlMark:(NSString *)string;


#pragma mark-去除字符串特殊字符
+ (NSString *)stringDeleteString:(NSString *)str;

#pragma mark-去除换行和空格
+ (NSString *)rnstringDeleteString:(NSString *)str;

#pragma mark-view加边框
+ (void)addBorderSide:(UIView *)view borderWidth:(CGFloat)borderWidth borderColor:(NSString *)colorStr;

#pragma mark-生成渐变色图片
+ (UIImage *)addGradientColor:(NSArray *)colorArray view:(UIView *)view;

#pragma mark-对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

#pragma mark-靠下提示框
+ (void)showHUDbottomtitle:(NSString *)title;

#pragma mark-居中提示框
//贝塞尔画线
+ (void)showHUDcentertitle:(NSString *)title;
+(void)drewLineWithStartPoint:(CGPoint)startPoint AndEndPoint:(CGPoint)endPoint AndLineColor:(UIColor *)LineColor AndLineWidth:(CGFloat)lineWidth toView:(UIView *)view;

#pragma mark-特殊字符转码
+ (NSString *)URLEncode:(NSString *)string;

#pragma mark-画虚线

+ (void)drawDashLine:(UIView *)lineView AndlineColor:(UIColor *)lineColor;


#pragma mark-设置图片size最大值 按照原图比例压缩
+ (CGSize)scaleImageToSize:(UIImage *)img size:(CGSize)size;
+ (CGSize)yuanTuscaleImageToSize:(UIImage *)image size:(CGSize)size;

#pragma mark-生成数组测试数据
+ (NSMutableArray *)randomTestText;

#pragma mark-判断时间戳是否为今天不是今天显示时分是今天现实日时分
+ (NSString *)timeStringWithTimeInterval:(NSString *)timeInterval;
+ (BOOL)isToday:(NSDate *)data;



#pragma mark-添加灰线
+ (UIView *)addLiveViewTo:(UIView *)superView frame:(CGRect)frame;

#pragma mark-默认tableView类型 组头不停留
+ (void)tableViewHaderrNostop:(CGFloat)headerViewH scrollView:(UIScrollView *)scrollView;
#pragma mark-时间戳转日月

+ (NSString *)getDayAndMonthWithTimeInterval:(NSString *)timeInterval;
@end
