//
//  PDAppDelegate.m
//  BackgroundUpload-CocoaLumberjack
//
//  Created by CocoaPods on 02/12/2015.
//  Copyright (c) 2014 Eric Jensen. All rights reserved.
//

#import "PDAppDelegate.h"

#import "DDLog.h"
#import "DDFileLogger.h"
#import "PDBackgroundUploadLogFileManager.h"

@interface PDAppDelegate()

@property (strong, nonatomic) PDBackgroundUploadLogFileManager *fileManager;

@end

@implementation PDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:4567/logs/create"]];
    [request setHTTPMethod:@"POST"];
    
    self.fileManager = [[PDBackgroundUploadLogFileManager alloc] initWithUploadRequest:request];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:self.fileManager];
    [DDLog addLogger:fileLogger];
    
    return YES;
}
							
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    [self.fileManager handleEventsForBackgroundURLSession:completionHandler];
}

@end
