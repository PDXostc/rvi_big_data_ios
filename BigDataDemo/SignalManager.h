/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    SignalManager.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>

@class Signal;
typedef void (^CallbackBlock)(NSString * signalName, NSString *vehicleId, Signal *signal);

@interface SignalManager : NSObject
+ (void)start;
+ (void)getDescriptorsForSignalNames:(NSArray *)signalNames vehicleId:(NSString *)vehicleId block:(CallbackBlock)callbackBlock;
@end
