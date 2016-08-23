//
//  QuickStartViewController.h
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface QuickStartViewController : UIViewController

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@end
