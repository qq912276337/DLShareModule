//
//  DLShareView.m
//  PocketSLH
//
//  Created by apple on 16/7/20.
//
//

#import "DLShareView.h"
#import "DLShareViewConstant.h"
#import "DLShareViewData.h"
#import "DLShareViewCell.h"
#import <objc/runtime.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "DLShareManager.h"
#import "NSBundle+DLShareLib.h"
#import "DLShareManager+Internal.h"
#import <Masonry/Masonry.h>
//@import Masonry;

#define COLOR_RGB_ORANGE 0xff6d4c
#define COLOR_RGB_GRAY   0xeeeeee
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define setupDictValue(dict, key, value) if (key && value) { [dict setValue:value forKey:key];}
#define setupArrayValue(array, object) if (array && object) { [array addObject:object]; }

static NSInteger const kShareViewHeight = 236;
static NSInteger const kCancelButtonHeight = 44;
static CGFloat const kAnimateDuration = .3f;

typedef NS_ENUM (NSUInteger ,DLSharePlatform) {
    DLShareToWechatFriend,
    DLShareToQQFriend,
    DLShareToQQZone,
    DLShareToWechatCircle,
    DLShareToMore
};

static NSString* const KCollectionCellIdentifier = @"DLShareViewCell";

@interface DLShareView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/** 蒙板 */
@property (nonatomic ,strong) UIView           *backView;

/** 分享框（包括取消框） */
@property (nonatomic ,strong) UIView           *shareView;

/** 分享平台view */
@property (nonatomic ,strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton         *cancelButton;

/** 分享数据 */
@property (nonatomic ,strong) DLShareViewData  *shareData;

@end

@implementation DLShareView

#pragma mark - View Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

/**
 *  初始化view
 */
- (instancetype)initWithShareData:(DLShareViewData *)shareData
{
    if (self = [super init]) {
        [self setupData:shareData];
        [self setupView];
    }
    return self;
}
/**
 *  初始化数据
 */
- (void)setupData:(DLShareViewData *)shareData
{
    self.shareData = shareData;
}
/**
 *  初始化视图
 */
- (void)setupView
{
    [self addSubview:self.backView];
    [self addSubview:self.shareView];
    [self.shareView addSubview:self.collectionView];
    UIButton *cancelButton = [self cancelButton];
    self.cancelButton = cancelButton;
    [self.shareView addSubview:cancelButton];
}

- (void)updateShareViewFrame {
    if (_superView) {
        [_superView addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_superView);
        }];
    } else {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(window);
        }];
    }

    [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_shareView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.mas_safeAreaLayoutGuideBottom);
        }else {
            make.bottom.equalTo(self);
        }
        make.height.mas_equalTo(kShareViewHeight);
    }];
    
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(_shareView);
        make.height.mas_equalTo(kShareViewHeight);
    }];
    
    
    [_cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(_shareView);
        make.height.mas_equalTo(kCancelButtonHeight);
    }];
    
//    _backView.frame = self.frame;
//    _backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//    _shareView.frame = CGRectMake(0, self.bounds.size.height - kShareViewHeight, self.bounds.size.width, kShareViewHeight);
//    _shareView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//
//    CGRect collectionFrame = _shareView.bounds;
//    collectionFrame.size.height -= kCancelButtonHeight;
//    _collectionView.frame = collectionFrame;
//    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//
//    _cancelButton.frame = CGRectMake(0, _shareView.bounds.size.height - kCancelButtonHeight, _shareView.bounds.size.width, kCancelButtonHeight);
//    _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - Public Interface
/**
 *  注册第三方分享
 */
+ (void)registerApp
{
    DLShareViewConfigure *configure = [[DLShareManager sharedInstance] config];
    
    //向微信注册
    [WXApi registerApp:configure.wechatAppKey];
    
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    
    [WXApi registerAppSupportContentFlag:typeFlag];
    (void)[[TencentOAuth alloc] initWithAppId:configure.QQAppKey andDelegate:nil];
}
/**
 *  分享纯文字
 *
 *  @param text        分享内容
 *
 *  @return shareView
 */
