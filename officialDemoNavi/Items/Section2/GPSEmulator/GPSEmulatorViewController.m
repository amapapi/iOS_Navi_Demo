//
//  GPSEmulatorViewController.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/14.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "GPSEmulatorViewController.h"

#import "SpeechSynthesizer.h"
#import "GPSEmulator.h"

@interface GPSEmulatorViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate, AMapNaviDriveDataRepresentable>

@property (nonatomic, strong) GPSEmulator *gpsEmulator;

@property (nonatomic, strong) AMapNaviPoint* startPoint;
@property (nonatomic, strong) AMapNaviPoint* endPoint;

@end

@implementation GPSEmulatorViewController

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.driveManager stopNavi];
    [self.driveManager removeDataRepresentative:self.driveView];
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
    //停止GPS模拟
    [self.gpsEmulator stopEmulator];
    self.gpsEmulator = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initToolBar];
    
    [self initProperties];
    
    [self initDriveView];
    
    [self initDriveManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self calculateRoute];
}

#pragma mark - Initalization

- (void)initProperties
{
    self.gpsEmulator = [[GPSEmulator alloc] init];
    
    //为了方便展示GPS模拟的结果，我们提前录制了一段GPS坐标，同时配合固定的两个点进行算路导航
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.989773 longitude:116.479872];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:39.995839 longitude:116.451204];
}

- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];
        
        //将当前VC添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.driveManager addDataRepresentative:self.driveView];
    }
}

- (void)initDriveView
{
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, 108, 0))];
        [self.driveView setDelegate:self];
        
        [self.view addSubview:self.driveView];
    }
}

- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UISegmentedControl *switchSegment = [[UISegmentedControl alloc] initWithItems:@[@"停止GPS模拟", @"开始GPS模拟"]];
    switchSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [switchSegment addTarget:self action:@selector(switchSegmentAction:) forControlEvents:UIControlEventValueChanged];
    switchSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:switchSegment];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, showItem, flexble, nil];
}

#pragma mark - Switch Segment Action

- (void)switchSegmentAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        [self stopGPSEmulator];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        [self startGPSEmulator];
    }
}

#pragma mark - GPS Emulator

//开始传入GPS模拟数据进行导航
- (void)startGPSEmulator
{
    if ([self.gpsEmulator isSimulating])
    {
        NSLog(@"GPSEmulator is already running");
        return;
    }
    
    //开启使用外部GPS数据
    [self.driveManager setEnableExternalLocation:YES];
    
    //开始GPS导航
    [self.driveManager startGPSNavi];
    
    __weak typeof(self) weakSelf = self;
    [self.gpsEmulator startEmulatorUsingLocationBlock:^(CLLocation *location, NSUInteger index, NSDate *addedTime, BOOL *stop) {
        
        //注意：需要使用当前时间作为时间戳
        CLLocation *newLocation = [[CLLocation alloc] initWithCoordinate:location.coordinate
                                                                altitude:location.altitude
                                                      horizontalAccuracy:location.horizontalAccuracy
                                                        verticalAccuracy:location.verticalAccuracy
                                                                  course:location.course
                                                                   speed:location.speed
                                                               timestamp:[NSDate dateWithTimeIntervalSinceNow:0]];
        
        //传入GPS模拟数据
        [weakSelf.driveManager setExternalLocation:newLocation isAMapCoordinate:NO];
        
        NSLog(@"SimGPS:{%f-%f-%f-%f}", location.coordinate.latitude, location.coordinate.longitude, location.speed, location.course);
    }];
}

//停止传入GPS模拟数据
- (void)stopGPSEmulator
{
    [self.gpsEmulator stopEmulator];
    
    [self.driveManager stopNavi];
    
    [self.driveManager setEnableExternalLocation:NO];
}

#pragma mark - Route Plan

- (void)calculateRoute
{
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:nil
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
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
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

- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView
{
    if (self.driveView.trackingMode == AMapNaviViewTrackingModeCarNorth)
    {
        self.driveView.trackingMode = AMapNaviViewTrackingModeMapNorth;
    }
    else
    {
        self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
    }
}

@end
