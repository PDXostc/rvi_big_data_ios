/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    BackendServerManager.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>


extern NSString *const kBackendServerWillConnectNotification;
extern NSString *const kBackendServerDidConnectNotification;
extern NSString *const kBackendServerDidFailToConnectNotification;
extern NSString *const kBackendServerDidDisconnectNotification;
extern NSString *const kBackendServerDidSendDataNotification;
extern NSString *const kBackendServerCommunicationDidFailNotification;
extern NSString *const kBackendServerDidReceivePacketNotification;
extern NSString *const kBackendServerNotificationPacketKey;
extern NSString *const kBackendServerNotificationErrorKey;

@class ServerPacket;
@interface BackendServerManager : NSObject
+ (void)stop;
+ (void)start;
+ (void)restart;
+ (BOOL)isConnected;
+ (void)sendPacket:(ServerPacket *)packet;
@end
