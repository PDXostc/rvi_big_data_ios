/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    AllSignalsViewController.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataViewController.h"

@class Signal;
@interface SelectedCellData : NSObject
@property (nonatomic, strong) NSString       *errorMessage;
@property (nonatomic, strong) NSString       *signalName;
@property (nonatomic, strong) NSString       *vehicleId;
@property (nonatomic, strong) Signal         *signal;
@property (nonatomic, strong) NSMutableArray *cachedValues;
@property (nonatomic)         NSNumber       *currentValue;

- (instancetype)initWithSignalName:(NSString *)signalName vehicleId:(NSString *)vehicleId;
+ (instancetype)dataWithSignalName:(NSString *)signalName vehicleId:(NSString *)vehicleId;
- (NSInteger)heightForDescriptorData;
- (NSInteger)heightForCachedValues;
- (NSInteger)heightForCurrentValue;
- (NSInteger)heightForCell;
- (void)updateCurrentValue:(NSNumber *)newValue;
@end

@interface AllSignalsViewController : DataViewController
@end
