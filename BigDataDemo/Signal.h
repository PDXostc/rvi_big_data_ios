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

#define kVehicleSignalCurrentValueKeyPath @"currentValue"

typedef enum
{
    SIGNAL_TYPE_UNKNOWN,
    SIGNAL_TYPE_RANGE,
    SIGNAL_TYPE_CONVERTED_RANGE,
    SIGNAL_TYPE_RANGE_ENUMERATION,
    SIGNAL_TYPE_ENUMERATION,
} SignalType;

//@interface ValuePair : NSObject
//@property (nonatomic, strong) NSString *stringDescription;
//@property (nonatomic, strong) NSNumber *enumKey;
//- (id)initWithEnumKey:(NSNumber *)enumKey stringDescription:(NSString *)stringDescription;
//+ (id)valuePairWithEnumKey:(NSNumber *)enumKey stringDescription:(NSString *)stringDescription;
//@end

@interface Signal : NSObject
@property (nonatomic, readonly)         SignalType signalType;
@property (nonatomic, readonly)         NSInteger  lowVal;
@property (nonatomic, readonly)         NSInteger  highVal;
@property (nonatomic, readonly)         NSInteger  scaledLowValue;
@property (nonatomic, readonly)         NSInteger  scaledHighValue;
@property (nonatomic, strong, readonly) NSString  *signalDescription;
@property (nonatomic, strong, readonly) NSString  *units;
@property (nonatomic, strong, readonly) NSString  *unitsDescription;
@property (nonatomic, strong, readonly) NSString  *signalName;
@property (nonatomic)                   NSInteger  currentValue;

- (id)initWithSignalName:(NSString *)signalName descriptorDictionary:(NSDictionary *)descriptor;
+ (id)signalWithSignalName:(NSString *)signalName descriptorDictionary:(NSDictionary *)descriptor;

- (NSString *)stringDescriptionForEnumKey:(NSInteger)enumKey;
- (NSArray *)allEnumKeys;
- (NSArray *)allValuePairs;
- (NSInteger)numberOfValuePairs;
@end
