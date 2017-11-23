 //
//  YJHelp.m
//  CnInsure
//
//  Created by yaojing on 16/4/9.
//  Copyright © 2016年 cousy. All rights reserved.
//

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeigh [UIScreen mainScreen].bounds.size.height

#import "YJHelp.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
@implementation YJHelp
//LoginToken单例
+ (instancetype)shareHelp
{
    static YJHelp *Help = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        Help = [[self alloc] init];
    });
    return Help;
}

#pragma - mark -动态行高
+ (NSAttributedString *) attributedMessageWithString:(NSString *)message
                                constraintWithCellWidth:(CGFloat)cellWidth
                                         lineSpacing:(CGFloat)lineSpacing
                                                font:(UIFont *)font{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    if ([self heightForText:message constrainWithCellWidth:cellWidth textAttribute:@{NSFontAttributeName : font}]> 30) {
        paragraphStyle.lineSpacing = lineSpacing;
    }
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary* attributes = @{NSFontAttributeName : font
                                 , NSParagraphStyleAttributeName : paragraphStyle
                                 };
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:(message.length > 0 ? message : @"") attributes:attributes];
    return attributedString;
}

+ (NSInteger)heightForAttributeString:(NSAttributedString *)attributeString constraintWithCellWidth:(CGFloat)cellWidth{
    if (attributeString.length == 0) return 0.f;
    CGRect frame = [attributeString boundingRectWithSize:CGSizeMake(cellWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading context:nil];
    return ceilf(frame.size.height);
}


+ (NSInteger)heightForText:(NSString *)string constrainWithCellWidth:(CGFloat)cellWidth  textAttribute:(NSDictionary *)attributeDic{
    if (string.length == 0) return 0.f;
    CGRect frame = [string boundingRectWithSize:CGSizeMake(cellWidth, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attributeDic context:nil];
    return ceilf(frame.size.height);
}

//升级版二段式不同颜色的字符串
+ (NSMutableAttributedString *)textDifferentColor:(NSString *)textStr otherStr:(NSString *)otherStr rgbColor:(UIColor *)rgbColor otherRgbColor:(UIColor *)otherRgbColor
{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    NSRange strRange = [textStr rangeOfString:otherStr];
    [attStr addAttribute:NSForegroundColorAttributeName value:rgbColor range:NSMakeRange(0, textStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:otherRgbColor range:strRange];
    return attStr;
}

//升级版字符串不同位置显示不同属性 二三段式
+ (NSMutableAttributedString *)textDifferentColor:(NSString *)textStr dict:(NSDictionary *)dict otherStr:(NSString *)otherStr otherDict:(NSDictionary *)otherDict
{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    NSRange strRange = [textStr rangeOfString:otherStr];
    [attStr addAttributes:dict range:NSMakeRange(0, textStr.length)];
    [attStr addAttributes:otherDict range:strRange];
    return attStr;
}

//黑色
- (NSMutableAttributedString *)blackTextDifferentColor:(NSString *)textStr{
    
    NSArray *textAry = [textStr componentsSeparatedByString:@" "];
    
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:textStr];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#626262"] range:NSMakeRange(0, [textAry[0] length])];
    
    
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@".PingFangSC-Regular" size:15] range:NSMakeRange(0, [textAry[0] length])];
    
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4F4F4F"] range:NSMakeRange([textAry[0] length],[textAry[1] length] + 1)];
    
    return attStr;
}



#pragma mark -根据身份证获取出生日期
+ (NSString *)birthdayStrFromIdentityCard:(NSString *)numberStr
{
    NSMutableString *result = [NSMutableString stringWithCapacity:0];
    NSString *year = nil;
    NSString *month = nil;
    
    BOOL isAllNumber = YES;
    
    NSString *day = nil;
    
    if([numberStr length]<14)
        return result;
    
    //**截取前14位
    NSString *fontNumer = [numberStr substringWithRange:NSMakeRange(0, 13)];
    
    //**检测前14位否全都是数字;
    const char *str = [fontNumer UTF8String];
    const char *p = str;
    while (*p!='\0') {
        if(!(*p>='0'&&*p<='9'))
            isAllNumber = NO;
        p++;
    }
    if(!isAllNumber)
        return result;
    
    year = [numberStr substringWithRange:NSMakeRange(6, 4)];
    month = [numberStr substringWithRange:NSMakeRange(10, 2)];
    day = [numberStr substringWithRange:NSMakeRange(12,2)];
    
    [result appendString:year];
    [result appendString:@"-"];
    [result appendString:month];
    [result appendString:@"-"];
    [result appendString:day];
    return result;
    
}
#pragma mark -根据身份证获取性别
//根据身份证号性别,奇数表示男，偶数表示女
+ (NSString *)getIdentityCardSex:(NSString *)numberStr
{
    
    if ([numberStr length]<16) {
        return nil;
    }
    
    int sexInt=[[numberStr substringWithRange:NSMakeRange(16,1)] intValue];
    
    if(sexInt%2!=0)
    {
        return @"男";
    }
    else
    {
        return @"女";
    }
}

