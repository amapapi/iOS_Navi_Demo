//
//  CustomFunctionalButtonViewController.m
//  AMapNaviKit
//
//  Created by liubo on 8/1/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "CustomFunctionalButtonViewController.h"

@interface CustomFunctionalButtonViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) NSArray<AMapNaviPoint *> *wayPoints;

@property (nonatomic, strong) UISegmentedControl *showMode;
@property (nonatomic, strong) UIButton *trafficLayerButton;
@property (nonatomic, strong) UIButton *zoomInButton;
@property (nonatomic, strong) UIButton *zoomOutButton;

@end

@implementation CustomFunctionalButtonViewController

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
    self.showMode = [[UISegmentedControl alloc] initWithItems:@[@"锁车状态",@"全览状态",@"普通状态"]];
    [self.showMode setFrame:CGRectMake(10, 410, 200, 30)];
    self.showMode.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.showMode addTarget:self action:@selector(showModeAction:) forControlEvents:UIControlEventValueChanged];
    self.showMode.selectedSegmentIndex = 0;
    [self.view addSubview:self.showMode];
    
    self.trafficLayerButton = [self createToolButton];
    [self.trafficLayerButton setFrame:CGRectMake(10, 460, 80, 30)];
    [self.trafficLayerButton setTitle:@"交通信息" forState:UIControlStateNormal];
    [self.trafficLayerButton addTarget:self action:@selector(trafficLayerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.trafficLayerButton];
    
    self.zoomInButton = [self createToolButton];
    [self.zoomInButton setFrame:CGRectMake(100, 460, 80, 30)];
    [self.zoomInButton setTitle:@"ZoomIn" forState:UIControlStateNormal];
    [self.zoomInButton addTarget:self action:@selector(zoomInAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.zoomInButton];
    
    self.zoomOutButton = [self createToolButton];
    [self.zoomOutButton setFrame:CGRectMake(190, 460, 80, 30)];
    [self.zoomOutButton setTitle:@"ZoomOut" forState:UIControlStateNormal];
    [self.zoomOutButton addTarget:self action:@selector(zoomOutAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.zoomOutButton];
}

- (UIButton *)createToolButton
{
    UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    toolBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    toolBtn.layer.borderWidth  = 0.5;
    toolBtn.layer.cornerRadius = 5;
    
    [toolBtn setBounds:CGRectMake(0, 0, 80, 30)];
    [toolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    return toolBtn;
}

#pragma mark - Button Action

- (void)trafficLayerAction
{
    //是否显示实时交通路况
    [self.driveView setShowTrafficLayer:!self.driveView.showTrafficLayer];
}

- (void)showModeAction:(UISegmentedControl *)sender
{
    //改变界面的显示模式
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            [self.driveView setShowMode:AMapNaviDriveViewShowModeCarPositionLocked];
            break;
        case 1:
            [self.driveView setShowMode:AMapNaviDriveViewShowModeOverview];
            break;
        case 2:
            [self.driveView setShowMode:AMapNaviDriveViewShowModeNormal];
            break;
        default:
            break;
    }
}

- (void)zoomInAction
{
    //改变地图的zoomLevel，会进入非锁车状态
    self.driveView.mapZoomLevel = self.driveView.mapZoomLevel+1;
}

- (void)zoomOutAction
{
    //改变地图的zoomLevel，会进入非锁车状态
    self.driveView.mapZoomLevel = self.driveView.mapZoomLevel-1;
}

#pragma mark - Route Plan

- (void)calculateRoute
{
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:self.wayPoints
                                          drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

#pragma mark - AMapNaviDriveView Delegate

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode
{
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
    
    //显示模式发生改变后的回调方法
    switch (showMode) {
        case AMapNaviDriveViewShowModeCarPositionLocked:
            [self.showMode setSelectedSegmentIndex:0];
            break;
        case AMapNaviDriveViewShowModeOverview:
            [self.showMode setSelectedSegmentIndex:1];
            break;
        case AMapNaviDriveViewShowModeNormal:
            [self.showMode setSelectedSegmentIndex:2];
            break;
        default:
            break;
    }
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
