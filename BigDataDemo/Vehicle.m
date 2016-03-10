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
@property (nonatomic, strong) NSObject     *throttlePressureCachedAttributes;
@property (nonatomic, strong) NSObject     *breakPressureCachedAttributes;
@property (nonatomic, strong) NSObject     *speedCachedAttributes;
@property (nonatomic, strong) NSObject     *engineRPMsCachedAttributes;
@property (nonatomic, strong) NSObject     *bearingCachedAttributes;
@property (nonatomic, strong) NSObject     *locationCachedAttributes;
@property (nonatomic, strong) NSObject     *leftFrontCachedAttributes;
@property (nonatomic, strong) NSObject     *rightFrontCachedAttributes;
@property (nonatomic, strong) NSObject     *leftRearCachedAttributes;
@property (nonatomic, strong) NSObject     *rightRearCachedAttributes;
@property (nonatomic, strong) NSObject     *middleRearCachedAttributes;
@property (nonatomic, strong) NSString     *vehicleId;
@property (nonatomic, strong) Signal       *speed;
@property (nonatomic, strong) Signal       *engineRPMs;
@property (nonatomic, strong) Signal       *throttlePressure;
@property (nonatomic, strong) Signal       *breakPressure;
@property (nonatomic, strong) Signal       *bearing;
@property (nonatomic, strong) Signal       *location;
@property (nonatomic, strong) Signal       *leftFront;
@property (nonatomic, strong) Signal       *rightFront;
@property (nonatomic, strong) Signal       *leftRear;
@property (nonatomic, strong) Signal       *rightRear;
@property (nonatomic, strong) Signal       *middleRear;

@property (nonatomic)         NSInteger     numberDoors;
@property (nonatomic)         NSInteger     numberWindows;
@property (nonatomic)         NSInteger     numberSeats;
@property (nonatomic, strong) NSString     *driverSide;

@property (nonatomic)         VehicleStatus vehicleStatus;
@end

@implementation Vehicle
{

}

+ (NSDictionary *)signalsMap
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    dictionary[@"ThrottlePosition_MS"] = @"throttlePressure";
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
