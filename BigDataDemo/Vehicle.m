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

@interface Vehicle ()
@property (nonatomic, strong) NSDictionary *defaultSignalsMap;
@property (nonatomic)         NSObject     *throttlePressureCachedAttributes;
@property (nonatomic)         NSObject     *breakPressureCachedAttributes;
@property (nonatomic)         NSObject     *speedCachedAttributes;
@property (nonatomic)         NSObject     *engineRPMsCachedAttributes;
@property (nonatomic)         NSObject     *bearingCachedAttributes;
@property (nonatomic)         NSObject     *locationCachedAttributes;
@property (nonatomic)         NSObject     *leftFrontCachedAttributes;
@property (nonatomic)         NSObject     *rightFrontCachedAttributes;
@property (nonatomic)         NSObject     *leftRearCachedAttributes;
@property (nonatomic)         NSObject     *rightRearCachedAttributes;
@property (nonatomic)         NSObject     *bitchCachedAttributes;
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
//    dictionary[@""] = @"bitch";

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (id)init//WithVehicleId:(NSString *)vehicleId
{
//    if (vehicleId == nil)
//        return nil;

    if ((self = [super init]))
    {
        _defaultSignalsMap = [Vehicle signalsMap];

        //[self setVehicleId:vehicleId];
    }

    return self;
}

+ (id)vehicle//WithVehicleId:(NSString *)vehicleId
{
    return [[Vehicle alloc] init];//WithVehicleId:vehicleId];
}

- (NSString *)cachedPropertyForProperty:(NSString *)propertyName
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
                                                  {
                                                      return; // Error I suppose
                                                  }

                                                  /* Get our Vehicle class's property string from the car's signalName name. */
                                                  NSString *propertyName = self.defaultSignalsMap[signalName];

                                                  /* Maybe it isn't in the dictionary; return. */
                                                  if (!propertyName) return;

                                                  /* Set the vehicle's objects property to the signal object. */
                                                  [self setValue:signal forKey:propertyName];

                                                  /* Get the cached value, if any. */
                                                  NSObject *attributes = [self valueForKey:[self cachedPropertyForProperty:propertyName]];

                                                  /* Set our signal object's attributes to our cached value. */
                                                  signal.eventAttributes = attributes;

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

- (void)eventForSignalName:(NSString *)signalName attributes:(NSObject *)attributes
{
    /* Get our Vehicle class's property string from the car's signalName name. */
    NSString *propertyName = self.defaultSignalsMap[signalName];

    /* Maybe it isn't in the dictionary; return. */
    if (!propertyName) return;

    /* Get the signal object from the Vehicle instance via the name of the property using KVC. */
    Signal *signal = [self valueForKey:propertyName];

    /* If it's not null, the SignalManager has returned its descriptor data, so set its attributes. */
    if (signal)
        signal.eventAttributes = attributes;
    /* Otherwise, SignalManager hasn't returned its descriptor data, so just cache the attributes, again, using KVC. */
    else
        [self setValue:attributes forKey:[self cachedPropertyForProperty:propertyName]];
}
@end
