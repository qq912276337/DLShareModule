//
//  DLShareSingleItem.h
//  ReactDemo05
//
//  Created by sml2 on 2017/11/24.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLShareSingleItem : NSObject

/** 序号 */
@property (nonatomic, assign) NSUInteger order;

- (instancetype)initWithImage:(UIImage*)image url:(NSURL*)url;

@end
