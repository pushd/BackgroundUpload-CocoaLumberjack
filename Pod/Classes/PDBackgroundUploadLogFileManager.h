//
//  PDBackgroundUploadLogFileManager.h
//  Pods
//
//  Created by Eric Jensen on 2/12/15.
//
//

#import <Foundation/Foundation.h>
#import "DDLog.h"
#import "DDFileLogger.h"

@interface PDBackgroundUploadLogFileManager : DDLogFileManagerDefault<NSURLSessionDelegate,NSURLSessionTaskDelegate>

- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest;
- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary;
- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary logsDirectory:(NSString *)logsDirectory;
#if TARGET_OS_IPHONE
- (instancetype)initWithWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary logsDirectory:(NSString *)logsDirectory defaultFileProtectionLevel:(NSString*)fileProtectionLevel;
#endif

- (NSString *)sessionIdentifier;
- (void)handleEventsForBackgroundURLSession:(void (^)())completionHandler;

@end
