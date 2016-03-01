/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    PacketParser.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "Util.h"

@class ServerPacket;


@protocol PacketParserDelegate <NSObject>

- (void)onPacketParsed:(ServerPacket *)packet;

@optional
- (void)onJsonStringParsed:(NSString *)jsonString;
- (void)onJsonObjectParsed:(NSObject *)jsonObject;
@end

@interface PacketParser : NSObject
@property (nonatomic, weak) id <PacketParserDelegate> delegate;

+ (id)packetParser;
- (void)parseData:(NSString *)data;
- (void)clear;
@end
