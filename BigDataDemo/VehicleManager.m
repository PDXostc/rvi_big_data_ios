/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    VehicleManager.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/29/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "VehicleManager.h"
#import "ConfigurationDataManager.h"
#import "Util.h"
#import "BackendServerManager.h"
#import "Vehicle.h"
#import "ServerPacket.h"
#import "UnsubscribePacket.h"
#import "SubscribePacket.h"
#import "AllSignalsPacket.h"
#import "EventPacket.h"

@interface VehicleManager ()
@property (nonatomic, strong) Vehicle *vehicle;
@end

@implementation VehicleManager
{

}

+ (NSArray *)defaultSignals
{
    return @[@"foo", @"bar", @"baz"];
}

+ (id)sharedManager
{
    static VehicleManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[VehicleManager alloc] init];

        _sharedManager.vehicle = [[Vehicle alloc] initWithVehicleId:[ConfigurationDataManager getVehicleId]];
    });

    return _sharedManager;
}

+ (void)start
{
    [[VehicleManager sharedManager] registerObservers];
}

+ (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    [BackendServerManager sendPacket:[SubscribePacket packetWithSignals:[VehicleManager defaultSignals]
                                                              vehicleId:vehicleId]];
}

+ (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    [BackendServerManager sendPacket:[UnsubscribePacket packetWithSignals:[VehicleManager defaultSignals]
                                                                vehicleId:vehicleId]];
}

+ (void)subscribeToSignal:(NSString *)signal
{
    [BackendServerManager sendPacket:[SubscribePacket packetWithSignals:@[signal]
                                                              vehicleId:[ConfigurationDataManager getVehicleId]]];
}

+ (void)unsubscribeFromSignal:(NSString *)signal
{
    [BackendServerManager sendPacket:[UnsubscribePacket packetWithSignals:@[signal]
                                                                vehicleId:[ConfigurationDataManager getVehicleId]]];
}

+ (void)getAllSignals
{
    [BackendServerManager sendPacket:[AllSignalsPacket packetWithVehicleId:[ConfigurationDataManager getVehicleId]]];
}

+ (Vehicle *)getVehicle
{
    return [[VehicleManager sharedManager] vehicle];
}

- (void)registerObservers
{
    [ConfigurationDataManager addObserver:self
                               forKeyPath:kConfigurationDataManagerVehicleIdKeyPath
                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:NULL];

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
    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerVehicleIdKeyPath];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kConfigurationDataManagerVehicleIdKeyPath]) {
        [self.vehicle setVehicleId:change[NSKeyValueChangeNewKey]];
        [VehicleManager unsubscribeDefaultsForVehicle:change[NSKeyValueChangeOldKey]];
        [VehicleManager resubscribeDefaultsForVehicle:change[NSKeyValueChangeNewKey]];
    }
}

- (void)backendServerDidConnect:(NSNotification *)notification
{
    DLog(@"");
    [VehicleManager resubscribeDefaultsForVehicle:[ConfigurationDataManager getVehicleId]];
}

- (void)backendServerDidDisconnect:(NSNotification *)notification
{
    DLog(@"");
}

- (void)backendServerDidReceiveData:(NSNotification *)notification
{
    DLog(@"");

    NSDictionary *userInfo = notification.userInfo;
    ServerPacket *packet = userInfo[kBackendServerNotificationPacketKey];

    if ([packet isKindOfClass:[EventPacket class]])
    {
        EventPacket *eventPacket = (EventPacket *)packet;

        if ([self.vehicle isSignalDefault:eventPacket.event])
            [self.vehicle eventForSignalName:eventPacket.event attributes:eventPacket.attributes];
        else ; /* We have an event for a signal that isn't default... pass it along to the UI class that's looking for it??? */

    }
}
@end