+ (void)showWithText:(NSString *)text
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithText:text];
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}
/**
 *  分享图片
 *
 *  @param image 图片对象
 *
 *  @return shareView对象
 */
+ (void)showWithImage:(UIImage *)image thumbImage:(UIImage *)thumbImage
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithImage:image thumbImage:thumbImage];
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}
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
+ (void)showWithURL:(NSString *)url thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithURL:url thumbImage:thumbImage title:title description:description];
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}


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
- (void)showWithURL:(NSString *)url thumbImage:(UIImage *)thumbImage title:(NSString *)title description:(NSString *)description
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithURL:url thumbImage:thumbImage title:title description:description];
    [self setupData:shareData];
    [self show];
}

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
+ (void)showWithMusicURL:(NSString *)url dataURL:(NSString *)dataUrl thumbImage:(UIImage *)thumbImage
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithURL:url dataURL:dataUrl thumbImage:thumbImage];
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}
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
+ (void)showWithVideoURL:(NSString *)url thumbImage:(UIImage *)thumbImage
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithVideoURL:url thumbImage:thumbImage];
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}
/**
 *  分享data数据
 *
 *  @param data      data数据
 *  @param extension 文件类型
 *  @param title     标题
 */
+ (void)showWithData:(NSData *)data Extension:(NSString *)extension title:(NSString *)title
{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithData:data Extension:extension title:title];
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}

/**
 *  分享data数据
 *
 *  @param data      data数据
 *  @param extension 文件类型pdf等
 *  @param title     标题
 */
- (void)showWithData:(NSData *)data Extension:(NSString *)extension title:(NSString *)title{
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithData:data Extension:extension title:title];
    [self setupData:shareData];
    [self show];
}

/**
 *  分享data数据
 *
 *  @param fileURL
 *  @param extension 文件类型pdf等
 *  @param title     标题
 */
- (void)showWithfileURL:(NSURL *)fileURL Extension:(NSString *)extension title:(NSString *)title {
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithFileURL:fileURL Extension:extension title:title];
    [self setupData:shareData];
    [self show];
}

/**
 *  分享data数据
 *
 *  @param dataURL 文件路径
 *  @param extension 文件类型pdf等
 *  @param title     标题
 *
 *  @author sml
 */
+ (void)showWithDataURL:(NSURL *)dataURL Extension:(NSString *)extension title:(NSString *)title {
    DLShareViewData *shareData = [[DLShareViewData alloc] initWithData:[NSData dataWithContentsOfURL:dataURL] Extension:extension title:title];
    shareData.fileURL = dataURL;
    DLShareView *shareView = [[self alloc] initWithShareData:shareData];
    [shareView show];
}

#pragma mark - User Interaction

/**
 *  点击分享按钮
 */
- (void)shareToPlatform:(NSUInteger)row
{
    switch (row) {
        case DLShareToWechatFriend://微信好友分享
            [self shareToWechatWithFriend:YES];
            break;
        case DLShareToQQFriend://qq好友分享
            [self shareToQQWithFriend:YES];
            break;
        case DLShareToQQZone://qq空间分享
            [self shareToQQWithFriend:NO];
            break;
        case DLShareToWechatCircle://微信朋友圈分享
            [self shareToWechatWithFriend:NO];
            break;
        case DLShareToMore://调用系统分享
        {
            [self shareWithSystemMethod];
            break;
        }
        default:
            break;
    }
}
/**
 *  点击取消按钮
 */
- (void)cancel
{
    [self dismiss];
}


/**
 *  显示view
 */
- (void)show
{
    [self updateShareViewFrame];
    _shareView.transform = CGAffineTransformMakeTranslation(0, kShareViewHeight);
    [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.backView.alpha = 0.5;
        _shareView.transform = CGAffineTransformIdentity;
    } completion:nil];
}
/**
 *  隐藏view
 */
