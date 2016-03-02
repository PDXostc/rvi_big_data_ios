/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    SignalDescriptorPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "SignalDescriptorPacket.h"


@implementation SignalDescriptorPacket
{

}

- (id)initWithSignal:(NSString *)signal vehicleId:(NSString *)vehicleId
{
    if (signal == nil || [signal isEqualToString:@""])
        return nil;

    if ((self = [super initWithCommand:SIGNAL_DESCRIPTOR vehicleId:vehicleId]))
    {
        _signal = [signal copy];
    }

    return self;
}

+ (id)packetWithSignal:(NSString *)signal vehicleId:(NSString *)vehicleId
{
    return [[SignalDescriptorPacket alloc] initWithSignal:signal vehicleId:vehicleId];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _signal = dict[@"signalName"];
    }

    return self;
}

+ (id)packetWithDictionary:(NSDictionary *)dictionary
{
    return [[SignalDescriptorPacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    dict[@"signalName"] = self.signal;

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
