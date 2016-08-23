//
//  QuickStartViewController.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "QuickStartViewController.h"

#import "SpeechSynthesizer.h"
#import "DriveNaviViewController.h"
#import "QuickStartAnnotationView.h"

@interface QuickStartViewController ()<MAMapViewDelegate, AMapSearchDelegate, AMapNaviDriveManagerDelegate, DriveNaviViewControllerDelegate>
{
    AMapNaviPoint *_endPoint;
    
    MAUserLocation *_userLocation;
    
    NSMutableArray *_poiAnnotations;
}

@end

@implementation QuickStartViewController

#pragma mark - Lufe Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initProperties];
    
    [self initToolBar];
    
    [self initMapView];
    
    [self initDriveManager];
    
    [self initSearch];
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
    
    [self.mapView setShowsUserLocation:YES];
}

#pragma mark - Initalization

- (void)initProperties
{
    _poiAnnotations = [[NSMutableArray alloc] init];
}

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

- (void)initSearch
{
    if (self.search == nil)
    {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
}

- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"餐饮",
                                             @"酒店",
                                             @"电影",
                                             nil]];
    
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *searchTypeItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, searchTypeItem, flexbleItem, nil];
}

#pragma mark - Search

- (void)searchAction:(UISegmentedControl *)segmentedControl
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    if (_userLocation)
    {
        request.location = [AMapGeoPoint locationWithLatitude:_userLocation.location.coordinate.latitude
                                                    longitude:_userLocation.location.coordinate.longitude];
    }
    else
    {
        request.location = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.471476];
    }
    
    request.keywords            = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    request.sortrule            = 1;
    request.requireExtension    = NO;
    
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - Actions

- (void)routePlanAction
{
    [self.driveManager calculateDriveRouteWithEndPoints:@[_endPoint]
                                              wayPoints:nil
                                        drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

#pragma mark - DriveNaviView Delegate

- (void)driveNaviViewCloseButtonClicked
{
    //停止导航
    [self.driveManager stopNavi];
    
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    DriveNaviViewController *driveVC = [[DriveNaviViewController alloc] init];
    [driveVC setDelegate:self];
    
    //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
    [self.driveManager addDataRepresentative:driveVC.driveView];
    
    [self.navigationController pushViewController:driveVC animated:NO];
    [self.driveManager startGPSNavi];
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

#pragma mark - Search Delegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"SearchError:{%@}", error.localizedDescription);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    [self.mapView removeAnnotations:_poiAnnotations];
    [_poiAnnotations removeAllObjects];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude)];
        [annotation setTitle:obj.name];
        [annotation setSubtitle:obj.address];
        
        [_poiAnnotations addObject:annotation];
    }];
    
    [self showPOIAnnotations];
}

- (void)showPOIAnnotations
{
    [self.mapView addAnnotations:_poiAnnotations];
    
    if (_poiAnnotations.count == 1)
    {
        self.mapView.centerCoordinate = [(MAPointAnnotation *)_poiAnnotations[0] coordinate];
    }
    else
    {
        [self.mapView showAnnotations:_poiAnnotations animated:NO];
    }
}

#pragma mark - MapView Delegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (updatingLocation)
    {
        _userLocation = userLocation;
    }
    
    if ([_poiAnnotations count] == 0)
    {
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(_userLocation.coordinate.latitude-0.01, _userLocation.coordinate.longitude)];
        [annotation setTitle:@"testTitle"];
        [annotation setSubtitle:@"testSubtitle"];

        [_poiAnnotations addObject:annotation];
        
        [self showPOIAnnotations];
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPointAnnotation *annotation = (MAPointAnnotation *)view.annotation;
        
        _endPoint = [AMapNaviPoint locationWithLatitude:annotation.coordinate.latitude
                                              longitude:annotation.coordinate.longitude];
        
        [self routePlanAction];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"QuickStartAnnotationView";
        QuickStartAnnotationView *annotationView = (QuickStartAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[QuickStartAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        
        return annotationView;
    }
    
    return nil;
}

@end
