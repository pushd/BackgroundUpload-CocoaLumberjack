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

@protocol PDBackgroundUploadLogFileManagerDelegate <NSObject>
@optional
- (void)attemptingUploadForFilePath:(NSString *)logFilePath;
- (void)uploadTaskForFilePath:(NSString *)logFilePath didCompleteWithError:(NSError *)error;
@end

@interface PDBackgroundUploadLogFileManager : DDLogFileManagerDefault<NSURLSessionDelegate,NSURLSessionTaskDelegate>

- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest;

- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary delegate:(id<PDBackgroundUploadLogFileManagerDelegate>)delegate;

- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary delegate:(id<PDBackgroundUploadLogFileManagerDelegate>)delegate logsDirectory:(NSString *)logsDirectory;

#if TARGET_OS_IPHONE
- (instancetype)initWithWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary delegate:(id<PDBackgroundUploadLogFileManagerDelegate>)delegate logsDirectory:(NSString *)logsDirectory defaultFileProtectionLevel:(NSString*)fileProtectionLevel;
#endif

- (NSString *)sessionIdentifier;
- (void)handleEventsForBackgroundURLSession:(void (^)())completionHandler;

@end
