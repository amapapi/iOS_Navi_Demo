//
//  WalkRoutePlanViewController.m
//  AMapNaviKit
//
//  Created by liubo on 7/29/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "WalkRoutePlanViewController.h"

#import "NaviPointAnnotation.h"
#import "SelectableOverlay.h"
#import "RouteCollectionViewCell.h"

#define kRoutePlanInfoViewHeight    100.f
#define kRouteIndicatorViewHeight   64.f
#define kCollectionCellIdentifier   @"kCollectionCellIdentifier"

@interface WalkRoutePlanViewController ()<MAMapViewDelegate, AMapNaviWalkManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@property (nonatomic, strong) UICollectionView *routeIndicatorView;
@property (nonatomic, strong) NSMutableArray *routeIndicatorInfoArray;

@end

@implementation WalkRoutePlanViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initProperties];
    
    [self initMapView];
    
    [self initWalkManager];
    
    [self configSubViews];
    
    [self initRouteIndicatorView];
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
    
    [self initAnnotations];
}

#pragma mark - Initalization

- (void)initProperties
{
    //为了方便展示步行路径规划，选择了固定的起终点
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993135 longitude:116.474175];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:39.908791 longitude:116.321257];
    
    self.routeIndicatorInfoArray = [NSMutableArray array];
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, kRoutePlanInfoViewHeight,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - kRoutePlanInfoViewHeight)];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}

- (void)initWalkManager
{
    if (self.walkManager == nil)
    {
        self.walkManager = [[AMapNaviWalkManager alloc] init];
        [self.walkManager setDelegate:self];
    }
}

- (void)initRouteIndicatorView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _routeIndicatorView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kRouteIndicatorViewHeight, CGRectGetWidth(self.view.bounds), kRouteIndicatorViewHeight) collectionViewLayout:layout];
    
    _routeIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _routeIndicatorView.backgroundColor = [UIColor clearColor];
    _routeIndicatorView.pagingEnabled = YES;
    _routeIndicatorView.showsVerticalScrollIndicator = NO;
    _routeIndicatorView.showsHorizontalScrollIndicator = NO;
    
    _routeIndicatorView.delegate = self;
    _routeIndicatorView.dataSource = self;
    
    [_routeIndicatorView registerClass:[RouteCollectionViewCell class] forCellWithReuseIdentifier:kCollectionCellIdentifier];
    
    [self.view addSubview:_routeIndicatorView];
}

- (void)initAnnotations
{
    NaviPointAnnotation *beginAnnotation = [[NaviPointAnnotation alloc] init];
    [beginAnnotation setCoordinate:CLLocationCoordinate2DMake(self.startPoint.latitude, self.startPoint.longitude)];
    beginAnnotation.title = @"起始点";
    beginAnnotation.navPointType = NaviPointAnnotationStart;
    
    [self.mapView addAnnotation:beginAnnotation];
    
    NaviPointAnnotation *endAnnotation = [[NaviPointAnnotation alloc] init];
    [endAnnotation setCoordinate:CLLocationCoordinate2DMake(self.endPoint.latitude, self.endPoint.longitude)];
    endAnnotation.title = @"终点";
    endAnnotation.navPointType = NaviPointAnnotationEnd;
    
    [self.mapView addAnnotation:endAnnotation];
}

#pragma mark - Button Action

- (void)routePlanAction:(id)sender
{
    //进行步行路径规划
    [self.walkManager calculateWalkRouteWithStartPoints:@[self.startPoint]
                                              endPoints:@[self.endPoint]];
}

#pragma mark - Handle Navi Routes

