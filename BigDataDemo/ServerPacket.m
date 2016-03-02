/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    ServerPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "ServerPacket.h"

@interface ServerPacket ()
@end

@implementation ServerPacket
{

}
NSString * stringForCommand(Command command)
{
    switch (command)
    {
        case SUBSCRIBE:         return @"subscribe";
        case UNSUBSCRIBE:       return @"unsubscribe";
        case EVENT:             return @"event";
        case ALL_SIGNALS:       return @"all_signals";
        case SIGNAL_DESCRIPTOR: return @"signal_descriptor";
        case ERROR:             return @"error";
        default:                return @"";
    }
}

Command commandForString(NSString * string)
{
    if ([string isEqualToString:@"subscribe"])         return SUBSCRIBE;
    if ([string isEqualToString:@"unsubscribe"])       return UNSUBSCRIBE;
    if ([string isEqualToString:@"event"])             return EVENT;
    if ([string isEqualToString:@"all_signals"])       return ALL_SIGNALS;
    if ([string isEqualToString:@"signal_descriptor"]) return SIGNAL_DESCRIPTOR;
    if ([string isEqualToString:@"error"])             return ERROR;

    return NONE;
}


- (id)initWithCommand:(Command)command vehicleId:(NSString *)vehicleId
{
    if (command == NONE || vehicleId == nil || [vehicleId isEqualToString:@""])
        return nil;

    if ((self = [super init]))
    {
        _command   = command;
        _vehicleId = [vehicleId copy];
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }

    return self;

}

+ (id)packetWithCommand:(Command)command vehicleId:(NSString *)vehicleId
{
    return [[ServerPacket alloc] initWithCommand:command vehicleId:vehicleId];
}

- (id)initFromDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super init]))
    {
        _command   = commandForString(dict[@"cmd"]);
        _vehicleId = dict[@"vehicle_id"];
        _timestamp = [((NSNumber *)dict[@"timestamp"]) longValue];
    }

    return self;
}

+ (ServerPacket *)packetFromDictionary:(NSDictionary *)dictionary
{
    return [[ServerPacket alloc] initFromDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    return [@{@"cmd" : stringForCommand(self.command), @"vehicle_id" : self.vehicleId, @"timestamp" : @(self.timestamp) } mutableCopy];
}

@end