- (void)dismiss
{
    [UIView animateWithDuration:kAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.backView.alpha = 0.f;
        _shareView.transform = CGAffineTransformMakeTranslation(0, kShareViewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - share method

/**
 *  微信分享，微信音乐分享有dataurl，其他没有
 *
 *  @param isShareToWechatFriend YES为微信好友，NO为微信朋友圈
 */
- (void)shareToWechatWithFriend:(BOOL)isShareToWechatFriend
{
    if (![WXApi isWXAppInstalled]) {
        [[DLShareManager sharedInstance] showAlerWithMessage:NoWechat callBack:nil];
        return;
    }
    if (_shareData.shareType == DLShareFile && isShareToWechatFriend == NO) {
        [[DLShareManager sharedInstance] showAlerWithMessage:NOSupportDataType callBack:nil];
        return;
    }
    enum WXScene currentScene;
    if (isShareToWechatFriend) {
        currentScene = WXSceneSession;
    }else {
        currentScene = WXSceneTimeline;
    }
    switch (_shareData.shareType) {
        case DLShareText:
        {
            [WXApiRequestHandler sendText:_shareData.shareText
                                  InScene:currentScene];
            break;
        }
        case DLShareImage:
        {
            [WXApiRequestHandler sendImageData:UIImageJPEGRepresentation(_shareData.shareImage,1.0)
                                       TagName:nil
                                    MessageExt:nil
                                        Action:nil
                                    ThumbImage:_shareData.shareThumbImage
                                       InScene:currentScene];
            break;
        }
        case DLShareURL:
        {
            [WXApiRequestHandler sendLinkURL:_shareData.shareURL
                                     TagName:nil
                                       Title:_shareData.shareTitle
                                 Description:_shareData.shareDescription
                                  ThumbImage:_shareData.shareThumbImage
                                     InScene:currentScene];
            break;
        }
        case DLShareAudio:
        {
            [WXApiRequestHandler sendMusicURL:_shareData.shareURL
                                      dataURL:_shareData.shareDataURL
                                        Title:_shareData.shareTitle
                                  Description:_shareData.shareDescription
                                   ThumbImage:_shareData.shareThumbImage
                                      InScene:currentScene];
            break;
        }
        case DLShareVideo:
        {
            [WXApiRequestHandler sendVideoURL:_shareData.shareURL
                                        Title:_shareData.shareTitle
                                  Description:_shareData.shareDescription
                                   ThumbImage:_shareData.shareThumbImage
                                      InScene:currentScene];
            break;
        }
        case DLShareFile:
        {
            [WXApiRequestHandler sendFileData:_shareData.shareFileData
                                fileExtension:_shareData.shareFileExtension
                                        Title:_shareData.shareTitle
                                  Description:_shareData.shareDescription
                                   ThumbImage:_shareData.shareThumbImage
                                      InScene:currentScene];
            break;
        }
        default:
            break;
    }
}
/**
 *  QQ分享
 *
 *  @param isShareToQQFriend YES为QQ好友，NO为QQZone
 */
- (void)shareToQQWithFriend:(BOOL)isShareToQQFriend
{
    if (![QQApiInterface isQQInstalled]) {
         [[DLShareManager sharedInstance] showAlerWithMessage:NoQQ callBack:nil];
        return;
    }
    if (_shareData.shareType == DLShareFile && isShareToQQFriend == NO) {
        [[DLShareManager sharedInstance] showAlerWithMessage:NOSupportDataType callBack:nil];
        return;
    }
    QQApiObject *content;
    switch (_shareData.shareType) {
        case DLShareText:
        {
            if (isShareToQQFriend == NO) {
                content = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:_shareData.shareText extMap:nil];
            }else {
                content = [QQApiTextObject objectWithText:_shareData.shareText];
            }
            break;
        }
        case DLShareImage:
        {
            if (isShareToQQFriend == NO) {
                content = [QQApiImageArrayForQZoneObject objectWithimageDataArray:[NSArray arrayWithObjects:UIImageJPEGRepresentation(_shareData.shareImage,1.0), nil] title:_shareData.shareText extMap:nil];
            }else {
                content = [QQApiImageObject objectWithData:UIImageJPEGRepresentation(_shareData.shareImage,1.0) previewImageData:UIImageJPEGRepresentation(_shareData.shareThumbImage,1.0) title:_shareData.shareText description:_shareData.shareDescription];
            }
            break;
        }
        case DLShareURL:
        {
            content = [QQApiNewsObject objectWithURL:[NSURL URLWithString:_shareData.shareURL] title:_shareData.shareTitle description:_shareData.shareDescription previewImageData:UIImageJPEGRepresentation(_shareData.shareThumbImage,1.0)];
            if (isShareToQQFriend == NO) {
                [content setCflag:kQQAPICtrlFlagQZoneShareOnStart];
            }
            break;
        }
        case DLShareAudio:
        {
            if (isShareToQQFriend == YES) {
                content = [QQApiAudioObject objectWithURL:[NSURL URLWithString:_shareData.shareURL] title:_shareData.shareTitle description:_shareData.shareDescription previewImageData:UIImageJPEGRepresentation(_shareData.shareThumbImage,1.0)];
            }else {
                //分享音乐到qq空间，官方没有说明，走新闻路径
                content = [QQApiNewsObject objectWithURL:[NSURL URLWithString:_shareData.shareURL] title:_shareData.shareTitle description:_shareData.shareDescription previewImageData:UIImageJPEGRepresentation(_shareData.shareThumbImage,1.0)];
                [content setCflag:kQQAPICtrlFlagQZoneShareOnStart];
            }
            break;
        }
        case DLShareVideo:
        {
            /*
             * QQApiVideoObject类型的分享，目前在android和PC上接收消息时，展现有问题，待手Q版本以后更新支持
             * 目前如果要分享视频请使用 QQApiNewsObject 类型，URL填视频所在的H5地址
             
             content = [QQApiVideoObject objectWithURL:[NSURL URLWithString:self.shareURL] title:self.shareTitle description:self.shareDescription previewImageData:UIImageJPEGRepresentation(self.shareThumbImage,1.0)];
             */
            if (isShareToQQFriend == YES) {
                content = [QQApiNewsObject objectWithURL:[NSURL URLWithString:_shareData.shareURL] title:_shareData.shareTitle description:_shareData.shareDescription previewImageData:UIImageJPEGRepresentation(_shareData.shareThumbImage,1.0)];
            }else {
                content = [QQApiVideoForQZoneObject objectWithAssetURL:_shareData.shareURL title:_shareData.shareTitle extMap:nil];
            }
            break;
        }
        case DLShareFile:
        {
            QQApiFileObject *fileObj = [QQApiFileObject objectWithData:_shareData.shareFileData previewImageData:UIImageJPEGRepresentation(_shareData.shareThumbImage,1.0) title:_shareData.shareTitle description:_shareData.shareDescription];
            fileObj.fileName = _shareData.shareTitle;
            content = fileObj;
            [content setCflag:kQQAPICtrlFlagQQShare];
            break;
        }
            
        default:
            break;
    }
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:content];
    if (isShareToQQFriend == YES || _shareData.shareType == DLShareURL || _shareData.shareType == DLShareAudio) {
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    }else {
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        [self handleSendResult:sent];
    }
}
/**
 *  通过系统分享
 */
- (void)shareWithSystemMethod
{
    NSMutableArray *array = [NSMutableArray array];
    switch (_shareData.shareType) {
        case DLShareText:
            setupArrayValue(array, _shareData.shareText);
            break;
        case DLShareImage:
            setupArrayValue(array, _shareData.shareImage);
            break;
        case DLShareFile:
            setupArrayValue(array, _shareData.fileURL);
            break;
        case DLShareURL:
            setupArrayValue(array, _shareData.shareTitle);
            setupArrayValue(array, [NSURL URLWithString:_shareData.shareURL]);
            setupArrayValue(array, _shareData.shareThumbImage);
            break;
        default:
            break;
    }
    
    if (!array.count) {
        return;
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    __weak typeof(activityVC) weakVC = activityVC;
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
        [weakVC dismissViewControllerAnimated:YES completion:nil];
        [[DLShareManager sharedInstance] handleSystemResultWithActivityType:activityType compelete:completed error:activityError];
    };
    UIViewController *controller;
    if (_presentingController) {
        controller = _presentingController;
    } else {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        controller = [[DLShareManager sharedInstance] dl_visibleViewController:window];
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        objc_setAssociatedObject(controller, _cmd, popoverController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (_sourceItem) {
            [popoverController presentPopoverFromBarButtonItem:_sourceItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            UIView *view = controller.view;
            [popoverController presentPopoverFromRect:view.bounds inView:view permittedArrowDirections: UIPopoverArrowDirectionAny animated:YES];
        }
    }else{
        [controller presentViewController:activityVC animated:YES completion:nil];
    }
}
/**
 *  检测qq分享请求
 */
- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    [[DLShareManager sharedInstance] handleSendResult:sendResult];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DLShareViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:KCollectionCellIdentifier forIndexPath:indexPath];
    NSDictionary *dict = [self sharePlatformInfo][indexPath.row];
    NSBundle *podBudle = [NSBundle bundleForClass:[self class]];
    NSBundle *sourceBundle =  [NSBundle bundleWithPath:[podBudle pathForResource:@"DLShareLib" ofType:@"bundle"]];
    [cell.imageView setImage:[UIImage imageNamed:dict[@"image"] inBundle:sourceBundle compatibleWithTraitCollection:nil]];
    cell.label.text = dict[@"text"];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self shareToPlatform:indexPath.row];
    [self dismiss];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.f;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0.f;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = collectionView.bounds.size.width / 3.0;
    return CGSizeMake(width, (kShareViewHeight-kCancelButtonHeight)*0.5);
    
}
#pragma mark - Setters and Getters

