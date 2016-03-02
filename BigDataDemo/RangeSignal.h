/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    RangeSignal.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "Signal.h"


@interface RangeSignal : Signal
@property (nonatomic)         NSInteger lowVal;
@property (nonatomic)         NSInteger highVal;
@property (nonatomic)         NSInteger scaledLowValue;
@property (nonatomic)         NSInteger scaledHighValue;
@property (nonatomic, strong) NSString *units;

+ (id)rangeSignalWithSignalName:(NSString *)signalName;
@end
