/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    ErrorPacket.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/2/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "ServerPacket.h"


@interface ErrorPacket : ServerPacket
@property (nonatomic, strong) NSObject     *signal;
@property (nonatomic, strong) NSString     *errorMessage;
@property (nonatomic, strong) NSDictionary *originalCommand;

- (id)initWithDictionary:(NSDictionary *)dict;
+ (id)packetWithDictionary:(NSDictionary *)dictionary;
@end
