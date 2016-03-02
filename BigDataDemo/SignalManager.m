/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    SignalManager.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "SignalManager.h"
#import "BackendServerManager.h"
#import "SignalDescriptorPacket.h"
#import "Util.h"
#import "ErrorPacket.h"

@interface SignalManager ()
@property (nonatomic, strong) NSMutableDictionary *pendingSignalDescriptorRequests;
@property (nonatomic, strong) NSMutableDictionary *ongoingSignalDescriptorRequests;
@end

@implementation SignalManager
{

}

+ (id)sharedManager
{
    static SignalManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[SignalManager alloc] init];

        _sharedManager.pendingSignalDescriptorRequests = [NSMutableDictionary dictionary];
        _sharedManager.ongoingSignalDescriptorRequests = [NSMutableDictionary dictionary];
    });

    return _sharedManager;
}

+ (void)start
{
    [[SignalManager sharedManager] registerObservers];
}

+ (void)getDescriptorsForSignals:(NSArray *)signals vehicleId:(NSString *)vehicleId
{
//    for (NSString *signal in signals)
//    {
//        SignalDescriptorPacket *packet = [SignalDescriptorPacket packetWithSignal:signal vehicleId:vehicleId];
//        [[SignalManager sharedManager] pendingSignalDescriptorRequests][signal] = packet;
//    }
//
//
//    if ([BackendServerManager isConnected])
//        [[SignalManager sharedManager] tryAndSendPackets];
}

//- (void)tryAndSendPackets
//{
//    NSArray *signals = [self.pendingSignalDescriptorRequests allKeys];
//
//    for (NSString *signal in signals)
//    {
//        [self.pendingSignalDescriptorRequests o
//        self.ongoingSignalDescriptorRequests[signal]
//    }
//}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidConnect:)
                                                 name:kBackendServerDidConnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidDisconnect:)
                                                 name:kBackendServerDidDisconnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidReceiveData:)
                                                 name:kBackendServerDidReceivePacketNotification
                                               object:nil];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
//}

- (void)backendServerDidConnect:(NSNotification *)notification
{
    DLog(@"");

    /* Move all pending requests to ongoing requests */
}

- (void)backendServerDidDisconnect:(NSNotification *)notification
{
    DLog(@"");

    /* Move all ongoing requests to pending requests? Or drop them? */
}

- (void)backendServerDidReceiveData:(NSNotification *)notification
{
    DLog(@"");

    NSDictionary *userInfo = notification.userInfo;
    ServerPacket *packet = userInfo[kBackendServerNotificationPacketKey];

    if ([packet isKindOfClass:[SignalDescriptorPacket class]])
    {

    }
    else if ([packet isKindOfClass:[ErrorPacket class]])
    {

    }
}
@end
