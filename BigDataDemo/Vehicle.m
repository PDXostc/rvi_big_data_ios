/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover.
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    Vehicle.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "Vehicle.h"
#import "SignalManager.h"
#import "StatusPacket.h"

@interface Vehicle ()
@property (nonatomic, strong) NSDictionary *defaultSignalsMap;
@property (nonatomic, strong) NSString     *vehicleId;
@property (nonatomic)         VehicleStatus vehicleStatus;

@property (nonatomic)         NSInteger     numberDoors;
@property (nonatomic)         NSInteger     numberWindows;
@property (nonatomic)         NSInteger     numberSeats;
@property (nonatomic, strong) NSString     *driverSide;

@property (nonatomic, strong) Signal       *speed;
@property (nonatomic, strong) Signal       *engineRPMs;
@property (nonatomic, strong) Signal       *throttlePosition;
@property (nonatomic, strong) Signal       *doorStatusMS;
@property (nonatomic, strong) Signal       *passWindowPosition;
@property (nonatomic, strong) Signal       *rearPassWindowPos;
@property (nonatomic, strong) Signal       *rearDriverWindowPos;
@property (nonatomic, strong) Signal       *driverWindowPosition;
@property (nonatomic, strong) Signal       *drivSeatBeltBcklState;
@property (nonatomic, strong) Signal       *passSeatBeltBcklState;
@property (nonatomic, strong) Signal       *beltReminderSensorRL;
@property (nonatomic, strong) Signal       *beltReminderSensorRR;
@property (nonatomic, strong) Signal       *lowBeamIndication;
@property (nonatomic, strong) Signal       *mainBeamIndication;

@property (nonatomic, strong) Signal       *speedCachedAttribute;
@property (nonatomic, strong) Signal       *engineRPMsCachedAttribute;
@property (nonatomic, strong) Signal       *throttlePositionCachedAttribute;
@property (nonatomic, strong) Signal       *doorStatusMSCachedAttribute;
@property (nonatomic, strong) Signal       *passWindowPositionCachedAttribute;
@property (nonatomic, strong) Signal       *rearPassWindowPosCachedAttribute;
@property (nonatomic, strong) Signal       *rearDriverWindowPosCachedAttribute;
@property (nonatomic, strong) Signal       *driverWindowPositionCachedAttribute;
@property (nonatomic, strong) Signal       *drivSeatBeltBcklStateCachedAttribute;
@property (nonatomic, strong) Signal       *passSeatBeltBcklStateCachedAttribute;
@property (nonatomic, strong) Signal       *beltReminderSensorRLCachedAttribute;
@property (nonatomic, strong) Signal       *beltReminderSensorRRCachedAttribute;
@property (nonatomic, strong) Signal       *lowBeamIndicationCachedAttribute;
@property (nonatomic, strong) Signal       *mainBeamIndicationCachedAttribute;
@end

@implementation Vehicle
{

}

+ (NSDictionary *)signalsMap
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    dictionary[@"ThrottlePosition_MS"     ] = @"throttlePosition";
    dictionary[@"DoorStatusMS_MS"         ] = @"doorStatusMS";
    dictionary[@"PassWindowPosition_MS"   ] = @"passWindowPosition";
    dictionary[@"RearPassWindowPos_MS"    ] = @"rearPassWindowPos";
    dictionary[@"RearDriverWindowPos_MS"  ] = @"rearDriverWindowPos";
    dictionary[@"DriverWindowPosition_MS" ] = @"driverWindowPosition";
    dictionary[@"DrivSeatBeltBcklState_MS"] = @"drivSeatBeltBcklState";
    dictionary[@"PassSeatBeltBcklState_MS"] = @"passSeatBeltBcklState";
    dictionary[@"BeltReminderSensorRL_MS" ] = @"beltReminderSensorRL";
    dictionary[@"BeltReminderSensorRR_MS" ] = @"beltReminderSensorRR";
    dictionary[@"LowBeamIndication_MS"    ] = @"lowBeamIndication";
    dictionary[@"MainBeamIndication_MS"   ] = @"mainBeamIndication";

//    dictionary[@""] = @"breakPressure";
//    dictionary[@""] = @"speed";
//    dictionary[@""] = @"engineRPMs";
//    dictionary[@""] = @"bearing";
//    dictionary[@""] = @"location";
//    dictionary[@""] = @"leftFront";
//    dictionary[@""] = @"rightFront";
//    dictionary[@""] = @"leftRear";
//    dictionary[@""] = @"rightRear";
//    dictionary[@""] = @"middleRear";

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (id)init
{
    if ((self = [super init]))
    {
        _defaultSignalsMap = [Vehicle signalsMap];
    }

    return self;
}

+ (id)vehicle
{
    return [[Vehicle alloc] init];
}

- (NSString *)cachedPropertyKeyPathForPropertyNamed:(NSString *)propertyName
{
    return [NSString stringWithFormat:@"%@CachedAttributes", propertyName];
}

- (void)setVehicleId:(NSString *)newVehicleId
{
    _vehicleId = [newVehicleId copy];

    if (newVehicleId)
        [SignalManager getDescriptorsForSignalNames:[_defaultSignalsMap allKeys]
                                          vehicleId:newVehicleId
                                              block:^(NSString *signalName, NSString *vehicleId, Signal *signal) {
                                                  if (![newVehicleId isEqualToString:vehicleId])
                                                      return;

                                                  /* Get our Vehicle class's property string from the car's signalName name. */
                                                  NSString *propertyName = self.defaultSignalsMap[signalName];

                                                  /* Maybe it isn't in the dictionary; return. */
                                                  if (!propertyName) return;

                                                  /* Set the vehicle's objects property to the signal object. */
                                                  [self setValue:signal forKey:propertyName];

                                                  /* Get the cached value, if any. */
                                                  NSNumber *cachedValue = [self valueForKey:[self cachedPropertyKeyPathForPropertyNamed:propertyName]];

                                                  /* Set our signal object's value to our cached value. */
                                                  signal.currentValue = cachedValue;

                                                  /* Remove the cached value. */
                                                  [self setValue:nil forKey:[self cachedPropertyKeyPathForPropertyNamed:propertyName]];

                                              }];
}

- (NSArray *)defaultSignals
{
    return self.defaultSignalsMap.allKeys;
}

- (BOOL)isSignalDefault:(NSString *)signalName
{
    return [self.defaultSignalsMap valueForKey:signalName] != NULL;
}

- (void)eventForVehicleId:(NSString *)vehicleId signalName:(NSString *)signalName attributes:(NSDictionary *)attributes
{
#ifdef TESTING
#else
    if (![vehicleId isEqualToString:self.vehicleId])
        return;
#endif

    /* Get our Vehicle class's property string from the car's signalName name. */
    NSString *propertyName = self.defaultSignalsMap[signalName];

    /* Maybe it isn't in the dictionary; return. */
    if (!propertyName) return;

    /* Get the signal object from the Vehicle instance via the name of the property using KVC. */
    Signal *signal = [self valueForKey:propertyName];

    /* If it's not null, the SignalManager has returned its descriptor data, so set its current value. */
    if (signal)
        signal.currentValue = attributes[@"value"];
    /* Otherwise, SignalManager hasn't returned its descriptor data, so just cache the current value, again, using KVC. */
    else
        [self setValue:[attributes[@"value"] copy] forKey:[self cachedPropertyKeyPathForPropertyNamed:propertyName]];
}
@end
