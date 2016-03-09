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
#import "Signal.h"
#import "SubscribePacket.h"
#import "AllSignalsPacket.h"
#import "UnsubscribePacket.h"
#import "EventPacket.h"

@interface CallbackData : NSObject
@property (nonatomic, strong) NSString      *signalName;
@property (nonatomic, strong) NSString      *vehicleId;
@property (nonatomic, copy)   CallbackBlock  callback;
@end

@implementation CallbackData
- (id)initWithSignalName:(NSString *)signalName vehicleId:(id)vehicleId callbackBlock:(CallbackBlock)callbackBlock
{
    if ((signalName == nil) || (vehicleId == nil) || (callbackBlock == nil))
        return nil;

    if ((self = [super init]))
    {
        _signalName = [signalName copy];
        _vehicleId  = [vehicleId copy];
        _callback   = [callbackBlock copy];

    }

    return self;
}

+ (id)callbackDataWithSignalName:(NSString *)signalName vehicleId:(id)vehicleId callbackBlock:(CallbackBlock)callbackBlock
{
    return [[CallbackData alloc] initWithSignalName:signalName vehicleId:vehicleId callbackBlock:callbackBlock];
}
@end

@interface SignalManager ()
@property (nonatomic, weak)   id<SignalManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary      *ongoingSignalDescriptorRequests;
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

//        _sharedManager.pendingSignalDescriptorRequests = [NSMutableDictionary dictionary];
        _sharedManager.ongoingSignalDescriptorRequests = [NSMutableDictionary dictionary];
    });

    return _sharedManager;
}

+ (void)start
{
    [[SignalManager sharedManager] registerObservers];
}

+ (void)getDescriptorsForSignalNames:(NSArray *)signalNames vehicleId:(NSString *)vehicleId block:(CallbackBlock)callbackBlock
{
    for (NSString *signalName in signalNames)
    {
        // TODO: Check if data is cached
        if (false) { }
        else
        {
            SignalDescriptorPacket *packet = [SignalDescriptorPacket packetWithSignal:signalName vehicleId:vehicleId];
            CallbackData *data = [CallbackData callbackDataWithSignalName:signalName vehicleId:vehicleId callbackBlock:callbackBlock];

            [[SignalManager sharedManager] ongoingSignalDescriptorRequests][signalName] = data;
            [BackendServerManager sendPacket:packet];
        }
    }
//
//
//    if ([BackendServerManager isConnected])
//        [[SignalManager sharedManager] tryAndSendPackets];
}

+ (void)setDelegate:(id <SignalManagerDelegate>)delegate
{
    [[SignalManager sharedManager] setDelegate:delegate];
}

+ (void)subscribeToSignal:(NSString *)signal forVehicle:(NSString *)vehicleId
{
    DLog(@"");

    [BackendServerManager sendPacket:[SubscribePacket packetWithSignals:@[signal]
                                                              vehicleId:vehicleId]];
}

+ (void)unsubscribeFromSignal:(NSString *)signal forVehicle:(NSString *)vehicleId
{
    DLog(@"");

    [BackendServerManager sendPacket:[UnsubscribePacket packetWithSignals:@[signal]
                                                                vehicleId:vehicleId]];
}

+ (void)getAllSignalsForVehicle:(NSString *)vehicleId
{
    DLog(@"");

    [BackendServerManager sendPacket:[AllSignalsPacket packetWithVehicleId:vehicleId]];
}

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


- (void)processSignalDescriptorPacket:(SignalDescriptorPacket *)signalDescriptorPacket
{
    NSString     *signalName    = signalDescriptorPacket.signal;
    NSString     *vehicleId     = signalDescriptorPacket.vehicleId;
    CallbackData *callbackData  = self.ongoingSignalDescriptorRequests[signalName];

    Signal       *signal        = [Signal signalWithSignalName:signalName descriptorDictionary:signalDescriptorPacket.descriptor];
    CallbackBlock callbackBlock = callbackData.callback;

    callbackBlock(signalName, vehicleId, signal);

    [self.ongoingSignalDescriptorRequests removeObjectForKey:signalName];
}

- (void)processAllSignalsPacket:(AllSignalsPacket *)allSignalsPacket
{
    [self.delegate signalManagerDidGetAllSignals:allSignalsPacket.signals forVehicle:allSignalsPacket.vehicleId];
}

- (void)processEventPacket:(EventPacket *)eventPacket
{
    [self.delegate signalManagerDidReceiveEventForVehicle:eventPacket.vehicleId signalName:eventPacket.signal attributes:eventPacket.attributes];
}

- (void)backendServerDidReceiveData:(NSNotification *)notification
{
    DLog(@"");

    NSDictionary *userInfo = notification.userInfo;
    ServerPacket *packet   = userInfo[kBackendServerNotificationPacketKey];

    if ([packet isKindOfClass:[SignalDescriptorPacket class]])
    {
        [self processSignalDescriptorPacket:(SignalDescriptorPacket *)packet];
    }
    else if ([packet isKindOfClass:[AllSignalsPacket class]])
    {
        [self processAllSignalsPacket:(AllSignalsPacket *)packet];
    }
    else if ([packet isKindOfClass:[EventPacket class]])
    {
        [self processEventPacket:(EventPacket *)packet];
    }
    else if ([packet isKindOfClass:[ErrorPacket class]])
    {
        ; // TODO: Error
    }
}
@end