- (void)showNaviRoutes
{
    if (self.walkManager.naviRoute == nil)
    {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    AMapNaviRoute *aRoute = self.walkManager.naviRoute;
    int count = (int)[[aRoute routeCoordinates] count];
    
    //添加路径Polyline
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < count; i++)
    {
        AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
        coords[i].latitude = [coordinate latitude];
        coords[i].longitude = [coordinate longitude];
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
    
    SelectableOverlay *selectablePolyline = [[SelectableOverlay alloc] initWithOverlay:polyline];
    
    [self.mapView addOverlay:selectablePolyline];
    free(coords);
    
    //更新CollectonView的信息
    RouteCollectionViewInfo *info = [[RouteCollectionViewInfo alloc] init];
    info.title = [NSString stringWithFormat:@"路径信息:"];
    info.subtitle = [NSString stringWithFormat:@"长度:%ld米 | 预估时间:%ld秒 | 分段数:%ld", (long)aRoute.routeLength, (long)aRoute.routeTime, (long)aRoute.routeSegments.count];
    
    [self.routeIndicatorInfoArray addObject:info];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    [self.routeIndicatorView reloadData];
}

- (void)selecteOverlayWithRouteID:(NSInteger)routeID
{
    [self.mapView.overlays enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MAOverlay> overlay, NSUInteger idx, BOOL *stop)
     {
         if ([overlay isKindOfClass:[SelectableOverlay class]])
         {
             SelectableOverlay *selectableOverlay = overlay;
             
             /* 获取overlay对应的renderer. */
             MAPolylineRenderer * overlayRenderer = (MAPolylineRenderer *)[self.mapView rendererForOverlay:selectableOverlay];
             
             if (selectableOverlay.routeID == routeID)
             {
                 /* 设置选中状态. */
                 selectableOverlay.selected = YES;
                 
                 /* 修改renderer选中颜色. */
                 overlayRenderer.fillColor   = selectableOverlay.selectedColor;
                 overlayRenderer.strokeColor = selectableOverlay.selectedColor;
                 
                 /* 修改overlay覆盖的顺序. */
                 [self.mapView exchangeOverlayAtIndex:idx withOverlayAtIndex:self.mapView.overlays.count - 1];
             }
             else
             {
                 /* 设置选中状态. */
                 selectableOverlay.selected = NO;
                 
                 /* 修改renderer选中颜色. */
                 overlayRenderer.fillColor   = selectableOverlay.regularColor;
                 overlayRenderer.strokeColor = selectableOverlay.regularColor;
             }
             
             [overlayRenderer glRender];
         }
     }];
}

#pragma mark - SubViews

- (void)configSubViews
{
    UILabel *startPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.view.bounds), 20)];
    
    startPointLabel.textAlignment = NSTextAlignmentCenter;
    startPointLabel.font = [UIFont systemFontOfSize:14];
    startPointLabel.text = [NSString stringWithFormat:@"起 点：%f, %f", self.startPoint.latitude, self.startPoint.longitude];
    
    [self.view addSubview:startPointLabel];
    
    UILabel *endPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.view.bounds), 20)];
    
    endPointLabel.textAlignment = NSTextAlignmentCenter;
    endPointLabel.font = [UIFont systemFontOfSize:14];
    endPointLabel.text = [NSString stringWithFormat:@"终 点：%f, %f", self.endPoint.latitude, self.endPoint.longitude];
    
    [self.view addSubview:endPointLabel];
    
    UIButton *routeBtn = [self createToolButton];
    [routeBtn setFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-80)/2.0, 60, 80, 30)];
    [routeBtn setTitle:@"路径规划" forState:UIControlStateNormal];
    [routeBtn addTarget:self action:@selector(routePlanAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:routeBtn];
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

#pragma mark - AMapNaviDriveManager Delegate

- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后显示路径
    [self showNaviRoutes];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)walkManagerNeedRecalculateRouteForYaw:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
}

- (void)walkManagerDidEndEmulatorNavi:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)walkManagerOnArrivedDestination:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"onArrivedDestination");
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.routeIndicatorInfoArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RouteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCellIdentifier forIndexPath:indexPath];
    
    cell.shouldShowPrevIndicator = (indexPath.row > 0 && indexPath.row < _routeIndicatorInfoArray.count);
    cell.shouldShowNextIndicator = (indexPath.row >= 0 && indexPath.row < _routeIndicatorInfoArray.count-1);
    cell.info = self.routeIndicatorInfoArray[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 10, CGRectGetHeight(collectionView.bounds) - 5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 5, 5);
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    return;
}

#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NaviPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"NaviPointAnnotationIdentifier";
        
        MAPinAnnotationView *pointAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (pointAnnotationView == nil)
        {
            pointAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:annotationIdentifier];
        }
        
        pointAnnotationView.animatesDrop   = NO;
        pointAnnotationView.canShowCallout = YES;
        pointAnnotationView.draggable      = NO;
        
        NaviPointAnnotation *navAnnotation = (NaviPointAnnotation *)annotation;
        
        if (navAnnotation.navPointType == NaviPointAnnotationStart)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorGreen];
        }
        else if (navAnnotation.navPointType == NaviPointAnnotationEnd)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorRed];
        }
        
        return pointAnnotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[SelectableOverlay class]])
    {
        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        
        polylineRenderer.lineWidth = 8.f;
        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
        
        return polylineRenderer;
    }
    
    return nil;
}

@end
