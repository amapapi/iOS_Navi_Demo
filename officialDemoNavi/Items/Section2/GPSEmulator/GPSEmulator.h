//
//  GPSEmulator.h
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/14.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^AMapNaviEmulatorLocationBlock)(CLLocation *location, NSUInteger index, NSDate *addedTime, BOOL *stop);

@interface GPSEmulator : NSObject

@property (nonatomic, readonly) BOOL isSimulating;

- (void)startEmulatorUsingLocationBlock:(AMapNaviEmulatorLocationBlock)locationBlock;;
- (void)stopEmulator;

@end
