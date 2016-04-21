// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//  Copyright © 2016 Jaguar Land Rover.
//
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0. The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
//  ConfigurationDataManagerTest.m
//  BigDataDemo
//
//  Created by Lilli Szafranski on 3/1/16.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#import <XCTest/XCTest.h>
#import "ConfigurationDataManager.h"

@interface ConfigurationDataManagerTest : XCTestCase

@end

@implementation ConfigurationDataManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullyQualifiedUrlWithScheme
{
    NSString *savedPort = [ConfigurationDataManager getServerPort];
    [ConfigurationDataManager setServerPort:@"1234"];

    /* "ws://" */
    [ConfigurationDataManager setServerUrl:@"https://foo.com"];
    NSURL *url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws://"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    [ConfigurationDataManager setServerUrl:@"ws://foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws://"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    [ConfigurationDataManager setServerUrl:@"foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws://"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    /* "ws" */
    [ConfigurationDataManager setServerUrl:@"https://foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    [ConfigurationDataManager setServerUrl:@"ws://foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    [ConfigurationDataManager setServerUrl:@"foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    /* "ws:" */
    [ConfigurationDataManager setServerUrl:@"https://foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws:"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    [ConfigurationDataManager setServerUrl:@"ws://foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws:"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    [ConfigurationDataManager setServerUrl:@"foo.com"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws:"];

    XCTAssertEqualObjects(@"ws://foo.com:1234", [url absoluteString]);

    /* Different port */

    [ConfigurationDataManager setServerUrl:@"ws://foo.com:5555"];
    url = [ConfigurationDataManager fullyQualifiedUrlWithScheme:@"ws:"];

    XCTAssertEqualObjects(@"ws://foo.com:5555", [url absoluteString]);

    [ConfigurationDataManager setServerPort:savedPort];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
