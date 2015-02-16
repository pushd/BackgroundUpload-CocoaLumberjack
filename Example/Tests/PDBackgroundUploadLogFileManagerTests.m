//
//  PDBackgroundUploadLogFileManagerTests.m
//  BackgroundUpload-CocoaLumberjack
//
//  Created by Eric Jensen on 2/16/15.
//  Copyright (c) 2015 Eric Jensen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DDLog.h"
#import "PDBackgroundUploadLogFileManager.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PDBackgroundUploadLogFileManagerTests : XCTestCase

@end

@implementation PDBackgroundUploadLogFileManagerTests

- (void)testInit
{
    DDLogVerbose(@"logged something");
    XCTAssert(YES, @"Pass");
}

@end
