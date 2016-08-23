//
//  CustomTurnInfoViewController.m
//  AMapNaviKit
//
//  Created by liubo on 8/1/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "CustomTurnInfoViewController.h"

@interface CustomTurnInfoViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate, AMapNaviDriveDataRepresentable>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) NSArray<AMapNaviPoint *> *wayPoints;

@property (nonatomic, strong) UILabel *turnRemainInfoLabel;
@property (nonatomic, strong) UILabel *roadInfoLabel;
@property (nonatomic, strong) UILabel *routeRemainInfoLabel;
@property (nonatomic, strong) UILabel *cameraInfoLabel;

@end

@implementation CustomTurnInfoViewController

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.driveManager stopNavi];
    [self.driveManager removeDataRepresentative:self.driveView];
    [self.driveManager removeDataRepresentative:self];
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
    
    [self configSubViews];
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
        
        //将当前VC添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.driveManager addDataRepresentative:self];
    }
}

- (void)initDriveView
{
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 400)];
        [self.driveView setDelegate:self];
        
        //将导航界面的界面元素进行隐藏，然后通过自定义的控件展示导航信息
        [self.driveView setShowUIElements:NO];
        
        [self.view addSubview:self.driveView];
    }
}

#pragma mark - Subviews

- (void)configSubViews
{
    self.turnRemainInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, CGRectGetWidth(self.view.bounds), 20)];
    self.turnRemainInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.turnRemainInfoLabel.font = [UIFont systemFontOfSize:14];
    self.turnRemainInfoLabel.text = [NSString stringWithFormat:@"转向剩余距离"];
    [self.view addSubview:self.turnRemainInfoLabel];
    
    self.roadInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 430, CGRectGetWidth(self.view.bounds), 20)];
    self.roadInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.roadInfoLabel.font = [UIFont systemFontOfSize:14];
    self.roadInfoLabel.text = [NSString stringWithFormat:@"道路信息"];
    [self.view addSubview:self.roadInfoLabel];
    
    self.routeRemainInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 450, CGRectGetWidth(self.view.bounds), 20)];
    self.routeRemainInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.routeRemainInfoLabel.font = [UIFont systemFontOfSize:14];
    self.routeRemainInfoLabel.text = [NSString stringWithFormat:@"道路剩余信息"];
    [self.view addSubview:self.routeRemainInfoLabel];
    
    self.cameraInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 470, CGRectGetWidth(self.view.bounds), 20)];
    self.cameraInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.cameraInfoLabel.font = [UIFont systemFontOfSize:14];
    self.cameraInfoLabel.text = [NSString stringWithFormat:@"电子眼信息"];
    [self.view addSubview:self.cameraInfoLabel];
}

#pragma mark - Route Plan

- (void)calculateRoute
{
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:self.wayPoints
                                          drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

#pragma mark - AMapNaviDriveDataRepresentable

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviMode:(AMapNaviMode)naviMode
{
    NSLog(@"updateNaviMode:%ld", (long)naviMode);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviRouteID:(NSInteger)naviRouteID
{
    NSLog(@"updateNaviRouteID:%ld", (long)naviRouteID);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviRoute:(nullable AMapNaviRoute *)naviRoute
{
    NSLog(@"updateNaviRoute");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(nullable AMapNaviInfo *)naviInfo
{
    //展示AMapNaviInfo类中的导航诱导信息，更多详细说明参考类 AMapNaviInfo 注释。
    
    //转向剩余距离
    NSString *turnStr = [NSString stringWithFormat:@"%@ 后，转向类型:%ld", [self normalizedRemainDistance:naviInfo.segmentRemainDistance], (long)naviInfo.iconType];
    [self.turnRemainInfoLabel setText:turnStr];
    
    //道路信息
    NSString *roadStr = [NSString stringWithFormat:@"从 %@ 进入 %@", naviInfo.currentRoadName, naviInfo.nextRoadName];
    [self.roadInfoLabel setText:roadStr];
    
    //路径剩余信息
    NSString *routeStr = [NSString stringWithFormat:@"剩余距离:%@ 剩余时间:%@", [self normalizedRemainDistance:naviInfo.routeRemainDistance], [self normalizedRemainTime:naviInfo.routeRemainTime]];
    [self.routeRemainInfoLabel setText:routeStr];
    
    //距离最近的下个电子眼信息
    NSString *cameraStr = @"暂无";
    if (naviInfo.cameraDistance > 0)
    {
        cameraStr = (naviInfo.cameraType == 0) ? [NSString stringWithFormat:@"测速(%ld)", (long)naviInfo.cameraLimitSpeed] : @"监控";
    }
    [self.cameraInfoLabel setText:[NSString stringWithFormat:@"电子眼信息:%@", cameraStr]];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation
{
    NSLog(@"updateNaviLocation");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showCrossImage:(UIImage *)crossImage
{
    NSLog(@"showCrossImage");
}

- (void)driveManagerHideCrossImage:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"hideCrossImage");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showLaneBackInfo:(NSString *)laneBackInfo laneSelectInfo:(NSString *)laneSelectInfo
{
    NSLog(@"showLaneInfo");
}

- (void)driveManagerHideLaneInfo:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"hideLaneInfo");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateTrafficStatus:(nullable NSArray<AMapNaviTrafficStatus *> *)trafficStatus
{
    NSLog(@"updateTrafficStatus");
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

#pragma mark - Utility

- (NSString *)normalizedRemainDistance:(NSInteger)remainDistance
{
    if (remainDistance < 0)
    {
        return nil;
    }
    
    if (remainDistance >= 1000)
    {
        CGFloat kiloMeter = remainDistance / 1000.0;
        
        if (remainDistance % 1000 >= 100)
        {
            kiloMeter -= 0.05f;
            return [NSString stringWithFormat:@"%.1f公里", kiloMeter];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f公里", kiloMeter];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%ld米", (long)remainDistance];
    }
}

- (NSString *)normalizedRemainTime:(NSInteger)remainTime
{
    if (remainTime < 0)
    {
        return nil;
    }
    
    if (remainTime < 60)
    {
        return [NSString stringWithFormat:@"< 1分钟"];
    }
    else if (remainTime >= 60 && remainTime < 60*60)
    {
        return [NSString stringWithFormat:@"%ld分钟", (long)remainTime/60];
    }
    else
    {
        NSInteger hours = remainTime / 60 / 60;
        NSInteger minute = remainTime / 60 % 60;
        if (minute == 0)
        {
            return [NSString stringWithFormat:@"%ld小时", (long)hours];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld小时%ld分钟", (long)hours, (long)minute];
        }
    }
}

@end
