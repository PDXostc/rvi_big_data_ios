/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    Signal.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/1/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "Signal.h"



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

@interface Signal ()
@property (nonatomic, strong) NSDictionary *valuePairs;
@end

@implementation Signal
{

}

+ (SignalType)signalTypeFromString:(NSString *)string
{
    if ([string isEqualToString:@"RANGE"])             return SIGNAL_TYPE_RANGE;
    if ([string isEqualToString:@"CONVERTED_RANGE"])   return SIGNAL_TYPE_CONVERTED_RANGE;
    if ([string isEqualToString:@"RANGE_ENUMERATION"]) return SIGNAL_TYPE_RANGE_ENUMERATION;
    if ([string isEqualToString:@"ENUMERATION"])       return SIGNAL_TYPE_ENUMERATION;

    return SIGNAL_TYPE_UNKNOWN;
}

- (void)processRangeFromDescriptor:(NSDictionary *)descriptor
{
    NSArray *rangeArray = descriptor[@"range"];

    if (rangeArray.count > 2) {
        _lowVal  = [rangeArray[0] integerValue];
        _highVal = [rangeArray[rangeArray.count - 1] integerValue];
    }

    NSArray *unitRangeArray = descriptor[@"unit_range"];

    if (unitRangeArray.count > 2) {
        _scaledLowValue  = [unitRangeArray[0] integerValue];
        _scaledHighValue = [unitRangeArray[unitRangeArray.count - 1] integerValue];
    }

    _signalDescription = descriptor[@"description"];
    _units             = descriptor[@"unit"];
    _unitsDescription  = descriptor[@"unit_description"];
}

- (void)processEnumerationFromDescriptor:(NSDictionary *)descriptor
{
    NSMutableDictionary *enumerationDictionary = [NSMutableDictionary dictionaryWithDictionary:[descriptor[@"enumeration"] copy]];

    NSObject *keyToRemove = nil;
    for (NSObject *key in enumerationDictionary.allKeys) {
        NSObject *value = enumerationDictionary[key];

        /* If one of our enumeration values is a dictionary containing a range, then process that range and remove it from our dictionary. */
        if ([value isKindOfClass:[NSDictionary class]] && ((NSDictionary *)value)[@"range"]) {
            [self processRangeFromDescriptor:(NSDictionary *)value];

            keyToRemove = key;
            break;
        }
    }

    if (keyToRemove)
        [enumerationDictionary removeObjectForKey:keyToRemove];

    _valuePairs = [NSDictionary dictionaryWithDictionary:enumerationDictionary];
}

- (id)initWithSignalName:(NSString *)signalName descriptorDictionary:(NSDictionary *)descriptor
{

    if (signalName == nil)
        return nil;

    if ((self = [super init]))
    {
        _signalName = [signalName copy];
        _signalType = [Signal signalTypeFromString:descriptor[@"type"]];

        switch (_signalType)
        {
            case SIGNAL_TYPE_RANGE:
            case SIGNAL_TYPE_CONVERTED_RANGE:
                [self processRangeFromDescriptor:descriptor];
                break;
            case SIGNAL_TYPE_RANGE_ENUMERATION:
            case SIGNAL_TYPE_ENUMERATION:
                [self processEnumerationFromDescriptor:descriptor];
                break;

            case SIGNAL_TYPE_UNKNOWN:
                break;
        }
    }

    return self;
}

+ (id)signalWithSignalName:(NSString *)signalName descriptorDictionary:(NSDictionary *)descriptor
{
    return [[Signal alloc] initWithSignalName:signalName descriptorDictionary:descriptor];
}

- (NSString *)stringDescriptionForEnumKey:(NSInteger)enumKey
{
    return ((NSString *)self.valuePairs[@(enumKey)]);
}

- (NSArray *)allEnumKeys
{
    return self.valuePairs.allKeys;
}

- (NSArray *)allValuePairs
{
    return self.valuePairs.allValues;
}

- (NSInteger)numberOfValuePairs
{
    return self.valuePairs.count;
}

@end
