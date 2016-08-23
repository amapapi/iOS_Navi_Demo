//
//  RouteCollectionViewCell.h
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/8.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteCollectionViewInfo : NSObject

@property (nonatomic, assign) NSInteger routeID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

@interface RouteCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) RouteCollectionViewInfo *info;

@property (nonatomic, assign) BOOL shouldShowPrevIndicator;
@property (nonatomic, assign) BOOL shouldShowNextIndicator;

@end
