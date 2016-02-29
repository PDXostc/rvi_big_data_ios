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
    });
  
    return _sharedManager;   
} 

+ (void)start
{
    [[VehicleManager sharedManager] registerObservers];
}

+ (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    [BackendServerManager sendData:@""];
}

+ (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
{
    [BackendServerManager sendData:@""];
}

+ (void)subscribeToSignal:(NSString *)signal
{
    [BackendServerManager sendData:@""];
}

+ (void)unsubscribeFromSignal:(NSString *)signal
{
    [BackendServerManager sendData:@""];
}

+ (void)getAllSignals
{
    [BackendServerManager sendData:@""];
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
                                             selector:@selector(backendServerDidConnect)
                                                 name:kBackendServerDidConnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidReceiveData)
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

- (void)backendServerDidConnect
{
    DLog(@"");
    [VehicleManager resubscribeDefaultsForVehicle:[ConfigurationDataManager getVehicleId]];
}

- (void)backendServerDidReceiveData
{
    DLog(@"");
}

@end
