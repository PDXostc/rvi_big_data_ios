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
@property (nonatomic)         NSNumber     *throttlePressureCachedValue;
@property (nonatomic)         NSNumber     *breakPressureCachedValue;
@property (nonatomic)         NSNumber     *speedCachedValue;
@property (nonatomic)         NSNumber     *engineRPMsCachedValue;
@property (nonatomic)         NSNumber     *bearingCachedValue;
@property (nonatomic)         NSNumber     *locationCachedValue;
@property (nonatomic)         NSNumber     *leftFrontCachedValue;
@property (nonatomic)         NSNumber     *rightFrontCachedValue;
@property (nonatomic)         NSNumber     *leftRearCachedValue;
@property (nonatomic)         NSNumber     *rightRearCachedValue;
@property (nonatomic)         NSNumber     *bitchCachedValue;
@end

@implementation Vehicle
{

}

+ (NSDictionary *)signalsMap
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    dictionary[@""] = @"throttlePressure";
    dictionary[@""] = @"breakPressure";
    dictionary[@""] = @"speed";
    dictionary[@""] = @"engineRPMs";
    dictionary[@""] = @"bearing";
    dictionary[@""] = @"location";
    dictionary[@""] = @"leftFront";
    dictionary[@""] = @"rightFront";
    dictionary[@""] = @"leftRear";
    dictionary[@""] = @"rightRear";
    dictionary[@""] = @"bitch";

    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (id)initWithVehicleId:(NSString *)vehicleId
{
    if (vehicleId == nil)
        return nil;

    if ((self = [super init]))
    {
        _vehicleId = [vehicleId copy];

        _defaultSignalsMap = [Vehicle signalsMap];


        [SignalManager getDescriptorsForSignals:[_defaultSignalsMap allKeys]];
    }

    return self;
}

+ (id)vehicleWithVehicleId:(NSString *)vehicleId
{
    return [[Vehicle alloc] initWithVehicleId:vehicleId];
}

- (NSArray *)defaultSignals
{
    return self.defaultSignalsMap.allKeys;
}

- (BOOL)isSignalDefault:(NSString *)signalName
{
    return [self.defaultSignalsMap valueForKey:signalName] != NULL;
}

- (void)updatePropertyForSignalName:(NSString *)signalName value:(NSInteger)value
{
    /* Get our Vehicle class's property string from the car's signal name. */
    NSString *propertyName = self.defaultSignalsMap[signalName];

    /* Maybe it isn't in the dictionary; return. */
    if (!propertyName) return;

    /* Get the signal object from the Vehicle instance via the name of the property using KVC. */
    Signal *signal = [self valueForKey:propertyName];

    /* If it's not null, the SignalManager has returned its descriptor data, so set its value. */
    if (signal)
        signal.signalValue = value;
    /* Otherwise, SignalManager hasn't returned its descriptor data, so just cache the value, again, using KVC. */
    else
        [self setValue:@(value) forKey:[NSString stringWithFormat:@"%@CachedValue", propertyName]];
}
@end