/**
 *  蒙板
 */
- (UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.frame];
        _backView.backgroundColor = [UIColor blackColor];
        _backView.alpha = 0.f;
        UITapGestureRecognizer *cancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [_backView addGestureRecognizer:cancel];
    }
    return _backView;
}
/**
 *  分享弹出框（包括取消框）
 */
- (UIView *)shareView
{
    if (!_shareView) {
        _shareView = [UIView new];
        _shareView.backgroundColor = [UIColor whiteColor];
    }
    return _shareView;
}
/**
 *  分享功能框
 */
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[DLShareViewCell class] forCellWithReuseIdentifier:KCollectionCellIdentifier];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}
/**
 *  取消按钮
 */
- (UIButton *)cancelButton
{
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundColor:UIColorFromRGB(COLOR_RGB_GRAY)];
    [cancelButton setTitle:ShareCancel forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColorFromRGB(COLOR_RGB_ORANGE) forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [cancelButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    return cancelButton;
}
/**
 *  设置分享标题
 */
- (void)setShareTitle:(NSString *)shareTitle
{
    _shareTitle = shareTitle;
    self.shareData.shareTitle = shareTitle;
}
/**
 *  设置分享描述
 */
- (void)setShareDescription:(NSString *)shareDescription
{
    _shareDescription = shareDescription;
    self.shareData.shareDescription = shareDescription;
}
/**
 *  分享平台信息
 */
- (NSArray *)sharePlatformInfo
{
    NSArray *imageName = @[@"share_wechat_action",@"share_qq_action",@"share_qqzone_action",@"share_wechat_friend",@"share_more_action"];
    NSArray *text = @[ShareWeChat,ShareQQ,ShareQQZone,ShareFriendCircle,ShareMore];
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i<5; i++) {
        NSDictionary *dict = @{@"image":imageName[i],@"text":text[i]};
        [tempArray addObject:dict];
    }
    return [NSArray arrayWithArray:tempArray];
}
@end
