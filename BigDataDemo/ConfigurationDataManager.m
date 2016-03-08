/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    ConfigurationDataManager.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "ConfigurationDataManager.h"
#import "Util.h"

@interface ConfigurationDataManager ()
@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, strong) NSString *serverUrl;
@property (nonatomic, strong) NSString *serverPort;
@end

@implementation ConfigurationDataManager
{

}

#define kVehicleIdPrefsKey  @"vehicle_id_prefs_key"
#define kServerUrlPrefsKey  @"server_url_prefs_key"
#define kServerPortPrefsKey @"server_port_prefs_key"

+ (id)sharedManager
{
    static ConfigurationDataManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[ConfigurationDataManager alloc] init];

        _sharedManager.vehicleId  = [ConfigurationDataManager getVehicleId];
        _sharedManager.serverUrl  = [ConfigurationDataManager getServerUrl];
        _sharedManager.serverPort = [ConfigurationDataManager getServerPort];
    });

    return _sharedManager;
}


+ (void)setString:(NSString *)string forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getStringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString *)getVehicleId
{
    return [ConfigurationDataManager getStringForKey:kVehicleIdPrefsKey];
}

+ (void)setVehicleId:(NSString *)vehicleId
{
    if ([vehicleId isEqualToString:[ConfigurationDataManager getVehicleId]])
        return;

    [ConfigurationDataManager setString:vehicleId forKey:kVehicleIdPrefsKey];
    [[ConfigurationDataManager sharedManager] setVehicleId:vehicleId];
}

+ (NSString *)getServerUrl
{
    return [ConfigurationDataManager getStringForKey:kServerUrlPrefsKey];
}

+ (void)setServerUrl:(NSString *)serverUrl
{
    if ([serverUrl isEqualToString:[ConfigurationDataManager getServerUrl]])
        return;

    [ConfigurationDataManager setString:serverUrl forKey:kServerUrlPrefsKey];
    [[ConfigurationDataManager sharedManager] setServerUrl:serverUrl];
}

+ (NSString *)getServerPort
{
    return [ConfigurationDataManager getStringForKey:kServerPortPrefsKey];
}

+ (void)setServerPort:(NSString *)serverPort
{
    if ([serverPort isEqualToString:[ConfigurationDataManager getServerPort]])
        return;

    [ConfigurationDataManager setString:serverPort forKey:kServerPortPrefsKey];
    [[ConfigurationDataManager sharedManager] setServerPort:serverPort];
}

+ (BOOL)hasValidConfigurationData
{
    return ([ConfigurationDataManager getVehicleId] && ![[ConfigurationDataManager getVehicleId] isEqualToString:@""]) &&
            ([ConfigurationDataManager getServerUrl] && ![[ConfigurationDataManager getServerUrl] isEqualToString:@""]) &&
            ([NSURL URLWithString:[ConfigurationDataManager getServerUrl]]) &&
            ([ConfigurationDataManager getServerPort] && ![[ConfigurationDataManager getServerPort] isEqualToString:@""]) &&
            ([[ConfigurationDataManager getServerPort] integerValue]);
}

/* Sanitize our saved url, removing incorrect scheme if user accidentally added one (e.g., 'http://'), and appending the port. */
+ (NSURL *)fullyQualifiedUrlWithScheme:(NSString *)scheme
{
    if ([scheme hasSuffix:@"://"]) scheme = [scheme substringToIndex:scheme.length - @"://".length];
    if ([scheme hasSuffix:@":"])   scheme = [scheme substringToIndex:scheme.length - @":".length];

    NSString        *serverUrl = [ConfigurationDataManager getServerUrl];
    NSMutableString *newUrl    = [NSMutableString string];

    NSURL *url = [NSURL URLWithString:serverUrl];

    if (![url scheme])
        [newUrl appendFormat:@"%@://%@", scheme, serverUrl];

    else if (![[url scheme] isEqualToString:scheme])
        [newUrl appendFormat:@"%@://%@", scheme, [serverUrl substringFromIndex:([url scheme].length + @"://".length)]];

    else
        [newUrl appendString:[url absoluteString]];

    if (![url port])
        [newUrl appendFormat:@":%@", [ConfigurationDataManager getServerPort]];


    url = [NSURL URLWithString:newUrl];

    return url;
}

+ (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [[ConfigurationDataManager sharedManager] addObserver:observer forKeyPath:keyPath options:options context:context];
}

+ (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    [[ConfigurationDataManager sharedManager] removeObserver:observer forKeyPath:keyPath];
}

+ (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    /* Just in case we screwed up KVO, catch that shit. */
    @try
    {
        [[ConfigurationDataManager sharedManager] removeObserver:observer forKeyPath:keyPath context:context];
    }
    @catch (NSException *exception)
    {
        /* Maybe the original signal was null... */
        DLog(@"EXCEPTION THROWN: %@", exception.description);
    }
}
@end
