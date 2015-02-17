//
//  BackgroundUpload-CocoaLumberjackTests.m
//  BackgroundUpload-CocoaLumberjackTests
//
//  Created by Eric Jensen on 02/12/2015.
//  Copyright (c) 2014 Eric Jensen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DDLog.h"
#import "PDBackgroundUploadLogFileManager.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)testInit
{
    DDLogVerbose(@"logged something");
    XCTAssert(YES, @"Pass");
}

@end