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
#import "SRWebSocket.h"
#import "ServerPacket.h"
#import "PacketParser.h"

NSString *const kBackendServerDidConnectNotification           = @"backend_server_did_connect_notification";
NSString *const kBackendServerDidFailToConnectNotification     = @"backend_server_did_fail_to_connect_notification";
NSString *const kBackendServerDidDisconnectNotification        = @"backend_server_did_disconnect_notification";
NSString *const kBackendServerCommunicationDidFailNotification = @"backend_server_communication_did_fail_notification";
NSString *const kBackendServerDidReceivePacketNotification     = @"backend_server_did_receive_packet_notification";
NSString *const kBackendServerNotificationPacketKey            = @"backend_server_notification_packet_key";
NSString *const kBackendServerNotificationErrorKey             = @"backend_server_notification_error_key";


@interface BackendServerManager () <SRWebSocketDelegate>//, PacketParserDelegate>
//@property (nonatomic, strong) PacketParser *packetParser;
@property (nonatomic, strong) SRWebSocket *webSocket;
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

//        _sharedBackendServerManager.packetParser = [PacketParser packetParser];
//        _sharedBackendServerManager.packetParser.delegate = _sharedBackendServerManager;

    });

    return _sharedBackendServerManager;
}

+ (void)start
{
    DLog(@"");

    [[BackendServerManager sharedManager] registerObservers];
    [[BackendServerManager sharedManager] reconnectToServer];
}

- (void)reconnectToServer
{
    if (self.isConnected)
    {
        DLog(@"Closing socket...");

        [self.webSocket close];
    }
    if ([ConfigurationDataManager hasValidConfigurationData])
    {
        DLog(@"Opening socket to: %@", [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws"]);

        [self setWebSocket:[[SRWebSocket alloc] initWithURL:[ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws"]]];
        [self.webSocket setDelegate:self];
        [self.webSocket open];
    }
}

+ (void)sendPacket:(ServerPacket *)packet
{
    if (!packet) // TODO: Error?
        return;

    NSString *data = [PacketParser stringFromPacket:packet];

    if (!data) // TODO: Error?
        return;

    DLog(@"Socket send: %@", data);

    [[[BackendServerManager sharedManager] webSocket] send:data];
}

+ (BOOL)isConnected
{
    return [[BackendServerManager sharedManager] isConnected];
}

- (void)registerObservers
{
    DLog(@"");

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
    DLog(@"");

    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerServerUrlKeyPath];

    [ConfigurationDataManager removeObserver:self
                                  forKeyPath:kConfigurationDataManagerServerPortKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kConfigurationDataManagerServerUrlKeyPath] || [keyPath isEqualToString:kConfigurationDataManagerServerPortKeyPath])
        [self reconnectToServer];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    DLog(@"Socket open");

    self.isConnected = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidConnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    DLog(@"Socket error: %@", reason);

    self.isConnected = NO;

    //[self.packetParser clear];

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidFailToConnectNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:reason ? @{ kBackendServerNotificationErrorKey : reason } : nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    DLog(@"Socket receive: %@", message);

    ServerPacket *packet = [PacketParser packetFromString:message];

    if (packet)
        [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerDidReceivePacketNotification
                                                            object:[BackendServerManager class]
                                                          userInfo:@{ kBackendServerNotificationPacketKey : packet }];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerCommunicationDidFailNotification
                                                            object:[BackendServerManager class]
                                                          userInfo:@{ kBackendServerNotificationErrorKey : [NSError errorWithDomain:ERROR_DOMAIN
                                                                                                                               code:NULL_PACKET_ERROR_DOMAIN
                                                                                                                           userInfo:@{ NSLocalizedDescriptionKey : @"Parsed packet is null" }] }];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    DLog(@"Socket error: %@", error.localizedDescription);

    [[NSNotificationCenter defaultCenter] postNotificationName:kBackendServerCommunicationDidFailNotification
                                                        object:[BackendServerManager class]
                                                      userInfo:error ? @{ kBackendServerNotificationErrorKey : error } : nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    DLog(@"Socket pong");
}

//- (void)onPacketParsed:(ServerPacket *)packet
//{
//    DLog(@"");
//
//
//}

@end
