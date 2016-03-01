/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    SignalsPacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "SignalsPacket.h"

@interface SignalsPacket ()
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSArray  *signals;
@end

@implementation SignalsPacket
{

}
- (id)initWithAction:(NSString *)action vehicleId:(NSString *)vehicleId
{
    if (action == nil || [action isEqualToString:@""])
        return nil;

    if ((self = [super initWithCommand:SIGNALS vehicleId:vehicleId]))
    {
        _action = [action copy];
    }

    return self;
}

+ (id)packetWithAction:(NSString *)action vehicleId:(NSString *)vehicleId
{
    return [[SignalsPacket alloc] initWithAction:action vehicleId:vehicleId];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (dict == nil)
        return nil;

    if ((self = [super initFromDictionary:dict]))
    {
        _action = dict[@"action"];
        _signals = dict[@"signals"];
    }

    return self;
}

+ (id)packetWithDictionary:(NSDictionary *)dictionary
{
    return [[SignalsPacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    dict[@"action"] = self.action;

    return [NSDictionary dictionaryWithDictionary:dict];
}
@end
