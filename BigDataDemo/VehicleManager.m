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

@interface Vehicle (MANAGER_ACCESS_ONLY)
@property (nonatomic)         NSInteger     numberDoors;
@property (nonatomic)         NSInteger     numberWindows;
@property (nonatomic)         NSInteger     numberSeats;
@property (nonatomic, strong) NSString     *driverSide;
@property (nonatomic, strong) NSString     *vehicleId;
@property (nonatomic)         VehicleStatus vehicleStatus;
- (id)init;
+ (id)vehicle;
@end

@implementation Vehicle (MANAGER_ACCESS_ONLY)
@end

@interface VehicleManager ()
@property (nonatomic, strong) Vehicle *vehicle;
@end

@implementation VehicleManager
{

}

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
    DLog(@"");

    [[VehicleManager sharedManager] registerObservers];
}

- (void)getStatusForVehicle:(NSString *)vehicleId
{
    DLog(@"");

    [self.vehicle setVehicleStatus:VEHICLE_STATUS_UNKNOWN];
    [BackendServerManager sendPacket:[StatusPacket packetWithVehicleId:vehicleId]];
}

- (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    DLog(@"");

    [self.vehicle setVehicleId:vehicleId];
    [BackendServerManager sendPacket:[SubscribePacket packetWithSignals:[self.vehicle defaultSignals]
                                                              vehicleId:vehicleId]];
}

- (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    DLog(@"");

    [self.vehicle setVehicleId:NULL];
    [BackendServerManager sendPacket:[UnsubscribePacket packetWithSignals:[self.vehicle defaultSignals]
                                                                vehicleId:vehicleId]];
}

+ (void)subscribeToSignal:(NSString *)signal
{
    DLog(@"");

    [BackendServerManager sendPacket:[SubscribePacket packetWithSignals:@[signal]
                                                              vehicleId:[ConfigurationDataManager getVehicleId]]];
}

+ (void)unsubscribeFromSignal:(NSString *)signal
{
    DLog(@"");

    [BackendServerManager sendPacket:[UnsubscribePacket packetWithSignals:@[signal]
                                                                vehicleId:[ConfigurationDataManager getVehicleId]]];
}

+ (void)getAllSignals
{
    DLog(@"");

    [BackendServerManager sendPacket:[AllSignalsPacket packetWithVehicleId:[ConfigurationDataManager getVehicleId]]];
}

+ (Vehicle *)vehicle
{
    return [[VehicleManager sharedManager] vehicle];
}

- (void)registerObservers
{
    DLog(@"");

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
                                             selector:@selector(backendServerDidConnect:)
                                                 name:kBackendServerDidFailToConnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidReceiveData:)
                                                 name:kBackendServerDidReceivePacketNotification
                                               object:nil];
}

- (void)unregisterObservers
{
    DLog(@"");

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

    [self.vehicle setVehicleStatus:VEHICLE_STATUS_UNKNOWN];
}

- (void)processStatusPacket:(StatusPacket *)statusPacket
{
    /* If our vehicle id is good, set the vehicle's property (so it fetches the signalName descriptor stuff) and subscribe. */
    if ([[statusPacket status] isEqualToString:@"INVALID"])
    {
        self.vehicle.vehicleStatus = VEHICLE_STATUS_INVALID_ID;
    }
    else
    {
        [self resubscribeDefaultsForVehicle:statusPacket.vehicleId];

        if ([[statusPacket status] isEqualToString:@"CONNECTED"])
            self.vehicle.vehicleStatus = VEHICLE_STATUS_CONNECTED;
        else if ([[statusPacket status] isEqualToString:@"NOT_CONNECTED"])
            self.vehicle.vehicleStatus = VEHICLE_STATUS_NOT_CONNECTED;

        self.vehicle.numberDoors   = statusPacket.numberDoors;
        self.vehicle.numberWindows = statusPacket.numberWindows;
        self.vehicle.numberSeats   = statusPacket.numberSeats;
        self.vehicle.driverSide    = statusPacket.driverSide;
    }
}

- (void)processEventPacket:(EventPacket *)eventPacket
{
    if ([self.vehicle isSignalDefault:eventPacket.event])
        [self.vehicle eventForVehicleId:eventPacket.vehicleId signalName:eventPacket.event attributes:eventPacket.attributes];
    else ; /* We have an event for a signalName that isn't default... pass it along to the UI class that's looking for it??? */
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
        [self processStatusPacket:(StatusPacket *)packet];
    }
    else if ([packet isKindOfClass:[EventPacket class]])
    {
        [self processEventPacket:(EventPacket *)packet];
    }
    else if ([packet isKindOfClass:[ErrorPacket class]])
    {
        ; /* No-op for now */
    }
}
@end
