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

@interface PDBackgroundUploadLogFileManager (Tests)

@property (weak, nonatomic) id<PDBackgroundUploadLogFileManagerDelegate> delegate;

@end

@interface PDAppDelegate (Tests)

@property (strong, nonatomic) PDBackgroundUploadLogFileManager *fileManager;
@property (strong, nonatomic) DDFileLogger *fileLogger;

@end

@interface Tests : XCTestCase <PDBackgroundUploadLogFileManagerDelegate>

@property (strong, nonatomic) XCTestExpectation *expectation;

@end

@implementation Tests

- (void)setUp
{
    [self appDelegate].fileManager.delegate = self;
    [self appDelegate].fileLogger.maximumFileSize = 5;
    [DDLog removeAllLoggers];
    [DDLog addLogger:[self appDelegate].fileLogger]; // some linking weirdness
    
    dispatch_sync([DDLog loggingQueue], ^{
        NSArray *fileInfos = [[self appDelegate].fileManager unsortedLogFileInfos];
        for (DDLogFileInfo *fileInfo in fileInfos) {
            if (fileInfo.isArchived) {
                [[NSFileManager defaultManager] removeItemAtPath:fileInfo.filePath error:nil];
            }
        }
    });
}

- (void)testRolling
{
    self.expectation = [self expectationWithDescription:@"Should call back delegate method"];

    DDLogVerbose(@"12345");
    DDLogVerbose(@"6");

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)attemptingUploadForFilePath:(NSString *)logFilePath
{
    [self.expectation fulfill];
}

- (PDAppDelegate *)appDelegate
{
    return (PDAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end