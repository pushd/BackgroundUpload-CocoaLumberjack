//
//  PDBackgroundUploadLogFileManager.h
//  Pods
//
//  Created by Eric Jensen on 2/12/15.
//
//

#import <Foundation/Foundation.h>
#define DD_LEGACY_MACROS 0
#import <CocoaLumberjack/CocoaLumberjack.h>

/**
 Optional delegate to notify about uploads
 */
@protocol PDBackgroundUploadLogFileManagerDelegate <NSObject>
@optional

/**
 called for each retry
 */
- (void)attemptingUploadForFilePath:(NSString *)logFilePath;

/**
 called once upon final success or failure
 */
- (void)uploadTaskForFilePath:(NSString *)logFilePath didCompleteWithError:(NSError *)error;

@end


/**
 A CocoaLumberjack log file manager that uses NSURLSession background transfer to upload files when they roll. Uploads are retried everytime another file is rolled (as per DDFileLogger's maximum file size and rolling frequency), until the file is no longer available (as per DDLogFileManager's maximum number of log files and disk quota). Log files are immediately removed from log directory upon successful upload.
 */
@interface PDBackgroundUploadLogFileManager : DDLogFileManagerDefault<NSURLSessionDelegate,NSURLSessionTaskDelegate>

/**
 Initializes
 
 @param uploadRequest template request whose body will be set to the content of the log files
 */
- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest;

/**
 Initializes
 
 @param uploadRequest template request whose body will be set to the content of the log files
 @param discretionary passed to NSURLSessionConfiguration.discretionary
 */
- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary delegate:(id<PDBackgroundUploadLogFileManagerDelegate>)delegate;

/**
 Initializes
 
 @param uploadRequest template request whose body will be set to the content of the log files
 @param discretionary passed to NSURLSessionConfiguration.discretionary
 @param delegate to notify about uploads
 @param logsDirectory passed to DDLogFileManagerDefault to override default directory to manage
 */
- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary delegate:(id<PDBackgroundUploadLogFileManagerDelegate>)delegate logsDirectory:(NSString *)logsDirectory;

#if TARGET_OS_IPHONE
/**
 Initializes
 
 @param uploadRequest template request whose body will be set to the content of the log files
 @param discretionary passed to NSURLSessionConfiguration.discretionary
 @param delegate to notify about uploads
 @param logsDirectory passed to DDLogFileManagerDefault to override default directory to manage
 @param fileProtectionLevel passed to DDLogFileManagerDefault override its default NSFileProtectionKey (either NSFileProtectionCompleteUntilFirstUserAuthentication if app lists background modes otherwise NSFileProtectionCompleteUnlessOpen) attribute on log files
 */
- (instancetype)initWithWithUploadRequest:(NSURLRequest *)uploadRequest discretionary:(BOOL)discretionary delegate:(id<PDBackgroundUploadLogFileManagerDelegate>)delegate logsDirectory:(NSString *)logsDirectory defaultFileProtectionLevel:(NSString*)fileProtectionLevel;
#endif

/**
 identifier to test before delegating call to application:handleEventsForBackgroundURLSession:completionHandler: method from your application delegate to handleEventsForBackgroundURLSession:
 */
- (NSString *)sessionIdentifier;

/**
  you must delegate calls to your application delegate's application:handleEventsForBackgroundURLSession:completionHandler: method to this if sessionIdentifier matches
 */
- (void)handleEventsForBackgroundURLSession:(void (^)())completionHandler;

@end
