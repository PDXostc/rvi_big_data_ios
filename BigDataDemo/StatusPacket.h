/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    StatusPacket.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/2/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "ServerPacket.h"


@interface StatusPacket : ServerPacket
@property (nonatomic, strong) NSString *status;
@property (nonatomic)         NSInteger numberDoors;
@property (nonatomic)         NSInteger numberWindows;
@property (nonatomic)         NSInteger numberSeats;
@property (nonatomic)         NSString *driverSide;

- (id)initWithVehicleId:(NSString *)vehicleId;
+ (id)packetWithVehicleId:(NSString *)vehicleId;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)packetWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;
@end
