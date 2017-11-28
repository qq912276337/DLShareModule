//
//  DLShareView.h
//  PocketSLH
//
//  Created by apple on 16/7/20.
//
//

#import <UIKit/UIKit.h>

@interface DLShareView : UIView

@property (nonatomic, strong) UIViewController *presentingController;

@property (nonatomic, strong) UIView *superView;

/**
 iPad展示UIActivityViewController
 */
@property (nonatomic, strong) UIBarButtonItem *sourceItem;

/** 标题 */
@property (nonatomic ,strong) NSString *shareTitle;
/** 描述 */
@property (nonatomic ,strong) NSString *shareDescription;

/**
 *  注册第三方分享
 */
+ (void)registerApp;
/**
 *  分享纯文字
 *
 *  @param text        分享内容
 *
 *  @return shareView
 */
+ (void)showWithText:(NSString *)text;
/**
 *  分享图片
 *
 *  @param image 图片对象
 *
 *  @return shareView对象
 */
+ (void)showWithImage:(UIImage *)image thumbImage:(UIImage *)thumbImage;
/**
 *  分享url
 *
 *  @param url         url
 *  @param thumbImage  缩略图
 *  @param title       标题
 *  @param description 描述
 *
 *  @return shareView对象
 */
+ (void)showWithURL:(NSString *)url thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description;

/**
 *  分享url
 *
 *  @param url         url
 *  @param thumbImage  缩略图
 *  @param title       标题
 *  @param description 描述
 *
 *  @return shareView对象
 */
- (void)showWithURL:(NSString *)url thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description;

/**
 *  分享音乐
 *
 *  @param url         音乐url
 *  @param dataUrl     音乐数据url
 *  @param thumbImage  缩略图
 *  @param title       标题
 *  @param description 描述
 *
 *  @return shareView对象
 */
+ (void)showWithMusicURL:(NSString *)url dataURL:(NSString *)dataUrl thumbImage:(UIImage *)thumbImage;
/**
 *  分享视频
 *
 *  @param url         视频url
 *  @param thumbImage  缩略图
 *  @param title       标题
 *  @param description 描述
 *
 *  @return shareView对象
 */
+ (void)showWithVideoURL:(NSString *)url thumbImage:(UIImage *)thumbImage;

/**
 *  分享data数据
 *
 *  @param data      data数据
 *  @param extension 文件类型pdf等
 *  @param title     标题
 */
+ (void)showWithData:(NSData *)data Extension:(NSString *)extension title:(NSString *)title;

/**
 *  分享data数据
 *
 *  @param data      data数据
 *  @param extension 文件类型pdf等
 *  @param title     标题
 */
- (void)showWithData:(NSData *)data Extension:(NSString *)extension title:(NSString *)title;

/**
 *  分享data数据
 *
 *  @param fileURL
 *  @param extension 文件类型pdf等
 *  @param title     标题
 */
- (void)showWithfileURL:(NSURL *)fileURL Extension:(NSString *)extension title:(NSString *)title;

/**
 *  分享data数据
 *
 *  @param dataURL 文件路径
 *  @param extension 文件类型pdf等
 *  @param title     标题
 *
 *  @author sml
 */
+ (void)showWithDataURL:(NSURL *)dataURL Extension:(NSString *)extension title:(NSString *)title;

/**
 *  隐藏view
 */
- (void)dismiss;

@end