+ (NSDate *)GetTomorrowDay:(NSDate *)aDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:aDate];
    [components setDay:([components day]+1)];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateday = [[NSDateFormatter alloc] init];
    [dateday setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateday stringFromDate:beginningOfWeek];
    return [dateday dateFromString:dateStr];
}

//时间大小的比较
+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
}

//时间加减的计算
+ (NSString*)getDate:(int)year month:(int)month day:(int)day selecterDate:(NSDate *)selecterDate
{
    NSLog(@"self.selecterDate%@", selecterDate);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:year];
    [adcomps setMonth:month];
    [adcomps setDay:day];
    
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:selecterDate options:0];
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setTimeZone:timeZone];
    NSString *dateFromData = [formatter stringFromDate:newdate];
    NSLog(@"dateFromData===%@",dateFromData);
    return dateFromData;
}

#pragma mark -创建button

+ (UIButton*) createButtonWithFrame:(CGRect)frame Target:(id)target Selector:(SEL)selector title:(NSString *)title selectedTitle:(NSString *)selectedTitle backgroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor numberFot:(NSInteger)numberFot normalImageName:(NSString *)normalImageName selectedImageName:(NSString *)selectedImageName
{
    UIButton* button = [self createButtonWithFrame:frame Target:target Selector:selector title:title selectedTitle:(NSString *)selectedTitle backgroundColor:backgroundColor titleColor:titleColor numberFont:numberFot];
    [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
    
    return button;
}


+ (UIButton*) createButtonWithFrame:(CGRect)frame Target:(id)target Selector:(SEL)selector title:(NSString *)title selectedTitle:(NSString *)selectedTitle backgroundColor:(UIColor *)backgroundColor titleColor:(UIColor *)titleColor numberFont:(CGFloat)numberFot
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    button.backgroundColor = backgroundColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:selectedTitle forState:UIControlStateSelected];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateSelected];

    button.titleLabel.font = [UIFont systemFontOfSize:numberFot];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
+ (UIButton*) createButtonWithFrame:(CGRect)frame Target:(id)target Selector:(SEL)selector Image:(NSString*)image ImagePressed:(NSString*)imagePressed
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    UIImage* newImage = [UIImage imageNamed:image];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    UIImage* newPressdImage = [UIImage imageNamed:imagePressed];
    [button setBackgroundImage:newPressdImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
+ (UIButton*) createButtonWithFrame:(CGRect)frame Title:(NSString*)title titleColor:(UIColor*)titleColor Target:(id)target Selector:(SEL)selector
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton*) createButtonWithTitle:(NSString*)title titleColor:(UIColor*)titleColor Target:(id)target Selector:(SEL)selector
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton*) createButtonWithFrame:(CGRect)frame Title:(NSString*)title imageStr:(NSString *)imageStr numberFont:(CGFloat)numberFot
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:numberFot];
    [button setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    return button;
}


#pragma mark -创建label
+ (UILabel*) createLabelWithFrame:(CGRect)frame title:(NSString *)title showPlaceStyle:(NSTextAlignment)showPlaceStyle textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textFontNumber:(CGFloat)textFontNumber
{
    UILabel* label = [[UILabel alloc] init];
    [label setFrame:frame];
    label.backgroundColor = backgroundColor;
    label.textColor = textColor;
    [label setFont:[UIFont systemFontOfSize:textFontNumber]];
    [label setText:title];
    [label setTextAlignment:showPlaceStyle];
    label.numberOfLines = 0;
    
    return label;
}

