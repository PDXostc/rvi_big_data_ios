/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    AllSignalsViewController+CellDrawing.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/9/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "AllSignalsViewController+CellDrawing.h"
#import "Signal.h"
#import "Util.h"

@interface  SelectedCellData (CellDrawing)
- (NSInteger)heightForDescriptorData;
- (NSInteger)heightForCachedValues;
- (NSInteger)heightForCurrentValue;
- (NSInteger)heightForCell;
@end

@implementation SelectedCellData (CellDrawing)
- (NSInteger)heightForDescriptorData
{
    NSInteger heightForDescriptorData = 0;

    switch (self.signal.signalType) {

        case SIGNAL_TYPE_UNKNOWN:
            break;

        case SIGNAL_TYPE_CONVERTED_RANGE:

            heightForDescriptorData += LINE_HEIGHT * 2;
        case SIGNAL_TYPE_RANGE:

            heightForDescriptorData += LINE_HEIGHT * 2;
            break;

        case SIGNAL_TYPE_RANGE_ENUMERATION:

            heightForDescriptorData += LINE_HEIGHT * 2;

        case SIGNAL_TYPE_ENUMERATION:

            heightForDescriptorData += LINE_HEIGHT + (self.signal.allValuePairs.count * LINE_HEIGHT);
            break;
    }

    return heightForDescriptorData + VERTICAL_PADDING;
}

- (NSInteger)heightForCachedValues
{
    if (!self.cachedValues.count) return 0;

    return LINE_HEIGHT + (self.cachedValues.count * LINE_HEIGHT) + VERTICAL_PADDING;
}

- (NSInteger)heightForCurrentValue
{
    if (!self.currentValue) return 0;

    return LINE_HEIGHT + LINE_HEIGHT + VERTICAL_PADDING;
}

- (NSInteger)heightForCell
{
    if (self.signal == nil)
        return 80;

    return EXTENDED_DATA_START + [self heightForDescriptorData] + [self heightForCachedValues] + [self heightForCurrentValue];
}
@end

@interface UIView (CellDrawing)
- (void)populateWithEnumerationDescriptorData:(Signal *)signal;
- (void)populateWithRangeDescriptorData:(Signal *)signal;
- (void)populateWithConvertedRangeDescriptorData:(Signal *)signal;
@end

@implementation UIView (CellDrawing)
- (void)populateWithEnumerationDescriptorData:(Signal *)signal
{
    UILabel *headerLabel = [AllSignalsViewController headerLabelWithFrame:CGRectMake(0, 0, self.frame.size.width, LINE_HEIGHT)];
    UILabel *textLabel   = [AllSignalsViewController labelWithFrame:CGRectMake(0, LINE_HEIGHT, self.frame.size.width, LINE_HEIGHT * signal.allValuePairs.count)];

    headerLabel.text = @"Possible Values";

    textLabel.numberOfLines = signal.allValuePairs.count;

    NSMutableString *text = [NSMutableString string];
    for (NSNumber *value in [signal.allEnumKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                                     if ([obj1 intValue] > [obj2 intValue])
                                                                                         return NSOrderedDescending;
                                                                                     else if ([obj1 intValue] < [obj2 intValue])
                                                                                         return NSOrderedAscending;
                                                                                     return NSOrderedSame;
                                                                                }])
    {
        [text appendString:[NSString stringWithFormat:@"%@: %@", value, [signal stringDescriptionForValue:value]]];
        [text appendString:@"\n"];
    }
    textLabel.text = text;

    [self addSubview:headerLabel];
    [self addSubview:textLabel];
}

- (void)populateWithRangeDescriptorData:(Signal *)signal
{
    UILabel *headerLabel = [AllSignalsViewController headerLabelWithFrame:CGRectMake(0, 0, self.frame.size.width, LINE_HEIGHT)];
    UILabel *textLabel   = [AllSignalsViewController labelWithFrame:CGRectMake(0, LINE_HEIGHT, self.frame.size.width, LINE_HEIGHT)];

    headerLabel.text = @"Possible Range Values";
    textLabel.text   = [NSString stringWithFormat:@"%d - %d %@", signal.lowVal, signal.highVal, signal.signalDescription];

    [self addSubview:headerLabel];
    [self addSubview:textLabel];
}

- (void)populateWithConvertedRangeDescriptorData:(Signal *)signal
{
    UILabel *headerLabel = [AllSignalsViewController headerLabelWithFrame:CGRectMake(0, 0, self.frame.size.width, LINE_HEIGHT)];
    UILabel *textLabel   = [AllSignalsViewController labelWithFrame:CGRectMake(0, LINE_HEIGHT, self.frame.size.width, LINE_HEIGHT)];

    headerLabel.text = @"Possible Range Values";
    textLabel.text   = [NSString stringWithFormat:@"%d - %d %@", signal.scaledLowValue, signal.scaledHighValue, signal.unitsDescription];

    [self addSubview:headerLabel];
    [self addSubview:textLabel];
}
@end


