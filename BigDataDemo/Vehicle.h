/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover.
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    Vehicle.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "Signal.h"

#define kVehicleSpeedKeyPath            @"speed"
#define kVehicleEngineRPMsKeyPath       @"engineRPMs"
#define kVehicleThrottlePressureKeyPath @"throttlePressure"
#define kVehicleBreakPressureKeyPath    @"breakPressure"
#define kVehicleBearingKeyPath          @"bearing"
#define kVehicleLocationKeyPath         @"location"
#define kVehicleLeftFrontKeyPath        @"leftFront"
#define kVehicleRightFrontKeyPath       @"rightFront"
#define kVehicleLeftRearKeyPath         @"leftRear"
#define kVehicleRightRearKeyPath        @"rightRear"
#define kVehicleMiddleRearKeyPath       @"middleRear"

#define kVehicleNumberDoorsKeyPath      @"numberDoors"
#define kVehicleNumberWindowsKeyPath    @"numberWindows"
#define kVehicleNumberSeatsKeyPath      @"numberSeats"
#define kVehicleDriverSideKeyPath       @"driverSide"

#define kVehicleVehicleStatusKeyPath    @"vehicleStatus"

typedef enum
{
    VEHICLE_STATUS_UNKNOWN,
    VEHICLE_STATUS_CONNECTED,
    VEHICLE_STATUS_NOT_CONNECTED,
    VEHICLE_STATUS_INVALID_ID
} VehicleStatus;

@interface Vehicle : NSObject
@property (nonatomic, strong, readonly) NSString  *vehicleId;
@property (nonatomic, strong, readonly) Signal    *speed;
@property (nonatomic, strong, readonly) Signal    *engineRPMs;
@property (nonatomic, strong, readonly) Signal    *throttlePressure;
@property (nonatomic, strong, readonly) Signal    *breakPressure;
@property (nonatomic, strong, readonly) Signal    *bearing;
@property (nonatomic, strong, readonly) Signal    *location;
@property (nonatomic, strong, readonly) Signal    *leftFront;
@property (nonatomic, strong, readonly) Signal    *rightFront;
@property (nonatomic, strong, readonly) Signal    *leftRear;
@property (nonatomic, strong, readonly) Signal    *rightRear;
@property (nonatomic, strong, readonly) Signal    *middleRear;

@property (nonatomic, readonly)         NSInteger  numberDoors;
@property (nonatomic, readonly)         NSInteger  numberWindows;
@property (nonatomic, readonly)         NSInteger  numberSeats;
@property (nonatomic, strong, readonly) NSString  *driverSide;

@property (nonatomic, readonly)         VehicleStatus vehicleStatus;

- (NSArray *)defaultSignals;
- (BOOL)isSignalDefault:(NSString *)signalName;
- (void)eventForVehicleId:(NSString *) vehicleId signalName:(NSString *)signalName attributes:(NSDictionary *)attributes;
@end














