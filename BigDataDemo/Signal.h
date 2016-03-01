/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    Signal.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>


@interface Signal : NSObject
@property (nonatomic, strong, readonly) NSString *signalName;
@property (nonatomic)                   NSInteger signalValue;
- (id)initWithSignalName:(NSString *)signalName;
+ (id)signalWithSignalName:(NSString *)signalName;
@end
