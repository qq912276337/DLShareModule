//
//  DLShareViewData.h
//  PocketSLH
//
//  Created by apple on 16/8/3.
//
//

#import <UIKit/UIKit.h>
@class WBMessageObject;

typedef NS_ENUM (NSUInteger ,DLShareType) {
    DLShareText,
    DLShareImage,
    DLShareURL,
    DLShareAudio,
    DLShareVideo,
    DLShareFile
};

@interface DLShareViewData : NSObject

/** 分享text */
@property (nonatomic ,copy  ) NSString         *shareText;
/** 分享image */
@property (nonatomic ,strong) UIImage          *shareImage;
/** 分享thumbImage */
@property (nonatomic ,strong) UIImage          *shareThumbImage;
/** 分享title */
@property (nonatomic ,copy  ) NSString         *shareTitle;
/** 分享description */
@property (nonatomic ,copy  ) NSString         *shareDescription;
/** 分享url */
@property (nonatomic ,copy  ) NSString         *shareURL;
/** 分享音乐dataUrl */
@property (nonatomic ,copy  ) NSString         *shareDataURL;
/** 分享数据data */
@property (nonatomic ,copy  ) NSData           *shareFileData;
/** 分享数据扩展 */
@property (nonatomic ,copy  ) NSString         *shareFileExtension;

@property (nonatomic, strong) NSURL *fileURL;

/** 分享类型 */
@property (nonatomic ,assign) DLShareType      shareType;

/**
 *  分享文字数据
 *
 *  @param text 文字
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithText:(NSString *)text;
/**
 *  分享图片数据
 *
 *  @param image      图片
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithImage:(UIImage *)image thumbImage:(UIImage *)thumbImage;
/**
 *  分享url数据
 *
 *  @param url        url
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithURL:(NSString *)url thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description;
/**
 *  分享音乐
 *
 *  @param url        音乐url
 *  @param dataUrl    音乐数据url
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithURL:(NSString *)url dataURL:(NSString *)dataUrl thumbImage:(UIImage *)thumbImage;
/**
 *  分享视频数据
 *
 *  @param url        视频url
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithVideoURL:(NSString *)url thumbImage:(UIImage *)thumbImage;
/**
 *  分享filedata数据
 *
 *  @param data      data数据
 *  @param extension 文件类型
 *  @param title     标题
 */
- (instancetype)initWithData:(NSData *)data Extension:(NSString *)extension title:(NSString *)title;

/**
 *  分享filedata数据
 *
 *  @param fileURL
 *  @param extension 文件类型
 *  @param title     标题
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL Extension:(NSString *)extension title:(NSString *)title
;

/**
 *  微博分享内容
 *
 *  @return 微博消息对象
 */
- (WBMessageObject *)weiboMessage;
@end
