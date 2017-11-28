//
//  DLShareManager.h
//  DLShareLib
//
//  Created by yjj on 2017/6/28.
//  Copyright © 2017年 com.ecool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLShareViewConfigure.h"

extern NSString *const DLShareErrorDomain;

/**
 分享类型

 - DLShareLibShareTypeWeChat: 微信
 - DLShareLibShareTypeQQ:     QQ
 - DLShareLibShareTypeSystem: 系统
 */
typedef NS_ENUM(NSUInteger, DLShareLibShareType) {
    DLShareLibShareTypeWeChat = 0,
    DLShareLibShareTypeQQ     = 1,
    DLShareLibShareTypeSystem = 2
};

@protocol DLShareManagerDelegate <NSObject>

@optional

/**
 分享成功
 */
- (void)shareDidSuccessWithShareType:(DLShareLibShareType)shareType systemShareType:(UIActivityType)activityType;

/**
 分享失败

 @param shareType 分享的类型
 @param activityType 如果分享的类型是系统的话需要判断
 @param error 错误信息
 */
- (void)shareDidFailureWithShareType:(DLShareLibShareType)shareType systemShareType:(UIActivityType)activityType error:(NSError *)error;

@end

@interface DLShareManager : NSObject

+ (instancetype)sharedInstance;

/**
 配置的key
 */
@property (nonatomic, strong) DLShareViewConfigure *config;

/**
 Delegate
 */
@property (nonatomic, weak) id<DLShareManagerDelegate> delegate;

/**
 处理openUrl事件

 @param url url
 @return bool
 */
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 QQ是否已经安装
 */
+ (BOOL)isQQAppInstalled;

/**
 微信是否已经安装
 */
+ (BOOL)isWechatAppInstalled;

@end
