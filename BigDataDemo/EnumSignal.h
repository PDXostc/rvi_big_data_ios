/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    EnumSignal.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "Signal.h"

@interface ValuePair : NSObject
@property (nonatomic, strong) NSString *stringDescription;
@property (nonatomic, strong) NSNumber *enumKey;
- (id)initWithEnumKey:(NSNumber *)enumKey stringDescription:(NSString *)stringDescription;
+ (id)valuePairWithEnumKey:(NSNumber *)enumKey stringDescription:(NSString *)stringDescription;
@end

@interface EnumSignal : Signal
+ (id)enumSignalWithSignalName:(NSString *)signalName;

- (void)addValuePair:(ValuePair *)valuePair;
- (void)addStringDescription:(NSString *)stringDescription forEnumKey:(NSNumber *)enumKey;
- (NSString *)stringDescriptionForEnumKey:(NSNumber *)enumKey;
- (NSArray *)allEnumKeys;
- (NSArray *)allValuePairs;
- (NSInteger)numberOfValuePairs;
@end
