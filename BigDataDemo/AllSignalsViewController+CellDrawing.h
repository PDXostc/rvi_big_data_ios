/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    AllSignalsViewController+CellDrawing.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/9/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "AllSignalsViewController.h"

#define EXTENDED_DATA_START 44
#define VERTICAL_PADDING    10
#define HORIZONTAL_PADDING  10
#define LINE_HEIGHT         22

@interface AllSignalsViewController (CellDrawing)
+ (UILabel *)headerLabelWithFrame:(CGRect)frame;
+ (UILabel *)labelWithFrame:(CGRect)frame;
- (void)buildOutCachedDataView:(UIView *)view withSelectedCellData:(SelectedCellData *)data;
- (void)buildOutCurrentDataView:(UIView *)view withSelectedCellData:(SelectedCellData *)data;
- (void)buildOutDescriptorDataView:(UIView *)view withSelectedCellData:(SelectedCellData *)data;
- (UITableViewCell *)drawCell:(UITableViewCell *)cell forSelectedCellData:(SelectedCellData *)selectedCellData;
@end
