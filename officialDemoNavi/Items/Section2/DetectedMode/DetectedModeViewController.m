//
//  DetectedModeViewController.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/10.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "DetectedModeViewController.h"
#import "SpeechSynthesizer.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DetectedModeViewController ()<AMapNaviDriveManagerDelegate, MAMapViewDelegate, AMapNaviDriveDataRepresentable>

@property (nonatomic, strong) MAPointAnnotation *carAnnotation;

@end

@implementation DetectedModeViewController

#pragma mark - Life Cycle

- (void)dealloc
{
    [self.driveManager setDetectedMode:AMapNaviDetectedModeNone];
    [self.driveManager removeDataRepresentative:self];
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initToolBar];
    
    [self initMapView];
    
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
    
    [self initCarAnnotation];
    
    //将当前VC添加为导航数据的Representative，使其可以接收到导航诱导数据
    [self.driveManager addDataRepresentative:self];
    
    //开启智能巡航模式
    [self.driveManager setDetectedMode:AMapNaviDetectedModeCameraAndSpecialRoad];
    
    [self notifyNeedDriving];
}

#pragma mark - Initalization

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}

- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];
    }
}

- (void)initCarAnnotation
{
    self.carAnnotation = [[MAPointAnnotation alloc] init];
    
    [self.mapView addAnnotation:self.carAnnotation];
}

- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UISegmentedControl *detectedModeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"关闭", @"电子眼和特殊道路设施"]];
    detectedModeSegmentedControl.selectedSegmentIndex = 1;
    detectedModeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [detectedModeSegmentedControl addTarget:self
                                     action:@selector(detectedModeAction:)
                           forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *detectedModeItem = [[UIBarButtonItem alloc] initWithCustomView:detectedModeSegmentedControl];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, detectedModeItem, flexbleItem, nil];
}

#pragma mark - Segmented Control Action

- (void)detectedModeAction:(UISegmentedControl *)sender
{
    NSString *selectedTitle = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    
    if ([selectedTitle isEqualToString:@"关闭"])
    {
        //停止语音
        [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
        
        [self.driveManager setDetectedMode:AMapNaviDetectedModeNone];
    }
    else if ([selectedTitle isEqualToString:@"电子眼和特殊道路设施"])
    {
        //开启智能巡航模式
        [self.driveManager setDetectedMode:AMapNaviDetectedModeCameraAndSpecialRoad];
    }
    
    NSLog(@"DetectedMode:%ld", (long)self.driveManager.detectedMode);
}

#pragma mark - Utility

- (void)updateCarAnnotationCoordinate:(CLLocationCoordinate2D)coordinate
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.carAnnotation setCoordinate:coordinate];
    }];
    
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    [self.mapView setZoomLevel:17 animated:YES];
}

- (void)notifyNeedDriving
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"智能播报功能需要在驾车过程中体验~" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - AMapNaviDriveDataRepresentable

/*
 这里只需要关注巡航相关数据，更多数据更新回调参考 AMapNaviDriveDataRepresentable 。
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(naviLocation.coordinate.latitude, naviLocation.coordinate.longitude);
    
    [self updateCarAnnotationCoordinate:coordinate];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateTrafficFacilities:(NSArray<AMapNaviTrafficFacilityInfo *> *)trafficFacilities
{
    NSLog(@"updateTrafficFacilities:%@", trafficFacilities);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateCruiseInfo:(AMapNaviCruiseInfo *)cruiseInfo
{
    NSLog(@"updateCruiseInfo:%@", cruiseInfo);
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
    
    if (soundStringType == AMapNaviSoundTypePassedReminder)
    {
        //用系统自带的声音做简单例子，播放其他提示音需要另外配置
        AudioServicesPlaySystemSound(1009);
    }
    else
    {
        [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
    }
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}

#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *detectedReuseIndetifier = @"DetectedModeAnnotationIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:detectedReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:detectedReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.draggable = NO;
        annotationView.image = [UIImage imageNamed:@"car"];
        
        return annotationView;
    }
    
    return nil;
}

@end
