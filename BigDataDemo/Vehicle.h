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

@interface RVIRangeSignal : NSObject
@property (nonatomic, strong) NSNumber *low;
@property (nonatomic, strong) NSNumber *high;
@property (nonatomic, strong) NSNumber *step;
@property (nonatomic, strong) NSNumber *value;
@end

@interface RVIGPSSignal : NSObject
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@end


@interface RVISeatSignal : NSObject
@property (nonatomic, strong) RVIRangeSignal *position;
@property (nonatomic)         BOOL           *isDriver;
@property (nonatomic)         BOOL           *isOccupied;
@end


@interface Vehicle : NSObject
@property (nonatomic, strong) RVIRangeSignal *throttlePressure;
@property (nonatomic, strong) RVIRangeSignal *breakPressure;
@property (nonatomic, strong) RVIRangeSignal *speed;
@property (nonatomic, strong) RVIRangeSignal *engineRPMs;
@property (nonatomic, strong) RVIRangeSignal *bearing;
@property (nonatomic, strong) RVIGPSSignal   *location;
@property (nonatomic, strong) RVISeatSignal  *leftFront;
@property (nonatomic, strong) RVISeatSignal  *rightFront;
@property (nonatomic, strong) RVISeatSignal  *leftRear;
@property (nonatomic, strong) RVISeatSignal  *rightRear;
@property (nonatomic, strong) RVISeatSignal  *bitch;


@end
