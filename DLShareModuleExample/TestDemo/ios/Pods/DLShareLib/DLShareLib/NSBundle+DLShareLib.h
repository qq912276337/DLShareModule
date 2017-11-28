//
//  NSBundle+DLShareLib.h
//  DLShareLib
//
//  Created by yjj on 2017/6/29.
//  Copyright © 2017年 com.ecool. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DLShareLocalizedString(key) [NSBundle dl_shareLocalizedStringForKey:(key) value:@""]

@interface NSBundle (DLShareLib)

/**
 获取FoundationLib的Bundle
 
 @return Bundle
 */
+ (instancetype)dl_shareLibBundle;


/**
 获取本地化的语言
 
 @param key key
 @return 本地化语音
 */
+ (NSString *)dl_shareLocalizedStringForKey:(NSString *)key value:(NSString *)value;

@end
