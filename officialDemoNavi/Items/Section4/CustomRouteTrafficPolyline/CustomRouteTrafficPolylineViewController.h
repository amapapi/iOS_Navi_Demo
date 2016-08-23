//
//  CustomRouteTrafficPolylineViewController.h
//  AMapNaviKit
//
//  Created by liubo on 8/3/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface CustomRouteTrafficPolylineViewController : UIViewController

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@property (nonatomic, strong) AMapNaviDriveView *driveView;

@end