#pragma mark -创建label
+ (UILabel*)createLabelWithTitle:(NSString *)title showPlaceStyle:(NSTextAlignment)showPlaceStyle textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textFontNumber:(UIFont *)textFontNumber
{
    UILabel* label = [[UILabel alloc] init];
    label.backgroundColor = backgroundColor;
    label.textColor = textColor;
    [label setFont:textFontNumber];
    [label setText:title];
    [label setTextAlignment:showPlaceStyle];
    label.numberOfLines = 0;
    return label;
}
#pragma mark -创建手势label
+ (UILabel*) createLabelWithTgrTarget:(id)target Selector:(SEL)selector Frame:(CGRect)frame title:(NSString *)title showPlaceStyle:(NSTextAlignment)showPlaceStyle textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor textFontNumber:(CGFloat)textFontNumber
{
    
    UILabel *label = [self createLabelWithFrame:frame title:title showPlaceStyle:showPlaceStyle textColor:textColor backgroundColor:backgroundColor textFontNumber:textFontNumber];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:tgr];
    
    return label;
}

//提示信息
+ (void)alertViewShowWithMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark -时间戳转时间
+ (NSString *)getTimeWith:(NSString *)str{
    if (str == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone =[NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    double showTime =[str doubleValue]/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:showTime];
    NSString *configTime = [formatter stringFromDate:date];
    return configTime;
}
+ (NSDate *)getDateTimeWith:(NSString *)str{
    
    if (str == nil) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *timeZone =[NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    double showTime =[str doubleValue]/1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:showTime];
    return date;
}

//获取现在特定时间格式的时间字符串
+ (NSString *)getCurrentTimeStr:(NSString *)timeSty{
      NSDate *currentDate = [NSDate date];//获取当前时间，日期
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:timeSty];
      NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

//获取今天是星期几
+ (NSString*)weekdayStringFromDate{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:currentDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

//获取今天是否为工作日
+ (BOOL)isWorkDay{
    NSArray *weekdays = [NSArray arrayWithObjects:@"星期一", @"星期二", @"星期三", @"星期四", @"星期五", nil];
    NSString *timeStr = [self weekdayStringFromDate];
    if ([weekdays containsObject:timeStr]) {
        return YES;
    }else{
        return NO;
    }
}

//根据时间计算出距离现在多长时间
+ (NSString *)getStrWithEndTime:(NSString *)endTimeStr currentTime:(NSString *)currentTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
  
    NSDate* currentDate = [dateFormatter dateFromString:currentTime];;
    
    
    
    NSTimeInterval time=[currentDate timeIntervalSinceDate:endDate];//间隔的秒数
    
    NSLog(@"-------%f", time);
    
    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    
    NSString *dateContent;
    
    if(month!=0){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",month,@"个月前"];
        
    }else if(days!=0){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",days,@"天前"];
    }else if(hours!=0){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",hours,@"小时前"];
    }else {
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",minute,@"分钟前"];
    }
    return dateContent;
}


+ (NSString *)getJustTimeStrWith:(NSString *)createTimeStr{
    
    NSDate *now=[NSDate date];
    NSDateFormatter *fm=[[NSDateFormatter alloc]init];
    fm.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    fm.dateFormat=@"yyyy-MM-dd HH:mm:ss";
    NSDate *created=[fm dateFromString:[YJHelp getTimeWith:createTimeStr]];
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSCalendarUnit uint=NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *cmp=[calendar components:uint fromDate:created toDate:now options:0];
    if (cmp.year==0) {
        if (cmp.day==1) {
            fm.dateFormat = @"昨天 HH:mm";
            return [fm stringFromDate:created];
        }
        if (cmp.day==0) {
            if (cmp.hour>=1) {
                return [NSString stringWithFormat:@"%d小时前",(int)cmp.hour];
            }
            else if (cmp.minute>=3){
                return [NSString stringWithFormat:@"%d分钟前",(int)cmp.minute];
            }
            else return @"刚刚";
        }
        else{
            fm.dateFormat=@"MM-dd HH:mm";
            return [fm stringFromDate:created];
        }
    }
    else {
        fm.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fm stringFromDate:created];
    }
}




//距离现在的时间戳
+ (NSTimeInterval)timeStrToNow:(NSString *)startime
{
    NSDate *now=[NSDate date];
    NSDate *oldDate = [YJHelp getDateTimeWith:startime];
    NSTimeInterval time = [oldDate timeIntervalSinceDate:now];
    return time;
}

