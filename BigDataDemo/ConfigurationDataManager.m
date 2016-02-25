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


@implementation ConfigurationDataManager
{

}

#define kVehicleIdPrefsKey  @"vehicle_id_prefs_key"
#define kServerUrlPrefsKey  @"server_url_prefs_key"
#define kServerPortPrefsKey @"server_port_prefs_key"

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
    [ConfigurationDataManager setString:vehicleId forKey:kVehicleIdPrefsKey];
}

+ (NSString *)getServerUrl
{
    return [ConfigurationDataManager getStringForKey:kServerUrlPrefsKey];
}

+ (void)setServerUrl:(NSString *)serverUrl
{
    [ConfigurationDataManager setString:serverUrl forKey:kServerUrlPrefsKey];
}

+ (NSString *)getServerPort
{
    return [ConfigurationDataManager getStringForKey:kServerPortPrefsKey];
}

+ (void)setServerPort:(NSString *)serverPort
{
    [ConfigurationDataManager setString:serverPort forKey:kServerPortPrefsKey];
}

+ (BOOL)hasValidConfigurationData
{
    return ([ConfigurationDataManager getVehicleId] && ![[ConfigurationDataManager getVehicleId] isEqualToString:@""]) &&
            ([ConfigurationDataManager getServerUrl] && ![[ConfigurationDataManager getServerUrl] isEqualToString:@""]) &&
            ([NSURL URLWithString:[ConfigurationDataManager getServerUrl]]) &&
            ([ConfigurationDataManager getServerPort] && ![[ConfigurationDataManager getServerPort] isEqualToString:@""]) &&
            ([[ConfigurationDataManager getServerPort] integerValue]);
}
@end
