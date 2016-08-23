//
//  GPSEmulator.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/14.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "GPSEmulator.h"

#define kAMapNaviEmulatorLocationKey            @"AMapNaviEmulatorLocations"
#define kAMapNaviEmulatorLocationAddedTimeKey   @"AMapNaviEmulatorLocationsAddedTimes"

@interface GPSEmulator ()
{
    NSMutableArray *_locations;
    NSMutableArray *_locationAddedTimes;
    
    NSThread *_locationsThread;
}

@property (nonatomic, readwrite) BOOL isSimulating;

@end

@implementation GPSEmulator

- (id)init
{
    if (self = [super init])
    {
        _locations = [NSMutableArray array];
        _locationAddedTimes = [NSMutableArray array];
        
        [self reloadFromFile];
        
        _isSimulating = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [self stopEmulator];
}

#pragma mark - Helper

- (void)locationsHandleBlock:(AMapNaviEmulatorLocationBlock)block
{
    BOOL shouldStop = NO;
    NSUInteger index = 0;
    CLLocation *location = nil;
    NSDate *addedTime = nil;
    
    while (!shouldStop && index < _locations.count && _locationsThread && ![_locationsThread isCancelled])
    {
        NSDate *currentTime = _locationAddedTimes[index];
        NSTimeInterval timeInterval = [currentTime timeIntervalSinceDate:addedTime];
        
        location = _locations[index];
        addedTime = currentTime;
        
        [NSThread sleepForTimeInterval:timeInterval];
        
        block(location, index, addedTime, &shouldStop);
        
        ++index;
    }
    
    _isSimulating = NO;
    NSLog(@"Stop Location Update");
}

#pragma mark - Interface

- (void)startEmulatorUsingLocationBlock:(AMapNaviEmulatorLocationBlock)locationBlock
{
    if (locationBlock == nil || _isSimulating)
    {
        return;
    }
    
    if (_locationsThread)
    {
        [_locationsThread cancel];
        _locationsThread = nil;
    }
    
    _isSimulating = YES;
    
    if (locationBlock)
    {
        _locationsThread = [[NSThread alloc] initWithTarget:self selector:@selector(locationsHandleBlock:) object:locationBlock];
        [_locationsThread setName:@"AMapNaviEmulatorLocationsThread"];
        [_locationsThread start];
    }
}

- (void)stopEmulator
{
    if (_locationsThread)
    {
        [_locationsThread cancel];
        _locationsThread = nil;
    }
    
    _isSimulating = NO;
}

#pragma mark - Load File

- (BOOL)reloadFromFile
{
    [_locations removeAllObjects];
    [_locationAddedTimes removeAllObjects];
    
    NSString *locationName = [[NSBundle mainBundle] pathForResource:kAMapNaviEmulatorLocationKey ofType:nil];
    NSString *locationsTimesName = [[NSBundle mainBundle] pathForResource:kAMapNaviEmulatorLocationAddedTimeKey ofType:nil];
    
    @try
    {
        id unarchiveLocations = [NSKeyedUnarchiver unarchiveObjectWithFile:locationName];
        if ([unarchiveLocations isKindOfClass:[NSArray class]])
        {
            [_locations addObjectsFromArray:unarchiveLocations];
        }
        
        id unarchiveLocationsTimes = [NSKeyedUnarchiver unarchiveObjectWithFile:locationsTimesName];
        if ([unarchiveLocationsTimes isKindOfClass:[NSArray class]])
        {
            [_locationAddedTimes addObjectsFromArray:unarchiveLocationsTimes];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Unarchive Exception: %@", exception.reason);
        return NO;
    }
    @finally
    {
        
    }
    
    return YES;
}

@end
