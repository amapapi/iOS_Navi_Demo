//
//  CustomRouteTrafficPolylineViewController.m
//  AMapNaviKit
//
//  Created by liubo on 8/3/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "CustomRouteTrafficPolylineViewController.h"

@interface CustomRouteTrafficPolylineViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) NSArray<AMapNaviPoint *> *wayPoints;

@end

@implementation CustomRouteTrafficPolylineViewController

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.driveManager stopNavi];
    [self.driveManager removeDataRepresentative:self.driveView];
    [self.driveManager setDelegate:nil];
    
    [self.driveView removeFromSuperview];
    self.driveView.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initProperties];
    
    [self initDriveView];
    
    [self initDriveManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self calculateRoute];
}

#pragma mark - Initalization

- (void)initProperties
{
    //为了方便展示,选择了固定的起终点
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993135 longitude:116.474175];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:39.910267 longitude:116.370888];
    self.wayPoints  = @[[AMapNaviPoint locationWithLatitude:39.973135 longitude:116.444175],
                        [AMapNaviPoint locationWithLatitude:39.987125 longitude:116.353145]];
}

- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];
        
        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.driveManager addDataRepresentative:self.driveView];
    }
}

- (void)initDriveView
{
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 450)];
        [self.driveView setDelegate:self];
        
        //可以将导航界面的界面元素进行隐藏，然后通过自定义的控件展示导航信息
        [self.driveView setShowUIElements:NO];
        
        //自定义实时交通路线Polyline的样式
        [self.driveView setLineWidth:8];
        [self.driveView setStatusTextures:@{@(AMapNaviRouteStatusUnknow): [UIImage imageNamed:@"arrowTexture0"],
                                            @(AMapNaviRouteStatusSmooth): [UIImage imageNamed:@"arrowTexture1"],
                                            @(AMapNaviRouteStatusSlow): [UIImage imageNamed:@"arrowTexture2"],
                                            @(AMapNaviRouteStatusJam): [UIImage imageNamed:@"arrowTexture3"],
                                            @(AMapNaviRouteStatusSeriousJam): [UIImage imageNamed:@"arrowTexture4"],}];
        
        [self.view addSubview:self.driveView];
    }
}

#pragma mark - Route Plan

- (void)calculateRoute
{
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:self.wayPoints
                                          drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    [self.driveManager startEmulatorNavi];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}

#pragma mark - AMapNaviDriveViewDelegate

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode
{
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
}

@end
