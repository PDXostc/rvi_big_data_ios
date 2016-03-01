/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    ServerPacket.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>


typedef enum
{
    NONE,
    SUBSCRIBE,
    UNSUBSCRIBE,
    EVENT,
    ALL_SIGNALS,
    SIGNAL_DESCRIPTOR,
} Command;

@interface ServerPacket : NSObject
@property (nonatomic)         Command        command;
@property (nonatomic, strong) NSString      *vehicleId;
@property (nonatomic)         NSTimeInterval timestamp;

- (id)initWithCommand:(Command)command vehicleId:(NSString *)vehicleId;
+ (id)packetWithCommand:(Command)command vehicleId:(NSString *)vehicleId;

- (id)initFromDictionary:(NSDictionary *)dict;
+ (ServerPacket *)packetFromDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;
@end
