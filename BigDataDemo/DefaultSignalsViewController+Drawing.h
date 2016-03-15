/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    DefaultSignalsViewController+Drawing.h
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/15/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import "DefaultSignalsViewController.h"

@interface DefaultSignalsViewController (Drawing)
- (void)drawHood:(UIView *)hoodView;
- (void)drawRightRearDoorView:(UIView *)doorView;
- (void)drawRightFrontDoorView:(UIView *)doorView;
- (void)drawLeftRearDoorView:(UIView *)doorView;
- (void)drawLeftFrontDoorView:(UIView *)doorView;

@end
