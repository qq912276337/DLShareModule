//
//  DLShareModule.m
//  ReactDemo05
//
//  Created by sml2 on 2017/11/15.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "DLShareModule.h"
#import <UIKit/UIKit.h>
#import <DLShareLib/DLShareLib.h>
#import "DLShareSingleItem.h"
#import <SDWebImageManager.h>

#define getNotNilValue(value) ((value) ? (value) : @"")

static NSInteger const kMaxNumberOfItems = 9;

@interface DLShareModule ()<DLShareManagerDelegate>

@property (nonatomic, copy) RCTResponseSenderBlock callback;

@end
@implementation DLShareModule

RCT_EXPORT_MODULE(DLShareModuleIOS);

/**
 * 注册分享模块
 * @param configure 配置AppKey @{@"wexin":@"wechatAppKey",@"qq":@"QQAppKey"}
 * @return
 * @by sml
 */
RCT_EXPORT_METHOD(registerShareModule:(NSDictionary *)configure) {
  //注册第三方分享
  DLShareViewConfigure *shareViewConfigure = [DLShareViewConfigure new];
  shareViewConfigure.wechatAppKey = configure[@"wexin"];
  shareViewConfigure.QQAppKey = configure[@"qq"];
  [[DLShareManager sharedInstance] setConfig:shareViewConfigure];
  [[DLShareManager sharedInstance] setDelegate:self];
  [DLShareView registerApp];
}

/**
 * 分享图片
 * @param imageURL NSString
 * @param callback 回调
 * @return
 * @by sml
 */
RCT_EXPORT_METHOD(shareImageURL:(NSString *)imageURL callback:(RCTResponseSenderBlock )callback){
  self.callback = callback;
  [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imageURL] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
    if (image) {
      [DLShareView showWithImage:image thumbImage:[DLShareModule cutImage:image targetSize:CGSizeMake(200, 200)]];
    } else {
      if (self.callback) {
        self.callback(@[error]);
      }
    }
  }];
}

/**
 * 分享图片
 * @param imageURL NSString
 * @param callback 回调
 * @return
 * @by sml
 */
RCT_EXPORT_METHOD(shareImageURLs:(NSArray *)urls callback:(RCTResponseSenderBlock )callback){
  if (!urls.count) {
    return;
  }
  
  self.callback = callback;
  
//  [DLViewUtility show];
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 1
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:urls.count];
    for (int i = 0; i <urls.count; i++) {
      if (i >= kMaxNumberOfItems) break;
      
      NSURL *URL = urls[i];
      // 2
      dispatch_group_enter(downloadGroup);
      
      [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:URL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        if (image) {
          [items addObject:[DLShareModule itemWithImage:image number:i]];
        }
        // 3
        dispatch_group_leave(downloadGroup);
      }];
    }
    // 4
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{
      [items sortUsingComparator:^NSComparisonResult(DLShareSingleItem *obj1, DLShareSingleItem *obj2) {
        return [@(!(obj1.order < obj2.order)) integerValue];
      }];
//      [DLViewUtility dismiss];
      [weakSelf presentActivityViewControllerWithItems:items callback:callback];
    });
  });
}

/**
 * 分享文字
 * @param text NSString
 * @param callback 回调
 * @return
 * @by sml
 */
RCT_EXPORT_METHOD(shareText:(NSString *)text callback:(RCTResponseSenderBlock )callback){
  self.callback = callback;
  dispatch_async(dispatch_get_main_queue(), ^{
    [DLShareView showWithText:text];
  });
}

/**
 * 分享URL链接
 * @param url NSString
 * @param title 标题
 * @param description 描述
 * @param callback 回调
 * @return
 * @by sml
 */
RCT_EXPORT_METHOD(shareLinkURL:(NSString *)url title:(NSString *)title description:(NSString *)description callback:(RCTResponseSenderBlock )callback){
  self.callback = callback;
  dispatch_async(dispatch_get_main_queue(), ^{
    [DLShareView showWithURL:url thumbImage:[UIImage imageNamed:@""] title:title description:description];
  });
}


#pragma mark - private

/**
 *  用于分享的item
 *
 *  @author sml
 */
