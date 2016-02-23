//
//  ModelController.h
//  BigDataDemo
//
//  Created by Lilli Szafranski on 2/23/16.
//  Copyright © 2016 Jaguar Land Rover. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

