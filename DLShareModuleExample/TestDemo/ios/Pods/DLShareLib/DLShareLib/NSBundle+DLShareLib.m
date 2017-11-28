//
//  NSBundle+DLShareLib.m
//  DLShareLib
//
//  Created by yjj on 2017/6/29.
//  Copyright © 2017年 com.ecool. All rights reserved.
//

#import "NSBundle+DLShareLib.h"

@implementation NSBundle (DLShareLib)

+ (instancetype)dl_shareLibBundle {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSBundle *podBudle = [NSBundle bundleForClass:NSClassFromString(@"DLShareView")];
        NSString *bundlePath = [podBudle pathForResource:@"DLShareLib" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

+ (NSString *)dl_shareLocalizedStringForKey:(NSString *)key value:(NSString *)value {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else {
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle dl_shareLibBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
