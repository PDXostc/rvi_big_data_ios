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
#import "StatusPacket.h"
#import "ErrorPacket.h"

@interface VehicleManager ()
@property (nonatomic, strong) Vehicle *vehicle;
@end

@implementation VehicleManager
{

}

//+ (NSArray *)defaultSignals
//{
//    return @[@"foo", @"bar", @"baz"];
//}

+ (id)sharedManager
{
    static VehicleManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[VehicleManager alloc] init];

        _sharedManager.vehicle = [[Vehicle alloc] init];//WithVehicleId:[ConfigurationDataManager getVehicleId]];
    });

    return _sharedManager;
}

+ (void)start
{
    [[VehicleManager sharedManager] registerObservers];
}

- (void)getStatusForVehicle:(NSString *)vehicleId
{
    [self.vehicle setVehicleStatus:UNKNOWN];
    [BackendServerManager sendPacket:[StatusPacket packetWithVehicleId:vehicleId]];
}

- (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    [self.vehicle setVehicleId:vehicleId];
    [BackendServerManager sendPacket:[SubscribePacket packetWithSignals:[self.vehicle defaultSignals]
                                                              vehicleId:vehicleId]];
}

- (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    [self.vehicle setVehicleId:NULL];
    [BackendServerManager sendPacket:[UnsubscribePacket packetWithSignals:[self.vehicle defaultSignals]
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

+ (Vehicle *)vehicle
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerCommunicationDidFail:)
                                                 name:kBackendServerCommunicationDidFailNotification
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
        [self unsubscribeDefaultsForVehicle:change[NSKeyValueChangeOldKey]];
        [self getStatusForVehicle:change[NSKeyValueChangeNewKey]];
    }
}

- (void)backendServerDidConnect:(NSNotification *)notification
{
    DLog(@"");

    [self getStatusForVehicle:[ConfigurationDataManager getVehicleId]];
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

    /* If for any reason, the currently saved vehicle id doesn't match the one in the packet,
     * just ignore the packet. */
    if (![packet.vehicleId isEqualToString:[ConfigurationDataManager getVehicleId]])
        return;

    if ([packet isKindOfClass:[StatusPacket class]])
    {
        StatusPacket *statusPacket = (StatusPacket *)packet;

        // TODO: Add a variable to report vehicle status to UI through KVO

        /* If our vehicle id is good, set the vehicle's property (so it fetches the signalName descriptor stuff) and subscribe. */
        if ([[statusPacket status] isEqualToString:@"INVALID"])
        {
            self.vehicle.vehicleStatus = INVALID_ID;
        }
        else
        {
            [self resubscribeDefaultsForVehicle:statusPacket.vehicleId];

            if ([[statusPacket status] isEqualToString:@"CONNECTED"])
                self.vehicle.vehicleStatus = CONNECTED;
            else if ([[statusPacket status] isEqualToString:@"NOT_CONNECTED"])
                self.vehicle.vehicleStatus = NOT_CONNECTED;

            self.vehicle.numberDoors   = statusPacket.numberDoors;
            self.vehicle.numberWindows = statusPacket.numberWindows;
            self.vehicle.numberSeats   = statusPacket.numberSeats;
            self.vehicle.driversSide   = statusPacket.driversSide;
        }
    }
    else if ([packet isKindOfClass:[EventPacket class]])
    {
        EventPacket *eventPacket = (EventPacket *)packet;

        if ([self.vehicle isSignalDefault:eventPacket.event])
            [self.vehicle eventForSignalName:eventPacket.event attributes:eventPacket.attributes];
        else ; /* We have an event for a signalName that isn't default... pass it along to the UI class that's looking for it??? */

    }
    else if ([packet isKindOfClass:[ErrorPacket class]])
    {
        ; /* No-op for now */
    }
}

- (void)backendServerCommunicationDidFail:(NSNotification *)notification
{
    DLog(@"");
}
@end
