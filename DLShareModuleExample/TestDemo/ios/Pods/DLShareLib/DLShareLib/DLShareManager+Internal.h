//
//  DLShareManager+Internal.h
//  DLShareLib
//
//  Created by yjj on 2017/8/30.
//  Copyright © 2017年 com.ecool. All rights reserved.
//

#import <DLShareLib/DLShareLib.h>

@interface DLShareManager (Internal)

/**
 *  检测qq分享请求
 */
- (void)handleSendResult:(int)sendResult;


/**
 系统分享回调处理

 @param activityType 分享类型
 @param compelete    是否成功
 @param error        错误信息
 */
- (void)handleSystemResultWithActivityType:(UIActivityType)activityType compelete:(BOOL)compelete error:(NSError *)error;


/**
 显示错误信息

 @param message 信息
 @param callBack 回调
 */
- (void)showAlerWithMessage:(NSString *)message callBack:(void(^)(void))callBack;


/**
 获取当前Window显示的控制器
 */
- (UIViewController *)dl_visibleViewController:(UIWindow *)window;

@end
