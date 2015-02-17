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
#import "PDAppDelegate.h"

@interface PDAppDelegate (Tests)

@property (strong, nonatomic) PDBackgroundUploadLogFileManager *fileManager;
@property (strong, nonatomic) DDFileLogger *fileLogger;

@end

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [self appDelegate].fileLogger.maximumFileSize = 5;
    
    NSArray *fileInfos = [[self appDelegate].fileManager unsortedLogFileInfos];
    for (DDLogFileInfo *fileInfo in fileInfos) {
        if (fileInfo.isArchived) {
            [[NSFileManager defaultManager] removeItemAtPath:fileInfo.filePath error:nil];
        }
    }
}

- (void)testRolling
{
    DDLogVerbose(@"12345");
    DDLogVerbose(@"6");
    XCTestExpectation *expectation = [self expectationWithDescription:@"Should finish on serial logging queue"];
    dispatch_async([DDLog loggingQueue], ^{
        dispatch_async([[self appDelegate].fileLogger loggerQueue], ^{
            [expectation fulfill];
            XCTAssertEqual(2, [[[self appDelegate].fileManager unsortedLogFilePaths] count], @"Should have rolled a file");
        });
    });
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (PDAppDelegate *)appDelegate
{
    return (PDAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end