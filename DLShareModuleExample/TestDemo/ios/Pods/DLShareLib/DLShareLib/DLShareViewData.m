//
//  DLShareViewData.m
//  PocketSLH
//
//  Created by apple on 16/8/3.
//
//

#import "DLShareViewData.h"

@interface DLShareViewData ()

@end

@implementation DLShareViewData

/**
 *  分享文字数据
 *
 *  @param text 文字
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithText:(NSString *)text
{
    return [self initWithText:text image:nil thumbImage:nil title:nil description:nil url:nil dataURL:nil type:DLShareText];
}
/**
 *  分享图片数据
 *
 *  @param image      图片
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithImage:(UIImage *)image thumbImage:(UIImage *)thumbImage
{
    return [self initWithText:nil image:image thumbImage:thumbImage title:nil description:nil url:nil dataURL:nil type:DLShareImage];
}
/**
 *  分享url数据
 *
 *  @param url        url
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithURL:(NSString *)url thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description
{
    return [self initWithText:nil image:nil thumbImage:thumbImage title:title description:description url:url dataURL:nil type:DLShareURL];
}
/**
 *  分享音乐
 *
 *  @param url        音乐url
 *  @param dataUrl    音乐数据url
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithURL:(NSString *)url dataURL:(NSString *)dataUrl thumbImage:(UIImage *)thumbImage
{
    return [self initWithText:nil image:nil thumbImage:thumbImage title:nil description:nil url:url dataURL:dataUrl type:DLShareAudio];
}
/**
 *  分享视频数据
 *
 *  @param url        视频url
 *  @param thumbImage 缩略图
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithVideoURL:(NSString *)url thumbImage:(UIImage *)thumbImage
{
    return [self initWithText:nil image:nil thumbImage:thumbImage title:nil description:nil url:url dataURL:nil type:DLShareVideo];
}
/**
 *  分享filedata数据
 *
 *  @param data      data数据
 *  @param extension 文件类型
 *  @param title     标题
 */
- (instancetype)initWithData:(NSData *)data Extension:(NSString *)extension title:(NSString *)title
{
    DLShareViewData *shareViewData = [self initWithText:nil image:nil thumbImage:nil title:title description:nil url:nil dataURL:nil type:DLShareFile];
    shareViewData.shareFileData = data;
    shareViewData.shareFileExtension = extension;
    return shareViewData;
}

/**
 *  分享filedata数据
 *
 *  @param fileURL
 *  @param extension 文件类型
 *  @param title     标题
 */
- (instancetype)initWithFileURL:(NSURL *)fileURL Extension:(NSString *)extension title:(NSString *)title
{
    DLShareViewData *shareViewData = [self initWithText:nil image:nil thumbImage:nil title:title description:nil url:nil dataURL:nil type:DLShareFile];
    shareViewData.shareFileData = [NSData dataWithContentsOfURL:fileURL];
    shareViewData.fileURL = fileURL;
    shareViewData.shareFileExtension = extension;
    return shareViewData;
}

/**
 *  初始化分享数据对象
 *
 *  @param text        文字
 *  @param image       图片
 *  @param thumbImage  缩略图
 *  @param title       标题
 *  @param description 描述
 *  @param URL         url
 *  @param dataURL     音乐数据url
 *  @param type        类型
 *
 *  @return 分享数据对象
 */
- (instancetype)initWithText:(NSString *)text image:(UIImage *)image thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description url:(NSString *)URL dataURL:(NSString *)dataURL type:(DLShareType)type
{
    if (self = [super init]) {
        self.shareText = text;
        self.shareImage = image;
        self.shareThumbImage = thumbImage;
        self.shareTitle = title;
        self.shareDescription = description;
        self.shareURL = URL;
        self.shareDataURL = dataURL;
        self.shareType = type;
    }
    return self;
}

@end
