//
//  ViewController.swift
//  AMapNaviSwiftDemo
//
//  Created by 刘博 on 16/4/12.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,MAMapViewDelegate,AMapNaviDriveManagerDelegate,AMapNaviDriveViewDelegate {

    //MARK: - Properties
    
    let startPoint = AMapNaviPoint.locationWithLatitude(39.989614, longitude: 116.481763)
    let endPoint = AMapNaviPoint.locationWithLatitude(39.983456, longitude: 116.315495)
    
    var calRouteSuccess = false
    var annotations = [MAAnnotation]()
    let speechSynthesizer = AVSpeechSynthesizer()
    let naviManager = AMapNaviDriveManager()
    lazy var driveView = AMapNaviDriveView()
    
    var mapView: MAMapView!
    var polyline: MAPolyline?
    
    //MARK: - Life Cycle
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AMapNaviKit-Demo-Swift"
        navigationController?.setToolbarHidden(false, animated: false);
        
        initToolBar()
        
        initSubViews()
        
        initMapView()
        
        naviManager.delegate = self
        naviManager.addDataRepresentative(driveView)
        
        driveView.frame = CGRectMake(0, 60, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-60)
        driveView.delegate = self
    }
    
    //MARK: - Initilization
    
    func initToolBar() {
        let flexbleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let calcroute = UIBarButtonItem(title: "路径规划", style: .Plain, target: self, action:#selector(calculateRoute))
        let simunavi = UIBarButtonItem(title: "模拟导航", style: .Plain, target: self, action:#selector(startSimuNavi))
        
        setToolbarItems([flexbleItem,calcroute,flexbleItem,simunavi,flexbleItem], animated: false)
    }
    
    func initSubViews() {
        let startPointLabel = UILabel(frame: CGRectMake(0, 70, 320, 20))
        startPointLabel.textAlignment = .Center
        startPointLabel.font = UIFont.systemFontOfSize(14)
        startPointLabel.text = "起点: \(startPoint.latitude), \(startPoint.longitude)"
        
        view.addSubview(startPointLabel)
        
        let endPointLabel = UILabel(frame: CGRectMake(0, 100, 320, 20))
        endPointLabel.textAlignment = .Center
        endPointLabel.font = UIFont.systemFontOfSize(14)
        endPointLabel.text = "终点: \(endPoint.latitude), \(endPoint.longitude)"
        
        view.addSubview(endPointLabel)
    }
    
    func initMapView() {
        mapView = MAMapView(frame: CGRectMake(0, 130, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-170))
        mapView.delegate = self
        
        view.insertSubview(mapView, atIndex: 0)
    }
    
    func initAnnotations(){
        let startAnn = MAPointAnnotation()
        startAnn.coordinate = CLLocationCoordinate2DMake(Double(startPoint.latitude), Double(startPoint.longitude))
        startAnn.title = "Start"
        
        annotations.append(startAnn)
        
        let endAnn = MAPointAnnotation()
        endAnn.coordinate = CLLocationCoordinate2DMake(Double(endPoint.latitude), Double(endPoint.longitude))
        endAnn.title = "End"
        
        annotations.append(endAnn)
        
        mapView.addAnnotations(annotations)
    }
    
    //MARK: - Navi Control
    
    func startSimuNavi()
    {
        if calRouteSuccess {
            navigationController?.setToolbarHidden(true, animated: false);
            view.addSubview(driveView)
            
            naviManager.startEmulatorNavi()
        }
        else {
            let alert = UIAlertView(title: "请先进行路线规划", message: nil, delegate: nil, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    func calculateRoute() {
        
        initAnnotations()
        
        naviManager.calculateDriveRouteWithStartPoints([startPoint], endPoints: [endPoint], wayPoints: nil, drivingStrategy: .SingleDefault)
    }
    
    // 展示规划路径
    func showRouteWithNaviRoute(naviRoute: AMapNaviRoute)
    {
        guard let mapView = self.mapView else { return }
        
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        for aCoordinate in naviRoute.routeCoordinates {
            coordinates.append(CLLocationCoordinate2DMake(Double(aCoordinate.latitude), Double(aCoordinate.longitude)))
        }
        
        polyline = MAPolyline(coordinates:&coordinates, count: UInt(naviRoute.routeCoordinates.count))
        
        mapView.addOverlay(polyline)
    }
    
    //MARK: - AMapNaviDriveManagerDelegate
    
    func driveManager(driveManager: AMapNaviDriveManager, error: NSError) {
        NSLog("error:{\(error.code) - \(error.localizedDescription)}")
    }
    
    func driveManagerOnCalculateRouteSuccess(driveManager: AMapNaviDriveManager) {
        NSLog("CalculateRouteSuccess")
        
        calRouteSuccess = true
        
        guard let route = driveManager.naviRoute else { return }
        
        showRouteWithNaviRoute(route);
    }
    
    func driveManager(driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: NSError) {
        NSLog("CalculateRouteFailure:{\(error.code) - \(error.localizedDescription)}")
    }
    
    func driveManager(driveManager: AMapNaviDriveManager, didStartNavi naviMode: AMapNaviMode) {
        NSLog("didStartNavi");
    }
    
    func driveManagerNeedRecalculateRouteForYaw(driveManager: AMapNaviDriveManager) {
        NSLog("needRecalculateRouteForYaw");
    }
    
    func driveManagerNeedRecalculateRouteForTrafficJam(driveManager: AMapNaviDriveManager) {
        NSLog("needRecalculateRouteForTrafficJam");
    }
    
    func driveManager(driveManager: AMapNaviDriveManager, onArrivedWayPoint wayPointIndex: Int32) {
        NSLog("ArrivedWayPoint:\(wayPointIndex)");
    }
    
    func driveManager(driveManager: AMapNaviDriveManager, playNaviSoundString soundString: String, soundStringType: AMapNaviSoundType) {
        NSLog("\(soundString)")
        
        if speechSynthesizer.speaking {
            speechSynthesizer.stopSpeakingAtBoundary(.Word)
        }
        
        let aUtterance = AVSpeechUtterance(string: soundString)
        aUtterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        
        speechSynthesizer.speakUtterance(aUtterance)
        
    }
    
    func driveManagerDidEndEmulatorNavi(driveManager: AMapNaviDriveManager) {
        NSLog("didEndEmulatorNavi");
    }
    
    func driveManagerOnArrivedDestination(driveManager: AMapNaviDriveManager) {
        NSLog("onArrivedDestination");
    }
    
    //MARK: - AMapNaviDriveViewDelegate
    
    func driveViewCloseButtonClicked(driveView: AMapNaviDriveView) {
        speechSynthesizer.stopSpeakingAtBoundary(.Immediate)
        
        naviManager.stopNavi()
        naviManager.removeDataRepresentative(self.driveView)
        driveView.removeFromSuperview()
        navigationController?.setToolbarHidden(false, animated: false);
    }
    
    func driveViewMoreButtonClicked(driveView: AMapNaviDriveView) {
        switch self.driveView.trackingMode {
        case .CarNorth:
            self.driveView.trackingMode = .MapNorth
        case .MapNorth:
            self.driveView.trackingMode = .CarNorth
        }
    }
    
    func driveViewTrunIndicatorViewTapped(driveView: AMapNaviDriveView) {
        naviManager.readNaviInfoManual()
    }
    
    func driveView(driveView: AMapNaviDriveView, didChangeShowMode showMode: AMapNaviDriveViewShowMode) {
        NSLog("didChangeShowMode:\(showMode)");
    }
    
    //MARK: - MAMapViewDelegate
    
    func mapView(mapView: MAMapView!, rendererForOverlay overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            let polylineRenderer = MAPolylineRenderer(overlay: overlay)
            
            polylineRenderer.lineWidth = 5.0
            polylineRenderer.strokeColor = UIColor.redColor()
            
            return polylineRenderer
        }
        return nil
    }
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let annotationIdentifier = "annotationIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as? MAPinAnnotationView
            
            if poiAnnotationView == nil {
                poiAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            poiAnnotationView!.animatesDrop   = true
            poiAnnotationView!.canShowCallout = true
            
            return poiAnnotationView;
        }
        return nil
    }
    
}
