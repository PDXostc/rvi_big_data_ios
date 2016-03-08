/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    SignalDescriptorPacket.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "ServerPacket.h"


@interface SignalDescriptorPacket : ServerPacket
@property (nonatomic, strong) NSString     *signal;
@property (nonatomic, strong) NSDictionary *descriptor;

- (id)initWithSignal:(NSString *)signal vehicleId:(NSString *)vehicleId;
+ (id)packetWithSignal:(NSString *)signal vehicleId:(NSString *)vehicleId;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)packetWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;
@end
