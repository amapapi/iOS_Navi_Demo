//
//  CustomCrossLaneInfoViewController.m
//  AMapNaviKit
//
//  Created by liubo on 8/1/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "CustomCrossLaneInfoViewController.h"

@interface CustomCrossLaneInfoViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate, AMapNaviDriveDataRepresentable>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) NSArray<AMapNaviPoint *> *wayPoints;

@property (nonatomic, strong) UIImageView *laneInfoView;
@property (nonatomic, strong) UIImageView *crossImageView;

@end

@implementation CustomCrossLaneInfoViewController

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
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 450)];
        [self.driveView setDelegate:self];
        
        //将导航界面的界面元素进行隐藏，然后通过自定义的控件展示导航信息
        [self.driveView setShowUIElements:NO];
        
        [self.view addSubview:self.driveView];
    }
}

#pragma mark - Subviews

- (void)configSubViews
{
    self.laneInfoView = [[UIImageView alloc] init];
    [self.laneInfoView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), 480)];
    [self.view addSubview:self.laneInfoView];
    
    self.crossImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.bounds)-90, 300, 180, 140)];
    [self.view addSubview:self.crossImageView];
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
    
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation
{
    NSLog(@"updateNaviLocation");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showCrossImage:(UIImage *)crossImage
{
    NSLog(@"showCrossImage");
    
    //显示路口放大图
    [self.crossImageView setImage:crossImage];
}

- (void)driveManagerHideCrossImage:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"hideCrossImage");
    
    //隐藏路口放大图
    [self.crossImageView setImage:nil];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showLaneBackInfo:(NSString *)laneBackInfo laneSelectInfo:(NSString *)laneSelectInfo
{
    NSLog(@"showLaneInfo");
    
    //根据车道信息生成车道信息Image
    UIImage *laneInfoImage = CreateLaneInfoImageWithLaneInfo(laneBackInfo, laneSelectInfo);
    
    //显示车道信息
    [self.laneInfoView setImage:laneInfoImage];
    [self.laneInfoView setBounds:CGRectMake(0, 0, laneInfoImage.size.width, laneInfoImage.size.height)];
}

- (void)driveManagerHideLaneInfo:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"hideLaneInfo");
    
    //隐藏车道信息
    [self.laneInfoView setImage:nil];
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

@end
