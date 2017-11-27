//
//  DLShareSingleItem.m
//  ReactDemo05
//
//  Created by sml2 on 2017/11/24.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "DLShareSingleItem.h"

@interface DLShareSingleItem ()

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSURL *url;

@end
@implementation DLShareSingleItem

- (instancetype)initWithImage:(UIImage*)image url:(NSURL*)url {
  self = [super init];
  if (self) {
    _image = image;
    _url = url;
  }
  return self;
}

- (instancetype)init {
  return nil;
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
  return _image;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
  return _url;
}

- (NSString*)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
  // 这里对我这分享图好像暂时没啥用....
  return @"";
}

@end
