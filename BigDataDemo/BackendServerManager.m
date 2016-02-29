/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    BackendServerManager.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "BackendServerManager.h"
#import "ConfigurationDataManager.h"
#import "Util.h"
#import "StreamWrapper.h"

@interface BackendServerManager () <StreamWrapperDelegate>
@property (nonatomic) BOOL isConnected;
@end

@implementation BackendServerManager
{

}

+ (id)sharedManager
{
    static BackendServerManager *_sharedBackendServerManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedBackendServerManager = [[BackendServerManager alloc] init];
    });

    return _sharedBackendServerManager;
}

+ (void)start
{
    [[BackendServerManager sharedManager] registerObservers];
    [BackendServerManager reconnectToServer];
}

+ (void)reconnectToServer
{
    if ([ConfigurationDataManager hasValidConfigurationData])
        [StreamWrapper connectStreamToUrl:[ConfigurationDataManager getServerUrl]
                                     port:(NSUInteger)[[ConfigurationDataManager getServerPort] integerValue]
                                 delegate:[BackendServerManager sharedManager]];

}

+ (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
{

}

+ (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
{

}

- (void)registerObservers
{
    [ConfigurationDataManager addObserver:self
                               forKeyPath:kConfigurationDataManagerVehicleIdKeyPath
                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:NULL];

    [ConfigurationDataManager addObserver:self
                               forKeyPath:kConfigurationDataManagerServerUrlKeyPath
                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:NULL];

    [ConfigurationDataManager addObserver:self
                               forKeyPath:kConfigurationDataManagerServerPortKeyPath
                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                  context:NULL];
}

- (void)unregisterObservers
{
    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerVehicleIdKeyPath];

    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerServerUrlKeyPath];

    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerServerPortKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kConfigurationDataManagerServerUrlKeyPath] || [keyPath isEqualToString:kConfigurationDataManagerServerPortKeyPath])
        [BackendServerManager reconnectToServer];
    else if ([keyPath isEqualToString:kConfigurationDataManagerVehicleIdKeyPath])
        [BackendServerManager unsubscribeDefaultsForVehicle:change[NSKeyValueChangeOldKey]],
        [BackendServerManager resubscribeDefaultsForVehicle:change[NSKeyValueChangeNewKey]];
}

- (void)onRemoteConnectionDidConnect
{
    self.isConnected = YES;

    [BackendServerManager resubscribeDefaultsForVehicle:[ConfigurationDataManager getVehicleId]];
}

- (void)onRemoteConnectionDidDisconnect:(NSError *)error
{
    DLog(@"Failed to connect to the backend server: %@", error.localizedDescription);
    self.isConnected = NO;
}

- (void)onRemoteConnectionDidFailToConnect:(NSError *)error
{
    DLog(@"Failed to connect to the backend server: %@", error.localizedDescription);
    self.isConnected = NO;
}

- (void)onRemoteConnectionDidReceiveData:(NSString *)data
{

}

- (void)onDidSendDataToRemoteConnection:(NSString *)data
{

}

- (void)onDidFailToSendDataToRemoteConnection:(NSError *)error
{
    DLog(@"Failed to connect to the backend server: %@", error.localizedDescription);
}


@end