@implementation AllSignalsViewController (CellDrawing)
+ (UILabel *)headerLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];

    label.font = [UIFont boldSystemFontOfSize:16.0];

    return label;
}

+ (UILabel *)labelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];

    label.font = [UIFont systemFontOfSize:16.0];

    return label;
}

- (NSString *)lineForSignal:(Signal *)signal value:(NSNumber *)value
{
    NSString *valueDescription = nil;
    NSInteger scaledValue      = [value integerValue];

    switch (signal.signalType) {

        case SIGNAL_TYPE_RANGE:
            valueDescription = [NSString stringWithFormat:@" %@", signal.signalDescription];
            break;

        case SIGNAL_TYPE_CONVERTED_RANGE:
            valueDescription = [NSString stringWithFormat:@" %@", signal.unitsDescription];
            scaledValue      = [[signal getScaledValueForValue:value] integerValue];
            break;

        case SIGNAL_TYPE_RANGE_ENUMERATION:
            if ([signal valueWithinRange:value])
            {
                valueDescription = [NSString stringWithFormat:@" %@", signal.signalDescription];
                break;
            } /* else - fall through */

        case SIGNAL_TYPE_ENUMERATION:
            valueDescription = [NSString stringWithFormat:@": %@", [signal stringDescriptionForValue:value]];

            break;

        case SIGNAL_TYPE_UNKNOWN:
            break;
    }

    return [NSString stringWithFormat:@"%d %@", scaledValue, valueDescription];
}

- (void)buildOutCachedDataView:(UIView *)view withSelectedCellData:(SelectedCellData *)data
{
    UILabel *headerLabel = [AllSignalsViewController headerLabelWithFrame:CGRectMake(0, 0, view.frame.size.width, LINE_HEIGHT)];
    UILabel *textLabel   = [AllSignalsViewController labelWithFrame:CGRectMake(0, LINE_HEIGHT, view.frame.size.width, LINE_HEIGHT * data.cachedValues.count)];

    headerLabel.text = @"Cached Values";

    textLabel.numberOfLines = data.cachedValues.count;

    NSMutableString *text = [NSMutableString string];
    for (NSNumber *value in data.cachedValues)
    {
        [text appendString:[self lineForSignal:data.signal value:value]];
        [text appendString:@"\n"];
    }
    textLabel.text = text;

    [view addSubview:headerLabel];
    [view addSubview:textLabel];
}

- (void)buildOutCurrentDataView:(UIView *)view withSelectedCellData:(SelectedCellData *)data
{
    UILabel *headerLabel = [AllSignalsViewController headerLabelWithFrame:CGRectMake(0, 0, view.frame.size.width, LINE_HEIGHT)];
    UILabel *textLabel   = [AllSignalsViewController labelWithFrame:CGRectMake(0, LINE_HEIGHT, view.frame.size.width, LINE_HEIGHT)];

    headerLabel.text = @"Current Value";

    textLabel.text = [self lineForSignal:data.signal value:data.signal.currentValue];

    [view addSubview:headerLabel];
    [view addSubview:textLabel];
}

- (void)buildOutDescriptorDataView:(UIView *)view withSelectedCellData:(SelectedCellData *)data
{
    UIView *primaryView = nil;
    UIView *fallThroughView = nil;

    switch (data.signal.signalType) {

        case SIGNAL_TYPE_CONVERTED_RANGE:
            fallThroughView = [[UIView alloc] initWithFrame:CGRectMake(0, LINE_HEIGHT * 2, view.frame.size.width, LINE_HEIGHT * 2)];
            [fallThroughView populateWithConvertedRangeDescriptorData:data.signal];

        case SIGNAL_TYPE_RANGE:
            primaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, LINE_HEIGHT * 2)];
            [primaryView populateWithRangeDescriptorData:data.signal];

            break;

        case SIGNAL_TYPE_RANGE_ENUMERATION:
            fallThroughView = [[UIView alloc] initWithFrame:CGRectMake(0, LINE_HEIGHT * data.signal.allValuePairs.count, view.frame.size.width, LINE_HEIGHT * 2)];
            [fallThroughView populateWithRangeDescriptorData:data.signal];

        case SIGNAL_TYPE_ENUMERATION:
            primaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, LINE_HEIGHT * data.signal.allValuePairs.count)];
            [primaryView populateWithEnumerationDescriptorData:data.signal];

            break;

        case SIGNAL_TYPE_UNKNOWN:
            break;
    }

    [view addSubview:primaryView];
    [view addSubview:fallThroughView];
}

#define TAG_CELL_ACTIVITY_INDICATOR   101
#define TAG_CELL_DESCRIPTOR_DATA_VIEW 102
#define TAG_CELL_CACHED_VALUES_VIEW   103
#define TAG_CELL_CURRENT_VALUE_VIEW   104
#define TAG_CELL_ERROR_MESSAGE_LABEL  105

