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
        case STATUS:            return @"STATUS";
        case ALL_SIGNALS:       return @"ALL_SIGNALS";
        case SIGNAL_DESCRIPTOR: return @"SIGNAL_DESCRIPTOR";
        case SUBSCRIBE:         return @"SUBSCRIBE";
        case UNSUBSCRIBE:       return @"UNSUBSCRIBE";
        case EVENT:             return @"EVENT";
        case ERROR:             return @"ERROR";
        default:                return @"";
    }
}

Command commandForString(NSString * string)
{
    if ([string isEqualToString:@"STATUS"])            return STATUS;
    if ([string isEqualToString:@"ALL_SIGNALS"])       return ALL_SIGNALS;
    if ([string isEqualToString:@"SIGNAL_DESCRIPTOR"]) return SIGNAL_DESCRIPTOR;
    if ([string isEqualToString:@"SUBSCRIBE"])         return SUBSCRIBE;
    if ([string isEqualToString:@"UNSUBSCRIBE"])       return UNSUBSCRIBE;
    if ([string isEqualToString:@"EVENT"])             return EVENT;
    if ([string isEqualToString:@"ERROR"])             return ERROR;

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
