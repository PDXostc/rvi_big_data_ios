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
#import "PacketParser.h"
#import "ServerPacket.h"
#import "UnsubscribePacket.h"
#import "SubscribePacket.h"
#import "AllSignalsPacket.h"

@interface VehicleManager () <PacketParserDelegate>
@property (nonatomic, strong) Vehicle *vehicle;
@property (nonatomic, strong) PacketParser *packetParser;
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

        _sharedManager.vehicle = [[Vehicle alloc] init];

        _sharedManager.packetParser = [PacketParser packetParser];
        _sharedManager.packetParser.delegate = _sharedManager;
    });

    return _sharedManager;
}

+ (void)start
{
    [[VehicleManager sharedManager] registerObservers];
}

+ (NSString *)stringFromPacket:(ServerPacket *)packet
{
    NSError *jsonError;
    NSData  *payload = [NSJSONSerialization dataWithJSONObject:[packet toDictionary]
                                                       options:nil
                                                         error:&jsonError];

    if (jsonError)
        return nil;

    return  [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
}

+ (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    NSString *data = [VehicleManager stringFromPacket:[SubscribePacket packetWithSignals:[VehicleManager defaultSignals]
                                                                               vehicleId:vehicleId]];
    if (data) [BackendServerManager sendData:data];
}

+ (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    NSString *data = [VehicleManager stringFromPacket:[UnsubscribePacket packetWithSignals:[VehicleManager defaultSignals]
                                                                                 vehicleId:vehicleId]];
    if (data) [BackendServerManager sendData:data];
}

+ (void)subscribeToSignal:(NSString *)signal
{
    NSString *data = [VehicleManager stringFromPacket:[SubscribePacket packetWithSignals:@[signal]
                                                                                 vehicleId:[ConfigurationDataManager getVehicleId]]];
    if (data) [BackendServerManager sendData:data];
}

+ (void)unsubscribeFromSignal:(NSString *)signal
{
    NSString *data = [VehicleManager stringFromPacket:[UnsubscribePacket packetWithSignals:@[signal]
                                                                                 vehicleId:[ConfigurationDataManager getVehicleId]]];
    if (data) [BackendServerManager sendData:data];
}

+ (void)getAllSignals
{
    NSString *data = [VehicleManager stringFromPacket:[AllSignalsPacket packetWithVehicleId:[ConfigurationDataManager getVehicleId]]];
    if (data) [BackendServerManager sendData:data];
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
                                                 name:kBackendServerDidReceiveDataNotification
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

    if ([keyPath isEqualToString:kConfigurationDataManagerVehicleIdKeyPath])
        [VehicleManager unsubscribeDefaultsForVehicle:change[NSKeyValueChangeOldKey]],
        [VehicleManager resubscribeDefaultsForVehicle:change[NSKeyValueChangeNewKey]];
}

- (void)backendServerDidConnect:(NSNotification *)notification
{
    DLog(@"");
    [VehicleManager resubscribeDefaultsForVehicle:[ConfigurationDataManager getVehicleId]];
}

- (void)backendServerDidDisconnect:(NSNotification *)notification
{
    DLog(@"");

    [self.packetParser clear];
}

- (void)backendServerDidReceiveData:(NSNotification *)notification
{
    DLog(@"");

    NSDictionary *userInfo = notification.userInfo;
    NSString *data = userInfo[kBackendServerNotificationDataKey];

    [self.packetParser parseData:data];
}

- (void)onPacketParsed:(ServerPacket *)packet
{

}
@end