- (UITableViewCell *)drawCell:(UITableViewCell *)cell forSelectedCellData:(SelectedCellData *)selectedCellData
{
    DLog(@"");

    UIActivityIndicatorView *activityIndicatorView = [cell.contentView viewWithTag:TAG_CELL_ACTIVITY_INDICATOR];

    UIView  *oldDescriptorDataView                 = [cell.contentView viewWithTag:TAG_CELL_DESCRIPTOR_DATA_VIEW];
    UIView  *oldCachedDataView                     = [cell.contentView viewWithTag:TAG_CELL_CACHED_VALUES_VIEW];
    UIView  *oldCurrentDataView                    = [cell.contentView viewWithTag:TAG_CELL_CURRENT_VALUE_VIEW];
    UILabel *oldErrorLabel                         = [cell.contentView viewWithTag:TAG_CELL_ERROR_MESSAGE_LABEL];

    if (oldDescriptorDataView) [oldDescriptorDataView removeFromSuperview];
    if (oldCachedDataView    ) [oldCachedDataView     removeFromSuperview];
    if (oldCurrentDataView   ) [oldCurrentDataView    removeFromSuperview];
    if (oldErrorLabel        ) [oldErrorLabel         removeFromSuperview];

    @try
    {
        if (!selectedCellData.signal)
        {
            if (selectedCellData.errorMessage)
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, EXTENDED_DATA_START, cell.contentView.frame.size.width - (HORIZONTAL_PADDING * 2), LINE_HEIGHT)];

                label.font = [UIFont systemFontOfSize:12.0];
                label.text = selectedCellData.errorMessage;

                [label setTag:TAG_CELL_ERROR_MESSAGE_LABEL];
                [cell.contentView addSubview:label];

                [activityIndicatorView setHidden:YES];
            }
            else
            {
                [activityIndicatorView setHidden:NO];
                [activityIndicatorView startAnimating];
            }
            return cell;
        }

        [activityIndicatorView stopAnimating];
        [activityIndicatorView setHidden:YES];

        NSInteger verticalStartPosition = EXTENDED_DATA_START;

        UIView *descriptorDataView = [[UIView alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, verticalStartPosition, cell.contentView.frame.size.width - (HORIZONTAL_PADDING * 2), [selectedCellData heightForDescriptorData])];

        [self buildOutDescriptorDataView:descriptorDataView withSelectedCellData:selectedCellData];

        [descriptorDataView setTag:TAG_CELL_DESCRIPTOR_DATA_VIEW];
        [cell.contentView addSubview:descriptorDataView];

        verticalStartPosition += [selectedCellData heightForDescriptorData];

        UIView *cachedDataView = [[UIView alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, verticalStartPosition, cell.contentView.frame.size.width - (HORIZONTAL_PADDING * 2), [selectedCellData heightForCachedValues])];

        [self buildOutCachedDataView:cachedDataView withSelectedCellData:selectedCellData];

        [cachedDataView setTag:TAG_CELL_CACHED_VALUES_VIEW];
        [cell.contentView addSubview:cachedDataView];

        verticalStartPosition += [selectedCellData heightForCachedValues];

        UIView *currentDataView = [[UIView alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, verticalStartPosition, cell.contentView.frame.size.width - (HORIZONTAL_PADDING * 2), [selectedCellData heightForCurrentValue])];

        [self buildOutCurrentDataView:currentDataView withSelectedCellData:selectedCellData];

        [currentDataView setTag:TAG_CELL_CURRENT_VALUE_VIEW];
        [cell.contentView addSubview:currentDataView];
    }
    @catch (NSException *exception)
    {
        oldDescriptorDataView = [cell.contentView viewWithTag:TAG_CELL_DESCRIPTOR_DATA_VIEW];
        oldCachedDataView     = [cell.contentView viewWithTag:TAG_CELL_CACHED_VALUES_VIEW];
        oldCurrentDataView    = [cell.contentView viewWithTag:TAG_CELL_CURRENT_VALUE_VIEW];
        oldErrorLabel         = [cell.contentView viewWithTag:TAG_CELL_ERROR_MESSAGE_LABEL];

        if (oldDescriptorDataView) [oldDescriptorDataView removeFromSuperview];
        if (oldCachedDataView    ) [oldCachedDataView     removeFromSuperview];
        if (oldCurrentDataView   ) [oldCurrentDataView    removeFromSuperview];
        if (oldErrorLabel        ) [oldErrorLabel         removeFromSuperview];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, EXTENDED_DATA_START, cell.contentView.frame.size.width - (HORIZONTAL_PADDING * 2), LINE_HEIGHT)];

        label.font = [UIFont systemFontOfSize:12.0];
        label.text = @"There was an error drawing the cell.";

        [label setTag:TAG_CELL_ERROR_MESSAGE_LABEL];
        [cell.contentView addSubview:label];

        [activityIndicatorView setHidden:YES];

        return cell;
    }

    return cell;
}
@end
