//
//  DLShareViewCell.m
//  PocketSLH
//
//  Created by apple on 16/8/3.
//
//

#import "DLShareViewCell.h"
#import <Masonry/Masonry.h>

@implementation DLShareViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] init];
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:imageView];
    [self.contentView addSubview:label];
    self.imageView = imageView;
    self.label = label;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@56);
        make.height.equalTo(@56);
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(10);
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom);
        make.height.equalTo(@30);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
}

@end
