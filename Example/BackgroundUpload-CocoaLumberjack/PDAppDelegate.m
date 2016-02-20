//
//  PDAppDelegate.m
//  BackgroundUpload-CocoaLumberjack
//
//  Created by CocoaPods on 02/12/2015.
//  Copyright (c) 2014 Eric Jensen. All rights reserved.
//

#import "PDAppDelegate.h"

#define DD_LEGACY_MACROS 0
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PDBackgroundUploadLogFileManager.h"

const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface PDAppDelegate()

@property (strong, nonatomic) PDBackgroundUploadLogFileManager *fileManager;
@property (strong, nonatomic) DDFileLogger *fileLogger;

@end

@implementation PDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000/logs"]];
    [request setHTTPMethod:@"POST"];
    
    self.fileManager = [[PDBackgroundUploadLogFileManager alloc] initWithUploadRequest:request];
    self.fileLogger = [[DDFileLogger alloc] initWithLogFileManager:self.fileManager];
    [DDLog addLogger:self.fileLogger];
    
    return YES;
}
							
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    if ([[self.fileManager sessionIdentifier] isEqualToString:identifier]) {
        [self.fileManager handleEventsForBackgroundURLSession:completionHandler];
    }
}

@end
