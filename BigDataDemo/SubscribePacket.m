/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    SubscribePacket.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "SubscribePacket.h"

@interface SubscribePacket ()
@property (nonatomic, strong) NSArray  *signals;
@end


@implementation SubscribePacket
{

}
- (id)initWithSignals:(NSArray *)signals vehicleId:(NSString *)vehicleId
{
    if (signals == nil)
        return nil;

    if ((self = [super initWithCommand:SUBSCRIBE vehicleId:vehicleId]))
    {
        _signals = [signals copy];
    }

    return self;
}

+ (id)packetWithSignals:(NSArray *)signals vehicleId:(NSString *)vehicleId
{
    return [[SubscribePacket alloc] initWithSignals:signals vehicleId:vehicleId];
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
    return [[SubscribePacket alloc] initWithDictionary:dictionary];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];

    dict[@"signals"] = self.signals;

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
