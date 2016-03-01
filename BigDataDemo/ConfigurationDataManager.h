/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    ConfigurationDataManager.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/25/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>


#define kConfigurationDataManagerVehicleIdKeyPath  @"vehicleId"
#define kConfigurationDataManagerServerUrlKeyPath  @"serverUrl"
#define kConfigurationDataManagerServerPortKeyPath @"serverPort"

@interface ConfigurationDataManager : NSObject
+ (NSString *)getVehicleId;
+ (void)setVehicleId:(NSString *)vehicleId;
+ (NSString *)getServerUrl;
+ (void)setServerUrl:(NSString *)serverUrl;
+ (NSString *)getServerPort;
+ (void)setServerPort:(NSString *)serverPort;

+ (BOOL)hasValidConfigurationData;
+ (NSURL *)fullyQualifiedUrlWithScheme:(NSString *)scheme;

+ (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
+ (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
+ (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;

@end