//倒计时
+ (NSString *)lessSecondToDay:(NSUInteger)seconds
{
    NSUInteger day  = (NSUInteger)seconds/(24*3600);
    
    NSUInteger hour = (NSUInteger)(seconds%(24*3600))/3600;
    
    NSUInteger min  = (NSUInteger)(seconds%(3600))/60;
    
    //    NSUInteger second = (NSUInteger)(seconds%60);
    NSString *time;
    if (day == 0 || day == 1) {
        //        time = [NSString stringWithFormat:@"%.2lu时%.2lu钟%.2lu秒",(unsigned long)hour,(unsigned long)min,(unsigned long)second];
        time = [NSString stringWithFormat:@"%.2lu时%.2lu钟",(unsigned long)hour,(unsigned long)min];
    }else{
        //        time = [NSString stringWithFormat:@"%.2lu天%.2lu时%.2lu钟%.2lu秒",(unsigned long)day,(unsigned long)hour,(unsigned long)min,(unsigned long)second];
//        time = [NSString stringWithFormat:@"%.2lu天%.2lu时%.2lu钟",(unsigned long)day,(unsigned long)hour,(unsigned long)min];
        time = [NSString stringWithFormat:@"%.2lu天",(unsigned long)day];
    }
    return time;
}

//sha1加密
+ (NSString *)getSha1String:(NSString *)srcString{
    if(!srcString){
        return nil;
    }
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    return result;
}

