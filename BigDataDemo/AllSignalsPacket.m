/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    AllSignalsPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "AllSignalsPacket.h"

@interface AllSignalsPacket ()
@property (nonatomic, strong) NSArray *signals;
@end

@implementation AllSignalsPacket
{

}
- (id)initWithVehicleId:(NSString *)vehicleId
{
    if ((self = [super initWithCommand:ALL_SIGNALS vehicleId:vehicleId]))
    {
    }

    return self;
}

+ (id)packetWithVehicleId:(NSString *)vehicleId
{
    return [[AllSignalsPacket alloc] initWithVehicleId:vehicleId];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _signals = dict[@"signals"];
    }

    return self;
}

+ (id)packetWithDictionary:(NSDictionary *)dictionary
{
    return [[AllSignalsPacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
