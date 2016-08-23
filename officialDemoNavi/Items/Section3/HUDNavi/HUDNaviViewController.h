//
//  HUDNaviViewController.h
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface HUDNaviViewController : UIViewController

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@property (nonatomic, strong) AMapNaviHUDView *hudView;

@end
