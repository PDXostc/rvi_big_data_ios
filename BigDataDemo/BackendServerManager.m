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

NSString *const kBackendServerDidConnectNotification        = @"backend_server_did_connect_notification";
NSString *const kBackendServerDidFailToConnectNotification  = @"backend_server_did_fail_to_connect_notification";
NSString *const kBackendServerDidDisconnectNotification     = @"backend_server_did_disconnect_notification";
NSString *const kBackendServerDidSendDataNotification       = @"backend_server_did_send_data_notification";
NSString *const kBackendServerDidFailToSendDataNotification = @"backend_server_did_fail_to_send_data_notification";
NSString *const kBackendServerDidReceiveDataNotification    = @"backend_server_did_receive_data_notification";
NSString *const kBackendServerNotificationDataKey           = @"backend_server_notification_data_key";
NSString *const kBackendServerNotificationErrorKey          = @"backend_server_notification_error_key";


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

+ (void)sendData:(NSString *)data
{
    [StreamWrapper sendData:data];
}

//+ (void)unsubscribeDefaultsForVehicle:(NSString *)vehicleId
//{
//
//}
//
//+ (void)resubscribeDefaultsForVehicle:(NSString *)vehicleId
//{
//
//}

- (void)registerObservers
{
//    [ConfigurationDataManager addObserver:self
//                               forKeyPath:kConfigurationDataManagerVehicleIdKeyPath
//                                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
//                                  context:NULL];

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
//    [ConfigurationDataManager removeObserver:self
//                                  forKeyPath:kConfigurationDataManagerVehicleIdKeyPath];

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
//    else if ([keyPath isEqualToString:kConfigurationDataManagerVehicleIdKeyPath])
//        [BackendServerManager unsubscribeDefaultsForVehicle:change[NSKeyValueChangeOldKey]],
//        [BackendServerManager resubscribeDefaultsForVehicle:change[NSKeyValueChangeNewKey]];
}

- (void)onRemoteConnectionDidConnect
{
    self.isConnected = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidConnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:nil];
}

- (void)onRemoteConnectionDidDisconnect:(NSError *)error
{
    DLog(@"Failed to connect to the backend server: %@", error.localizedDescription);
    self.isConnected = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidFailToConnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationErrorKey : error}];
}

- (void)onRemoteConnectionDidFailToConnect:(NSError *)error
{
    DLog(@"Failed to connect to the backend server: %@", error.localizedDescription);
    self.isConnected = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidDisconnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationErrorKey : error}];
}

- (void)onRemoteConnectionDidReceiveData:(NSString *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidReceiveDataNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationDataKey : data}];
}

- (void)onDidSendDataToRemoteConnection:(NSString *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidSendDataNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationDataKey : data}];
}

- (void)    onDidFailToSendDataToRemoteConnection:(NSError *)error
{
    DLog(@"Failed to connect to the backend server: %@", error.localizedDescription);

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidFailToSendDataNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:@{kBackendServerNotificationErrorKey : error}];
}


@end
