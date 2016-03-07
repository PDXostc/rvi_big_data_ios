/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    EventPacket.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "ServerPacket.h"


@interface EventPacket : ServerPacket
@property (nonatomic, strong) NSObject     *attributes;
@property (nonatomic, strong) NSString     *event;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString     *source;
@property (nonatomic, strong) NSString     *signal;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)packetWithDictionary:(NSDictionary *)dictionary;
@end