//MD5字符串加密
+ (NSString *)getMD5String:(NSString *)srcString
{
    if(!srcString){
        return nil;
    }
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

//MD5data加密
+(NSString *)getMD5Data:(NSData *)srcData{
    if (!srcData) {
        return nil;//判断sourceString如果为空则直接返回nil。
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, srcData.bytes, (CC_LONG)srcData.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
    return  resultString;
}

//base64加密
+ (NSString *)base64EncodingWithData:(NSData *)sourceData{
    if (!sourceData) {//如果sourceData则返回nil，不进行加密。
        return nil;
    }
    NSString *resultString = [sourceData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return resultString;
}

//base64解密
+(id)base64EncodingWithString:(NSString *)sourceString{
    if (!sourceString) {
        return nil;//如果sourceString则返回nil，不进行解密。
    }
    NSData *resultData = [[NSData alloc]initWithBase64EncodedString:sourceString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return resultData;
}

//获取AFN错误json
//+(id)codeWithError:(NSError *)error{
//
//    NSData * data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
//    id json = nil;
//    if (data && (json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil])) {
////        NSUInteger code = [[json objectForKey:@"code"] integerValue];
//        return json;
//    }
//    return json;
//}

//空字符串的统一处理
+ (NSString *)replaceNullValue:(NSString *)string
{
    NSString *newStr = [NSString stringWithFormat:@"%@", string];
    if ([newStr isKindOfClass:[NSNull class]] ||
        newStr == nil ||
        [newStr isEqualToString:@"(null)"] ||
        [newStr isEqualToString:@""] ||
        [newStr isEqualToString:@"null"] ||
        [newStr isEqualToString:@"<null>"]) {
        newStr = @"";
    }
    return newStr;
}

//为空判断
+ (BOOL)noNullValue:(id)string
{
    NSString *newStr = [NSString stringWithFormat:@"%@", string];
    if ([newStr isKindOfClass:[NSNull class]] ||
        newStr == nil ||
        [newStr isEqualToString:@"(null)"] ||
        [newStr isEqualToString:@""] ||
        [newStr isEqualToString:@"null"] ||
        [newStr isEqualToString:@"<null>"]){
        
        newStr = @"";
    }
    if (newStr.length == 0) {
        return NO;
    }else{
        return YES;
    }
}

//判断字符串是不是都是数字
+ (BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if (string.length > 0) {
        return NO;
    }else{
        return YES;
    }
}

//去掉字符串中的空格
+ (NSString *)deleateWhitespaceCharacter:(NSString *)string
{

    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

/**
 *  生成二维码
 *
 *  @param code
 *  @param width
 *  @param height
 *
 *  @return
 */
+ (UIImage *)yjGenerateBarCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height fileName:(NSString *)fileName{
    
    CIImage *qrcodeImage;
    NSData *data = [code dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    qrcodeImage = [filter outputImage];
    
    // 消除模糊
    CGFloat scaleX = width / qrcodeImage.extent.size.width; // extent 返回图片的frame
    CGFloat scaleY = height / qrcodeImage.extent.size.height;
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    
    return [UIImage imageWithCIImage:transformedImage];
}

#pragma mark -  json转换
+(id )getObjectFromJsonString:(NSString *)jsonString
{
    NSError *error = nil;
    if (jsonString) {
        id rev=[NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUnicodeStringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        if (error==nil) {
            return rev;
        }
        else
        {
            return nil;
        }
    }
    return nil;
}

+(NSString *)getJsonStringFromObject:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object])
        
    {
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
        
        
        
        return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    return nil;
}

#pragma mark -  NSDate互转NSString
+(NSDate *)NSStringToDate:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

+(NSDate *)NSStringToDate:(NSString *)dateString withFormat:(NSString *)formatestr{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
}

+(NSString *)NSDateToString:(NSDate *)dateFromString withFormat:(NSString *)formatestr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatestr];
    NSString *strDate = [dateFormatter stringFromDate:dateFromString];
    return strDate;
}

#pragma mark -  判断字符串是否为空,为空的话返回 “” （一般用于保存字典时）
+(NSString *)IsNotNull:(id)string
{
    NSString * str = (NSString*)string;
    if ([self isBlankString:str]){
        string = @"";
    }
    return string;
    
}

//..判断字符串是否为空字符的方法
+(BOOL) isBlankString:(id)string {
    NSString * str = (NSString*)string;
    if ([str isEqualToString:@"(null)"]) {
        return YES;
    }
    if (str == nil || str == NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}


#pragma mark - 使用subString去除float后面无效的0
+(NSString *)changeFloatWithString:(NSString *)stringFloat

{
    const char *floatChars = [stringFloat UTF8String];
    NSUInteger length = [stringFloat length];
    NSUInteger zeroLength = 0;
    NSInteger i = length-1;
    for(; i>=0; i--)
    {
        if(floatChars[i] == '0') {
            zeroLength++;
        } else {
            if(floatChars[i] == '.')
                i--;
            break;
        }
    }
    NSString *returnString;
    if(i == -1) {
        returnString = @"0";
    } else {
        returnString = [stringFloat substringToIndex:i+1];
    }
    return returnString;
}

#pragma mark - 去除float后面无效的0
+(NSString *)changeFloatWithFloat:(CGFloat)floatValue

{
    return [self changeFloatWithString:[NSString stringWithFormat:@"%f",floatValue]];
}

#pragma mark - 如何通过一个整型的变量来控制数值保留的小数点位数。以往我们通类似@"%.2f"来指定保留2位小数位，现在我想通过一个变量来控制保留的位数
+(NSString *)newFloat:(float)value withNumber:(int)numberOfPlace
{
    NSString *formatStr = @"%0.";
    formatStr = [formatStr stringByAppendingFormat:@"%df", numberOfPlace];
    NSLog(@"____%@",formatStr);
    
    formatStr = [NSString stringWithFormat:formatStr, value];
    NSLog(@"____%@",formatStr);
    
    printf("formatStr %s\n", [formatStr UTF8String]);
    return formatStr;
}


#pragma mark -  手机号码验证
+(BOOL) isValidateMobile:(NSString *)mobile
{
    /*
     //手机号以13， 15，18开头，八个 \d 数字字符
     NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
     NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
     return [phoneTest evaluateWithObject:mobile];
     */
    
    NSPredicate* phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"1[34578]([0-9]){9}"];
    
    return [phoneTest evaluateWithObject:mobile];
    
}

#pragma mark -  阿里云压缩图片
+(NSURL*)UrlWithStringForImage:(NSString*)string{
    NSString * str = [NSString stringWithFormat:@"%@@800w_600h_10Q.jpg",string];
    NSLog(@"加载图片地址=%@",str);
    return [NSURL URLWithString:str];
}

//..去掉压缩属性“@800w_600h_10Q.jpg”
+(NSString*)removeYaSuoAttribute:(NSString*)string{
    NSString * str = @"";
    if ([string rangeOfString:@"@"].location != NSNotFound) {
        NSArray * arry = [string componentsSeparatedByString:@"@"];
        str = arry[0];
    }
    return str;
}

#pragma mark - 字符串类型判断
//..判断是否为整形：
+ (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}


#pragma mark -  计算内容文本的高度方法
+ (CGFloat)HeightForText:(NSString *)text withSizeOfLabelFont:(UIFont *)font withWidthOfContent:(CGFloat)contentWidth
{
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize size = CGSizeMake(contentWidth, 2000);
    CGRect frame = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
    return frame.size.height;
}

#pragma mark -  计算字符串长度
+ (CGFloat)WidthForString:(NSString *)text withSizeOfFont:(CGFloat)font
{
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:font]};
    CGSize size = [text sizeWithAttributes:dict];
    return size.width;
}



#pragma mark -  计算两个时间相差多少秒

+(NSInteger)getSecondsWithBeginDate:(NSString*)currentDateString  AndEndDate:(NSString*)tomDateString{
    
    NSDate * currentDate = [YJHelp NSStringToDate:currentDateString withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger currSec = [currentDate timeIntervalSince1970];
    
    NSDate *tomDate = [YJHelp NSStringToDate:tomDateString withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger tomSec = [tomDate timeIntervalSince1970];
    
    NSInteger newSec = tomSec - currSec;
    NSLog(@"相差秒：%ld",(long)newSec);
    return newSec;
}


#pragma mark - 根据出生日期获取年龄
+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
}


#pragma mark - 根据经纬度计算两个位置之间的距离
+(double)distanceBetweenOrderBylat1:(double)lat1 lat2:(double)lat2 lng1:(double)lng1 lng2:(double)lng2{
    double dd = M_PI/180;
    double x1=lat1*dd,x2=lat2*dd;
    double y1=lng1*dd,y2=lng2*dd;
    double R = 6371004;
    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));
    //返回km
    return  distance/1000;
    
    //返回m
    //return   distance;
    
}

