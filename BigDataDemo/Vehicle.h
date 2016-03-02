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

#define kVehicleThrottlePressureKeyPath @"throttlePressure"
#define kVehicleBreakPressureKeyPath    @"breakPressure"
#define kVehicleSpeedKeyPath            @"speed"
#define kVehicleEngineRPMsKeyPath       @"engineRPMs"
#define kVehicleBearingKeyPath          @"bearing"
#define kVehicleLocationKeyPath         @"location"
#define kVehicleLeftFrontKeyPath        @"leftFront"
#define kVehicleRightFrontKeyPath       @"rightFront"
#define kVehicleLeftRearKeyPath         @"leftRear"
#define kVehicleRightRearKeyPath        @"rightRear"
#define kVehicleBitchKeyPath            @"bitch"


@interface Vehicle : NSObject
@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, strong) Signal   *throttlePressure;
@property (nonatomic, strong) Signal   *breakPressure;
@property (nonatomic, strong) Signal   *speed;
@property (nonatomic, strong) Signal   *engineRPMs;
@property (nonatomic, strong) Signal   *bearing;
@property (nonatomic, strong) Signal   *location;
@property (nonatomic, strong) Signal   *leftFront;
@property (nonatomic, strong) Signal   *rightFront;
@property (nonatomic, strong) Signal   *leftRear;
@property (nonatomic, strong) Signal   *rightRear;
@property (nonatomic, strong) Signal   *bitch;

- (NSArray *)defaultSignals;
- (BOOL)isSignalDefault:(NSString *)signalName;
- (void)eventForSignalName:(NSString *)signalName attributes:(NSObject *)attributes;

- (id)init;//WithVehicleId:(NSString *)vehicleId;
+ (id)vehicle;//WithVehicleId:(NSString *)vehicleId;


@end














