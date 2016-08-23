//
//  RouteCollectionViewCell.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/8.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "RouteCollectionViewCell.h"

@implementation RouteCollectionViewInfo

@end

#define RouteCellLeftMargin     10
#define RouteCellTopMargin      3

@interface RouteCollectionViewCell ()
{
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_prevImageView;
    UIImageView *_nextImageView;
}

@end

@implementation RouteCollectionViewCell

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.clipsToBounds = YES;
        
        _prevImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftArrow"]];
        _prevImageView.center = CGPointMake(RouteCellLeftMargin + CGRectGetWidth(_prevImageView.bounds) / 2.0, CGRectGetHeight(frame) / 2.0);
        _prevImageView.hidden = YES;
        [self.contentView addSubview:_prevImageView];
        
        _nextImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow"]];
        _nextImageView.center = CGPointMake(CGRectGetWidth(frame) - RouteCellLeftMargin - CGRectGetWidth(_nextImageView.bounds) / 2.0, CGRectGetHeight(frame) / 2.0);
        _nextImageView.hidden = YES;
        [self.contentView addSubview:_nextImageView];
        
        CGFloat labelWidth = CGRectGetWidth(frame) - CGRectGetWidth(_prevImageView.bounds) * 2 - RouteCellLeftMargin * 4;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(RouteCellLeftMargin + RouteCellLeftMargin + CGRectGetWidth(_prevImageView.frame), RouteCellTopMargin, labelWidth, 32)];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(RouteCellLeftMargin + RouteCellLeftMargin + CGRectGetWidth(_prevImageView.frame), CGRectGetMaxY(_titleLabel.frame), labelWidth, 20)];
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_subtitleLabel];
    }
    return self;
}

#pragma mark - Interface

- (void)setInfo:(RouteCollectionViewInfo *)info
{
    _info = info;
    
    _titleLabel.text = _info.title;
    _subtitleLabel.text = _info.subtitle;
}

- (void)setShouldShowPrevIndicator:(BOOL)shouldShowPrevIndicator
{
    _shouldShowPrevIndicator = shouldShowPrevIndicator;
    _prevImageView.hidden = !self.shouldShowPrevIndicator;
}

- (void)setShouldShowNextIndicator:(BOOL)shouldShowNextIndicator
{
    _shouldShowNextIndicator = shouldShowNextIndicator;
    _nextImageView.hidden = !self.shouldShowNextIndicator;
}

@end
