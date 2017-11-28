//
//  DLShareManager.m
//  DLShareLib
//
//  Created by yjj on 2017/6/28.
//  Copyright © 2017年 com.ecool. All rights reserved.
//

#import "DLShareManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApiManager.h"
#import "WXApi.h"
#import "NSBundle+DLShareLib.h"
#import "DLShareManager+Internal.h"

NSString *const DLShareErrorDomain = @"DLShareErrorDomain";

@interface DLShareManager() <WXApiManagerDelegate>

@end

@implementation DLShareManager

+ (instancetype)sharedInstance {
    static DLShareManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 设置初始化信息
        [[WXApiManager sharedManager] setDelegate:self];
    }
    return self;
}

#pragma mark -  WXApiManagerDelegate


/**
 请求授权

 @param response 授权结果
 */
- (void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    if (response.errStr && response.errStr.length > 0) {
        if ([self.delegate respondsToSelector:@selector(shareDidFailureWithShareType:systemShareType:error:)]) {
            // 返回错误信息
            NSError *error = [NSError errorWithDomain:DLShareErrorDomain code:response.errCode userInfo:@{ @"name" : response.errStr}];
            [self.delegate shareDidFailureWithShareType:DLShareLibShareTypeWeChat systemShareType:@"-1" error:error];
        }else {
            // 显示错误信息
            [self showAlerWithMessage:response.errStr ?:DLShareLocalizedString(@"授权失败") callBack:nil];
        }
    }else {
        // 授权成功
    }
}

/**
 分享内容

 @param response 分享结果
 */
- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response {
    if (response.errStr && response.errStr.length > 0) {
        if ([self.delegate respondsToSelector:@selector(shareDidFailureWithShareType:systemShareType:error:)]) {
            // 返回错误信息
            NSError *error = [NSError errorWithDomain:DLShareErrorDomain code:response.errCode userInfo:@{ @"name" : response.errStr}];
            [self.delegate shareDidFailureWithShareType:DLShareLibShareTypeWeChat systemShareType:@"-1" error:error];
        }else {
            // 显示错误信息
            [self showAlerWithMessage:response.errStr ?:DLShareLocalizedString(@"分享失败") callBack:nil];
        }
    }else {
        // 授权成功
        if ([self.delegate respondsToSelector:@selector(shareDidSuccessWithShareType:systemShareType:)]) {
            [self.delegate shareDidSuccessWithShareType:DLShareLibShareTypeWeChat systemShareType:@"-1"];
        }
    }
}

#pragma mark - Public

- (BOOL)handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]] || [TencentOAuth HandleOpenURL:url];
}

+ (BOOL)isQQAppInstalled {
    return [QQApiInterface isQQInstalled];
}

+ (BOOL)isWechatAppInstalled {
    return [WXApi isWXAppInstalled];
}

#pragma mark - private

/**
 系统分享回调处理
 
 @param activityType 分享类型
 @param compelete    是否成功
 @param error        错误信息
 */
- (void)handleSystemResultWithActivityType:(UIActivityType)activityType compelete:(BOOL)compelete error:(NSError *)error {
    if (compelete == NO && error != nil) {
        if ([self.delegate respondsToSelector:@selector(shareDidFailureWithShareType:systemShareType:error:)]) {
            // 返回错误信息
            NSError *shareError = [NSError errorWithDomain:DLShareErrorDomain code:error.code userInfo:@{ @"name" : error.localizedDescription?:DLShareLocalizedString(@"分享失败") }];
            [self.delegate shareDidFailureWithShareType:DLShareLibShareTypeSystem systemShareType:activityType error:shareError];
        }else {
            // 显示错误信息
            [self showAlerWithMessage:error.localizedDescription?:DLShareLocalizedString(@"分享失败") callBack:nil];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(shareDidSuccessWithShareType:systemShareType:)]) {
            [self.delegate shareDidSuccessWithShareType:DLShareLibShareTypeSystem systemShareType:activityType];
        }
    }
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    NSString *errorInfo = nil;
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            errorInfo = DLShareLocalizedString(@"App未注册");
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            errorInfo = DLShareLocalizedString(@"发送参数错误");
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            errorInfo = DLShareLocalizedString(@"未安装手Q");
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            errorInfo = DLShareLocalizedString(@"API接口不支持");
            break;
        }
        case EQQAPISENDFAILD:
        {
            errorInfo = DLShareLocalizedString(@"发送失败");
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:
        {
            errorInfo = DLShareLocalizedString(@"当前QQ版本太低，需要更新");
            break;
        }
        case EQQAPISENDSUCESS:
        {
            break;
        }

        default:
        {
            errorInfo = DLShareLocalizedString(@"未知错误");
            break;
        }
    }
    // 有错误
    if (sendResult != EQQAPISENDSUCESS) {
        if ([self.delegate respondsToSelector:@selector(shareDidFailureWithShareType:systemShareType:error:)]) {
            // 返回错误信息
            NSError *error = [NSError errorWithDomain:DLShareErrorDomain code:sendResult userInfo:@{ @"name" : errorInfo }];
            [self.delegate shareDidFailureWithShareType:DLShareLibShareTypeQQ systemShareType:@"-1" error:error];
        }else {
            // 显示错误信息
            [self showAlerWithMessage:errorInfo callBack:nil];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(shareDidSuccessWithShareType:systemShareType:)]) {
            [self.delegate shareDidSuccessWithShareType:DLShareLibShareTypeQQ systemShareType:@"-1"];
        }
    }
}

#pragma mark - Internal Helpers

- (UIViewController *)dl_visibleViewController:(UIWindow *)window {
    UIViewController *rootViewController = window.rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

- (void)showAlerWithMessage:(NSString *)message callBack:(void(^)(void))callBack {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:DLShareLocalizedString(@"提醒信息") message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:DLShareLocalizedString(@"确认") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (callBack) {
                callBack();
            }
        }];
        [alert addAction:action];
        
        UIViewController *visibleController = [self dl_visibleViewController:[UIApplication sharedApplication].delegate.window];
        [visibleController presentViewController:alert animated:YES completion:nil];
    });
}


@end
