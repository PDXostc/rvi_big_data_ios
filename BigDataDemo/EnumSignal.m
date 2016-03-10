/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    EnumSignal.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "EnumSignal.h"

//@implementation ValuePair
//- (id)initWithEnumKey:(NSNumber *)enumKey stringDescription:(NSString *)stringDescription
//{
//    if ((enumKey == nil) || (stringDescription == nil))
//        return nil;
//
//    if ((self = [super init]))
//    {
//        _enumKey = enumKey;
//        _stringDescription = [stringDescription copy];
//    }
//
//    return self;
//}
//
//+ (id)valuePairWithEnumKey:(NSNumber *)enumKey stringDescription:(NSString *)stringDescription
//{
//    return [[ValuePair alloc] initWithEnumKey:enumKey stringDescription:stringDescription];
//}
//@end
//
//@interface EnumSignal ()
//@property (nonatomic, strong) NSMutableDictionary *valuePairs;
//@end
//
//@implementation EnumSignal
//{
//
//}
//- (id)initWithSignalName:(NSString *)signalName
//{
//    if (signalName == nil)
//        return nil;
//
//    if ((self = [super initWithSignalName:signalName]))
//    {
//        _valuePairs = [NSMutableDictionary dictionary];
//    }
//
//    return self;
//}
//
//+ (id)enumSignalWithSignalName:(NSString *)signalName
//{
//    return [[EnumSignal alloc] initWithSignalName:signalName];
//}
//
//- (void)addValuePair:(ValuePair *)valuePair
//{
//    self.valuePairs[valuePair.enumKey] = valuePair;
//}
//
//- (void)addStringDescription:(NSString *)stringDescription forEnumKey:(NSNumber *)enumKey
//{
//    self.valuePairs[enumKey] = [ValuePair valuePairWithEnumKey:enumKey stringDescription:stringDescription];
//}
//
//- (NSString *)stringDescriptionForValue:(NSNumber *)enumKey
//{
//    return ((ValuePair *)self.valuePairs[enumKey]).stringDescription;
//}
//
//- (NSArray *)allEnumKeys
//{
//    return self.valuePairs.allKeys;
//}
//
//- (NSArray *)allValuePairs
//{
//    return self.valuePairs.allValues;
//}
//
//- (NSInteger)numberOfValuePairs
//{
//    return self.valuePairs.count;
//}
//@end
