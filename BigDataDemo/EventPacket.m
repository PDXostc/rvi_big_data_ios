/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    EventPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "EventPacket.h"


@interface EventPacket ()

@end

@implementation EventPacket
{

}
- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _attributes = dict[@"attributes"];
        _event      = dict[@"event"];
        _location   = dict[@"location"];
        _source     = dict[@"source"];
        _signal     = dict[@"signal"];
    }

    return self;
}

+ (id)packetWithDictionary:(NSDictionary *)dictionary
{
    return [[EventPacket alloc] initWithDictionary:dictionary];
}
@end
