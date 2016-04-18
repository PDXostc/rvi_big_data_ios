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

#define kVehicleSpeedKeyPath                        @"speed"
#define kVehicleEngineRPMsKeyPath                   @"engineRPMs"
#define kVehicleThrottlePositionKeyPath             @"throttlePosition"
#define kVehicleSteeringWheelAngleKeyPath           @"steeringWheelAngle"
#define kVehicleBearingKeyPath                      @"bearing"
#define kVehicleLocationKeyPath                     @"location"
#define kVehicleDoorStatusKeyPath                   @"doorStatus"
#define kVehicleDriverWindowPositionKeyPath         @"driverWindowPosition"
#define kVehiclePassengerWindowPositionKeyPath      @"passengerWindowPosition"
#define kVehicleRearDriverWindowPositionKeyPath     @"rearDriverWindowPosition"
#define kVehicleRearPassengerWindowPositionKeyPath  @"rearPassengerWindowPosition"
#define kVehicleDriverSeatBeltBuckleStateKeyPath    @"driverSeatBeltBuckleState"
#define kVehiclePassengerSeatBeltBuckleStateKeyPath @"passengerSeatBeltBuckleState"
#define kVehicleBeltReminderSensorLRKeyPath         @"beltReminderSensorLR"
#define kVehicleBeltReminderSensorRRKeyPath         @"beltReminderSensorRR"
#define kVehicleLowBeamIndicationKeyPath            @"lowBeamIndication"
#define kVehicleMainBeamIndicationKeyPath           @"mainBeamIndication"

#define kVehicleNumberDoorsKeyPath                  @"numberDoors"
#define kVehicleNumberWindowsKeyPath                @"numberWindows"
#define kVehicleNumberSeatsKeyPath                  @"numberSeats"
#define kVehicleDriverSideKeyPath                   @"driverSide"

#define kVehicleVehicleStatusKeyPath                @"vehicleStatus"

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
@property (nonatomic, strong, readonly) Signal    *throttlePosition;
@property (nonatomic, strong, readonly) Signal    *steeringWheelAngle;
@property (nonatomic, strong, readonly) Signal    *bearing;
@property (nonatomic, strong, readonly) Signal    *location;

@property (nonatomic, strong, readonly) Signal    *doorStatus;
@property (nonatomic, strong, readonly) Signal    *driverWindowPosition;
@property (nonatomic, strong, readonly) Signal    *passengerWindowPosition;
@property (nonatomic, strong, readonly) Signal    *rearDriverWindowPosition;
@property (nonatomic, strong, readonly) Signal    *rearPassengerWindowPosition;
@property (nonatomic, strong, readonly) Signal    *driverSeatBeltBuckleState;    /* 0 is not latched, 1 is latched */
@property (nonatomic, strong, readonly) Signal    *passengerSeatBeltBuckleState;
@property (nonatomic, strong, readonly) Signal    *beltReminderSensorLR;         /* 1 for seated (and not latched?), 0 for not seated */
@property (nonatomic, strong, readonly) Signal    *beltReminderSensorRR;
@property (nonatomic, strong, readonly) Signal    *lowBeamIndication;
@property (nonatomic, strong, readonly) Signal    *mainBeamIndication;

@property (nonatomic, readonly)         NSInteger  numberDoors;
@property (nonatomic, readonly)         NSInteger  numberWindows;
@property (nonatomic, readonly)         NSInteger  numberSeats;
@property (nonatomic, strong, readonly) NSString  *driverSide;

@property (nonatomic, readonly)         VehicleStatus vehicleStatus;

- (NSArray *)defaultSignals;
- (BOOL)isSignalDefault:(NSString *)signalName;
- (void)eventForVehicleId:(NSString *) vehicleId signalName:(NSString *)signalName attributes:(NSDictionary *)attributes;
@end














