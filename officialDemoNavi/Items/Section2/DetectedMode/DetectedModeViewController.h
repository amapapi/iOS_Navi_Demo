//
//  DetectedModeViewController.h
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/10.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface DetectedModeViewController : UIViewController

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@end