+ (DLShareSingleItem *)itemWithImage:(UIImage *)image number:(NSInteger )number {
  NSString *imageName = [NSString stringWithFormat:@"DYZS_ShareWX%ld.jpg",number];
  NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:imageName];
  [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
  NSURL *shareobj = [NSURL fileURLWithPath:imagePath];
  /** image:UIimage;shareobj:NSURL:在吊起微信的分享的时候 传递给他 UIimage对象,在分享的时候 实际传递 NSURL对象 达到我们分享九宫格的目的 */
  DLShareSingleItem *item = [[DLShareSingleItem alloc] initWithImage:image url:shareobj];
  item.order = number;
  return item;
}

/**
 * 弹出系统分享视图
 *
 *  @author sml
 */
- (void)presentActivityViewControllerWithItems:(NSArray *)items callback:(RCTResponseSenderBlock )callback {
  UIActivityViewController *activityViewController =[[UIActivityViewController alloc] initWithActivityItems:items
                                                                                      applicationActivities:nil];
  // 隐藏不需要分享的app通道
  activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
                                                   UIActivityTypePostToTwitter,
                                                   UIActivityTypePostToWeibo,
                                                   UIActivityTypeMessage,
                                                   UIActivityTypeMail,
                                                   UIActivityTypePrint,
                                                   UIActivityTypeCopyToPasteboard,
                                                   UIActivityTypeAssignToContact,
                                                   UIActivityTypeSaveToCameraRoll,
                                                   UIActivityTypeAddToReadingList,
                                                   UIActivityTypePostToFlickr,
                                                   UIActivityTypePostToVimeo,
                                                   UIActivityTypePostToTencentWeibo];
  
  __weak typeof(activityViewController) weakVC = activityViewController;
  activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
    [weakVC dismissViewControllerAnimated:YES completion:nil];
    if (callback) {
      if (completed) {
        callback(@[[NSNull null],getNotNilValue(activityType)]);
      } else{
        callback(@[activityError,getNotNilValue(activityType)]);
      }
    }
  };
  [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

///**
// * 导出常量
// * @by sml
// */
//- (NSDictionary *)constantsToExport {
//  return @{
//           @"weixinKey": @"111",
//           @"weiboKey": @"222",
//           @"qqKey": @"333",
//           };
//}

+ (UIImage *)cutImage:(UIImage *)image targetSize:(CGSize)size {
  int W = size.width;
  int H = size.height;
  
  CGImageRef   imageRef   = image.CGImage;
  CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
  
  
  CGContextRef bitmap = CGBitmapContextCreate(NULL, W, H, 8, 4*W, colorSpaceInfo, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
  
  if(image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight){
    W = size.height;
    H = size.width;
  }
  
  if(image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationLeftMirrored){
    CGContextRotateCTM (bitmap, M_PI/2);
    CGContextTranslateCTM (bitmap, 0, -H);
  }
  else if (image.imageOrientation == UIImageOrientationRight || image.imageOrientation == UIImageOrientationRightMirrored){
    CGContextRotateCTM (bitmap, -M_PI/2);
    CGContextTranslateCTM (bitmap, -W, 0);
  }
  else if (image.imageOrientation == UIImageOrientationUp || image.imageOrientation == UIImageOrientationUpMirrored){
    // Nothing
  }
  else if (image.imageOrientation == UIImageOrientationDown || image.imageOrientation == UIImageOrientationDownMirrored){
    CGContextTranslateCTM (bitmap, W, H);
    CGContextRotateCTM (bitmap, -M_PI);
  }
  
  CGContextDrawImage(bitmap, CGRectMake(0, 0, W, H), imageRef);
  CGImageRef ref = CGBitmapContextCreateImage(bitmap);
  UIImage* newImage = [UIImage imageWithCGImage:ref];
  
  CGContextRelease(bitmap);
  CGImageRelease(ref);
  return newImage;
}




#pragma mark - DLShareManagerDelegate

/**
 分享成功
 */
- (void)shareDidSuccessWithShareType:(DLShareLibShareType)shareType systemShareType:(UIActivityType)activityType {
  if (self.callback) {
    self.callback(@[[NSNull null],@{@"shareType":@(shareType),@"activityType":getNotNilValue(activityType)}]);
  }
}

/**
 分享失败
 
 @param shareType 分享的类型
 @param activityType 如果分享的类型是系统的话需要判断
 @param error 错误信息
 */
- (void)shareDidFailureWithShareType:(DLShareLibShareType)shareType systemShareType:(UIActivityType)activityType error:(NSError *)error {
  if (self.callback) {
    self.callback(@[error,@{@"shareType":@(shareType),@"activityType":getNotNilValue(activityType)}]);
  }
}

@end

