//
//  DriveRoutePlanViewController.h
//  AMapNaviKit
//
//  Created by liubo on 7/29/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface DriveRoutePlanViewController : UIViewController

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@end
