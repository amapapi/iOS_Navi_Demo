//
//  HUDNaviViewController.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "HUDNaviViewController.h"
#import "SpeechSynthesizer.h"

@interface HUDNaviViewController ()<AMapNaviDriveManagerDelegate, AMapNaviHUDViewDelegate>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@end

@implementation HUDNaviViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initProperties];
    
    [self initHudView];
    
    [self initDriveManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self calculateRoute];
}

- (void)viewWillLayoutSubviews
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        interfaceOrientation = self.interfaceOrientation;
    }
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        [self.hudView setIsLandscape:NO];
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        [self.hudView setIsLandscape:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Initalization

- (void)initProperties
{
    //为了方便展示驾车多路径规划，选择了固定的起终点
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993135 longitude:116.474175];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:39.985063 longitude:116.464831];
}

- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];
        
        //将hudView添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.driveManager addDataRepresentative:self.hudView];
    }
}

- (void)initHudView
{
    if (self.hudView == nil)
    {
        self.hudView = [[AMapNaviHUDView alloc] initWithFrame:self.view.bounds];
        self.hudView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        [self.hudView setDelegate:self];
        [self.view addSubview:self.hudView];
    }
}

#pragma mark - Button Action

- (void)calculateRoute
{
    //进行路径规划
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:nil
                                          drivingStrategy:AMapNaviDrivingStrategyMultipleAvoidCongestion];
}

#pragma mark - AMapNaviHUDView Delegate

- (void)hudViewCloseButtonClicked:(AMapNaviHUDView *)hudView
{
    //停止导航
    [self.driveManager stopNavi];
    [self.driveManager removeDataRepresentative:self.hudView];
    
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后进行模拟导航
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

@end
