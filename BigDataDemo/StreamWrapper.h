/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    StreamWrapper.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>


@protocol StreamWrapperDelegate <NSObject>
- (void)onRemoteConnectionDidConnect;
- (void)onRemoteConnectionDidDisconnect:(NSError *)error;
- (void)onRemoteConnectionDidFailToConnect:(NSError *)error;
- (void)onRemoteConnectionDidReceiveData:(NSString *)data;
- (void)onDidSendDataToRemoteConnection:(NSString *)packet;
- (void)onDidFailToSendDataToRemoteConnection:(NSError *)error;
@end

@interface StreamWrapper : NSObject

@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic)         UInt32 serverPort;
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, weak) id<StreamWrapperDelegate> delegate;

+ (id)streamWrapper;

@end
