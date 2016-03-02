/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    ErrorPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/2/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "ErrorPacket.h"


@implementation ErrorPacket
{

}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _signal           = dict[@"signal"];
        _errorMessage     = dict[@"error_message"];
        _originalCommand  = dict[@"original_command"];
    }

    return self;
}

+ (id)packetWithDictionary:(NSDictionary *)dictionary
{
    return [[ErrorPacket alloc] initWithDictionary:dictionary];
}
@end
