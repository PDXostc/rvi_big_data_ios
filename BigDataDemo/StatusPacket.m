/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    StatusPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/2/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "StatusPacket.h"


@implementation StatusPacket
{

}
- (id)initWithVehicleId:(NSString *)vehicleId
{
    if ((self = [super initWithCommand:STATUS vehicleId:vehicleId]))
    {
    }

    return self;
}

+ (id)packetWithVehicleId:(NSString *)vehicleId
{
    return [[StatusPacket alloc] initWithVehicleId:vehicleId];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _status        = [dict[@"status"] copy];
        _numberDoors   = [((NSNumber *)dict[@"number_doors"]) integerValue];
        _numberWindows = [((NSNumber *)dict[@"number_windows"]) integerValue];
        _numberSeats   = [((NSNumber *)dict[@"number_seats"]) integerValue];
        _driverSide    = [dict[@"driver_side"] copy];
    }

    return self;
}

+ (id)packetWithDictionary:(NSDictionary *)dictionary
{
    return [[StatusPacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