+(int)compareDate:(NSString*)date01{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    //前一天
    //    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:currentDate];
    
    NSString *dateString = [df stringFromDate:currentDate];
    
    NSString *subTimeStr = [[dateString componentsSeparatedByString:@" "] firstObject];
    NSString *allTimeStr = [NSString stringWithFormat:@"%@ 09:00:00", subTimeStr];    
    NSDate *dt1 = [[NSDate alloc]init];
    NSDate *dt2 = [[NSDate alloc]init];
    dt1 = [df dateFromString:date01];
    dt2 = [df dateFromString:allTimeStr];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date01比date02小
        case NSOrderedAscending: ci=1;
            break;
            //date01比date02大
        case NSOrderedDescending: ci=-1;
            break;
            //date02=date01
        case NSOrderedSame: ci=0;
            break;
        default: NSLog(@"erorr dates %@, %@", dt2, dt1);break;
    }
    return ci;
}


+ (int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    if (date01.length == 10) {
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    if (date01.length == 16) {
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    if (date01.length == 19) {
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
    if (date02.length == 10) {
        [df2 setDateFormat:@"yyyy-MM-dd"];
    }
    if (date02.length == 16) {
        [df2 setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    if (date02.length == 19) {
        [df2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSDate *dt1 = [[NSDate alloc] init];
    NSDate *dt2 = [[NSDate alloc] init];
    dt1 = [df dateFromString:date01];
    dt2 = [df2 dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
        default: NSLog(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}


#pragma mark-修改图片大小和控件一致
- (UIImage *)scaleImageToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark-yiwang
+ (NSString *)getYiOrWang:(NSString *)str
{
    
    if ([self returnBool:str]) {//zheng
        NSString *newStr = nil;
        CGFloat yiVolume = [str floatValue]/100000000;
        CGFloat wangVolume = [str floatValue]/10000;
        if (yiVolume >1) {
            newStr = [self roundFloat:[NSString stringWithFormat:@"%f", yiVolume]];
            newStr = [NSString stringWithFormat:@"%@亿", newStr];
        }else if (yiVolume < 1 && wangVolume > 1){
            newStr = [self roundFloat:[NSString stringWithFormat:@"%f万", wangVolume]];
            newStr = [NSString stringWithFormat:@"%@万", newStr];
        }else{
            newStr = str;
        }
        return newStr;
    }else{//fu
        NSString *newStr = nil;
        NSString *intStr = [str substringFromIndex:1];
        
        
        CGFloat yiVolume = [intStr floatValue]/100000000;
        CGFloat wangVolume = [intStr floatValue]/10000;
        if (yiVolume >1) {
            newStr = [self roundFloat:[NSString stringWithFormat:@"%f", yiVolume]];
            newStr = [NSString stringWithFormat:@"%@亿", newStr];
        }else if (yiVolume < 1 && wangVolume > 1){
            newStr = [self roundFloat:[NSString stringWithFormat:@"%f万", wangVolume]];
            newStr = [NSString stringWithFormat:@"%@万", newStr];
            
        }else{
            newStr = intStr;
        }
        return [NSString stringWithFormat:@"-%@", newStr];
    }
}

#pragma mark-wang
+ (NSString *)getWang:(NSString *)str
{
    if (str == nil) {
        return nil;
    }
    NSString *newStr = nil;
    CGFloat wangVolume = [str floatValue]/10000;
    newStr = [self roundFloat:[NSString stringWithFormat:@"%f", wangVolume]];
    newStr = [NSString stringWithFormat:@"%@", newStr];
    return newStr;
}

+(BOOL)returnBool:(NSString *)str{
    const char *chars = [str cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (chars[0]=='-') {
        return NO;
    }else{
        return YES;
    }
}


+ (NSString *)roundFloat:(NSString *)price{
    CGFloat fPrice = [price floatValue];
    return [NSString stringWithFormat:@"%.2f",(floorf(fPrice*100 + 0.5))/100];
}

+ (BOOL)stockShouldRefresh
{
    NSDate *dateFrom = [self getCustomDateWithHour:9];
    
    NSDate *dateTo = [self getCustomDateWithHour:15];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:dateFrom]==NSOrderedDescending && [currentDate compare:dateTo]==NSOrderedAscending)
    {
        NSLog(@"该时间在 %d:00-%d:00 之间！", 9, 15);
        return YES;
    }
    
    return NO;
}

+ (NSDate *)getCustomDateWithHour:(NSInteger)hour

{   //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [resultCalendar dateFromComponents:resultComps];
}

#pragma mark-刷新单行cell
+ (void)reloadRowAtIndexPath:(UITableView *)tableView Row:(NSInteger)row inSection:(NSInteger)section{
    NSIndexPath *indexPathA = [NSIndexPath indexPathForRow:row inSection:section]; //刷新第0段第2行
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathA,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark-刷新单组cell
+ (void)reloadRowAtIndexPath:(UITableView *)tableView inSection:(NSInteger)section{
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:section];
    [tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}




+ (void)addshadow:(UIView *)view{
    view.layer.shadowColor = [UIColor colorWithHexString:@"#000000"].CGColor;
    view.layer.shadowOffset = CGSizeMake(0.2, 0.2);
    view.layer.shadowOpacity = 0.5;
}

#pragma mark-去除网络标签
+ (NSString *)getStringDelectHtmlMark:(NSString *)string{

    NSString *content = [NSString stringWithFormat:@" %@ ", string];
    
    NSRegularExpression
    
    *regularExpretion=[NSRegularExpression
                       
                       regularExpressionWithPattern:@"<[^>]*>|\n"
                       
                       
                       options:0
                       
                       
                       error:nil];
    
    
    
    content=[regularExpretion
             
             stringByReplacingMatchesInString:content
             
             options:NSMatchingReportProgress
             
             range:NSMakeRange(0, content.length)
             
             withTemplate:@""];//替换所有html和换行匹配元素为""
    return content;
}

#pragma mark-去除字符串特殊字符
+ (NSString *)stringDeleteString:(NSString *)str
{
    NSMutableString *str1 = [NSMutableString stringWithString:str];
    for (int i = 0; i < str1.length; i++) {
        unichar c = [str1 characterAtIndex:i];
        NSRange range = NSMakeRange(i, 1);
        if (c == '"' || c == '.' || c == ',' || c == '(' || c == ')') { //此处可以是任何字符
            [str1 deleteCharactersInRange:range];
            --i;
        }
    }
    NSString *newstr = [NSString stringWithString:str1];
    return newstr;
}

#pragma mark-去除换行和空格
+ (NSString *)rnstringDeleteString:(NSString *)str
{
    if (str == nil) {
        return nil;
    }
    //1. 去掉首尾空格和换行符
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //2. 去掉所有空格和换行符
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *newstr = [NSString stringWithString:str];
    return newstr;
}

#pragma mark-view加边框
+ (void)addBorderSide:(UIView *)view borderWidth:(CGFloat)borderWidth borderColor:(NSString *)colorStr{
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = [[UIColor colorWithHexString:colorStr] CGColor];
}



#pragma mark-生成渐变色图片
+ (UIImage *)addGradientColor:(NSArray *)colorArray view:(UIView *)view
{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colorArray) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colorArray lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    start = CGPointMake(0.0, 0.0);
    end = CGPointMake(0.0, view.frame.size.height);
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;

}

#pragma mark-对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

//贝塞尔画线 直线
+(void)drewLineWithStartPoint:(CGPoint)startPoint AndEndPoint:(CGPoint)endPoint AndLineColor:(UIColor *)LineColor AndLineWidth:(CGFloat)lineWidth toView:(UIView *)view{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:startPoint];
    [linePath addLineToPoint:endPoint];
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.lineWidth = 0.5f;
    layer.strokeColor = LineColor.CGColor;
    layer.path = linePath.CGPath;
    [view.layer addSublayer:layer];
}

+ (void)drawDashLine:(UIView *)lineView AndlineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:2], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

+ (NSString *)URLEncode:(NSString *)string {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)string,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return encodedString;
}

//设置图片size最大值 按照原图比例压缩
+ (CGSize)scaleImageToSize:(UIImage *)image size:(CGSize)size
{
    NSInteger w = 0;
    NSInteger h = 0;
    
    if (image.size.height>image.size.width) {
            h = size.height;
            w = size.height/image.size.height*image.size.width;
            }else{
            w = size.width;
            h = size.width/image.size.width*image.size.height;
           }
    return CGSizeMake(w+1, h+1);
}

+ (CGSize)yuanTuscaleImageToSize:(UIImage *)image size:(CGSize)size
{
    NSInteger w = 0;
    NSInteger h = 0;
    
    if (image.size.height>image.size.width) {
        if (image.size.height>size.height) {
            h = size.height;
            w = size.height/image.size.height*image.size.width;
        }else {
            h = image.size.height;
            w = image.size.height;
        }
    }else{
        if (image.size.width>size.width) {
            w = size.width;
            h = size.width/image.size.width*image.size.height;
        }else{
            w = image.size.width;
            h = image.size.height;
        }
    }
    return CGSizeMake(w+1, h+1);
}


//生成数组测试数据
+ (NSMutableArray *)randomTestText{
    
    NSMutableArray *testAry = [NSMutableArray new];
    CGFloat arrLength = arc4random() % 5 + 1;

    for (NSUInteger i = 0; i < arrLength; i++) {
        CGFloat length = arc4random() % 5 + 1;
        NSMutableString *str = [[NSMutableString alloc] init];
        for (NSUInteger i = 0; i < length; i++) {
            [str appendString:@"测试"];
        }
        [testAry addObject:str];
    }
    return testAry;
}


//判断时间戳是否为今天不是今天显示时分是今天现实日时分
+ (NSString *)timeStringWithTimeInterval:(NSString *)timeInterval{
    NSTimeInterval time=[timeInterval doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //今天
    if ([self isToday:detaildate]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        
    }else{
        
        [dateFormatter setDateFormat:@"MM-dd"];
    }
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    return currentDateStr;
}
+ (NSString *)getDayAndMonthWithTimeInterval:(NSString *)timeInterval{
    NSTimeInterval time=[timeInterval doubleValue]/1000;//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    return currentDateStr;
}

+ (BOOL)isToday:(NSDate *)data
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得self
    NSDateComponents *selfCmps = [calendar components:unit fromDate:data];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}

#pragma mark-添加灰线
+ (UIView *)addLiveViewTo:(UIView *)superView frame:(CGRect)frame{
    UIView *sendLine = [[UIView alloc] initWithFrame:frame];
    sendLine.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [superView addSubview:sendLine];
    return sendLine;
}

#pragma mark-默认tableView类型 组头不停留
+ (void)tableViewHaderrNostop:(CGFloat)headerViewH scrollView:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = headerViewH;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y> 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }else{
        if(scrollView.contentOffset.y >= sectionHeaderHeight){
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

@end
