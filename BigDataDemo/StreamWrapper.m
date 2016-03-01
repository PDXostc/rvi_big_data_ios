/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    StreamWrapper.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "StreamWrapper.h"
#import "Util.h"

@interface StreamWrapper () <NSStreamDelegate>
@property (nonatomic, strong)   NSInputStream  *inputStream;
@property (nonatomic, strong)   NSOutputStream *outputStream;
@property (nonatomic) BOOL                      isConnected;
@property (nonatomic) BOOL                      isConnecting;
@property (nonatomic, strong)   NSString       *serverUrl;
@property (nonatomic)           UInt32          serverPort;
@property (nonatomic, weak) id<StreamWrapperDelegate> delegate;
@end

@implementation StreamWrapper
{

}

+ (StreamWrapper *)instance
{
    static StreamWrapper *_instance = nil;
    static dispatch_once_t onceToken;
 
    dispatch_once(&onceToken, ^{
        _instance = [[StreamWrapper alloc] init];
    });
  
    return _instance;
} 

+ (void)connectStreamToUrl:(NSString *)serverUrl port:(NSUInteger)serverPort delegate:(id<StreamWrapperDelegate>)delegate
{
    [[StreamWrapper instance] setServerUrl:serverUrl];
    [[StreamWrapper instance] setServerPort:serverPort];
    [[StreamWrapper instance] setDelegate:delegate];

    [[StreamWrapper instance] connect];
}

+ (void)sendData:(NSString *)data
{
    if (![[StreamWrapper instance] isConnected])
    {
        [[[StreamWrapper instance] delegate] onDidFailToSendDataToRemoteConnection:[NSError errorWithDomain:@"com.jaguarlandrover.bigdata"
                                                                                                       code:1000
                                                                                                   userInfo:@{ NSLocalizedDescriptionKey : @"Can't send data; not connected" }]];
        return;
    }

    [[StreamWrapper instance] writeString:data];
    [[[StreamWrapper instance] delegate] onDidSendDataToRemoteConnection:data];
}

- (void)connect
{
    DLog(@"");

    if ([self isConnected])
        [self disconnect:nil];

    self.isConnecting = YES;

    [self setup];
    [self open];
}

- (void)disconnect:(NSError *)trigger
{
    self.isConnected = NO;

    [self close];

    if (trigger != nil)
        [self.delegate onRemoteConnectionDidDisconnect:trigger];
}

- (void)errorConnecting:(NSInteger)code underlyingError:(NSError *)underlyingError
{
    [self.delegate onRemoteConnectionDidFailToConnect:[NSError errorWithDomain:@"com.jaguarlandrover.bigdata"
                                                                          code:code
                                                                      userInfo:@{ NSLocalizedDescriptionKey : @"There was an error connecting",
                                                                                  NSUnderlyingErrorKey : underlyingError ? (id)underlyingError : (id)kCFNull }]];

    [self close];
}

- (void)finishConnecting
{
    self.isConnecting = NO;
    self.isConnected = YES;

    [self.delegate onRemoteConnectionDidConnect];
}

- (void)setup
{
    NSURL *url = [NSURL URLWithString:self.serverUrl];

    DLog(@"Setting up connection to %@ : %i", [url absoluteString], (int)self.serverPort);

    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url absoluteString], self.serverPort, &readStream, &writeStream);

    self.inputStream  = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
}

- (void)open
{
    DLog(@"Opening streams.");

    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];

    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [self.inputStream open];
    [self.outputStream open];
}

- (void)close
{
    DLog(@"Closing streams.");

    [self.inputStream close];
    [self.outputStream close];

    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    [self.inputStream setDelegate:nil];
    [self.outputStream setDelegate:nil];

    self.inputStream  = nil;
    self.outputStream = nil;
}

- (void)readString:(NSString *)string
{
    [self.delegate onRemoteConnectionDidReceiveData:string];
}

- (void)writeString:(NSString *)string
{
    [self.outputStream write:(uint8_t *)[string UTF8String] maxLength:strlen((char *)[string UTF8String])];
}

#pragma mark -
#pragma mark NSStreamDelegate

#define BUFFER_LEN 2048
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSInteger result = 0;
    switch (eventCode)
    {
        case NSStreamEventNone:
            DLog(@"NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            DLog(@"NSStreamEventOpenCompleted: %@", [[stream class] description]);
            break;
        case NSStreamEventHasBytesAvailable:
            DLog(@"NSStreamEventHasBytesAvailable");

            if (stream == self.inputStream)
            {
                uint8_t   buf[BUFFER_LEN];
                NSInteger len = [self.inputStream read:buf maxLength:BUFFER_LEN];
                NSMutableData *data = [[NSMutableData alloc] initWithLength:0];

                if (len > 0)
                {
                    [data appendBytes:(const void *)buf length:(NSUInteger)len];
                    [self readString:[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]];
                }
            }
            else
            {
                DLog(@"stream != self.inputStream");
            }

            break;
        case NSStreamEventHasSpaceAvailable:
            DLog(@"NSStreamEventHasSpaceAvailable");

            if (stream == self.outputStream)
            {
                if (self.isConnecting)
                    [self finishConnecting];
            }
            else
            {
                DLog(@"stream != self.outputStream");
            }
            break;
        case NSStreamEventErrorOccurred:
            DLog(@"unexpected NSStreamEventErrorOccurred: %@", [stream streamError]);

            if (self.isConnecting)
                [self errorConnecting:[[stream streamError] code] underlyingError:[stream streamError]];

            else if (self.isConnected)
                [self disconnect:[stream streamError]];

            break;
        case NSStreamEventEndEncountered:
            DLog(@"NSStreamEventEndEncountered: %@", [[stream class] description]);

            if (self.isConnecting)
                [self errorConnecting:1000 underlyingError:nil];

            else if (self.isConnected)
                [self disconnect:[NSError errorWithDomain:@"com.jaguarlandrover.bigdata"
                                                     code:1000
                                                 userInfo:@{ NSLocalizedDescriptionKey : @"The end of the stream has been reached." }]];

            break;
        default:
            break;
    }
}
@end
