//
//  PDBackgroundUploadLogFileManager.m
//  Pods
//
//  Created by Eric Jensen on 2/12/15.
//
//

#import "PDBackgroundUploadLogFileManager.h"

@interface PDBackgroundUploadLogFileManager()

@property (strong, nonatomic) NSURLRequest *uploadRequest;
@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic) void(^completionHandler)();

@end

@implementation PDBackgroundUploadLogFileManager

- (id)initWithUploadRequest:(NSURLRequest *)uploadRequest
{
    if ((self = [super init])) {
        _uploadRequest = uploadRequest;
        [self setupSession];
    }
    return self;
}

- (instancetype)initWithUploadRequest:(NSURLRequest *)uploadRequest logsDirectory:(NSString *)logsDirectory
{
    if ((self = [super initWithLogsDirectory:logsDirectory])) {
        _uploadRequest = uploadRequest;
        [self setupSession];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (instancetype)initWithWithUploadRequest:(NSURLRequest *)uploadRequest logsDirectory:(NSString *)logsDirectory defaultFileProtectionLevel:(NSString*)fileProtectionLevel
{
    if ((self = [super initWithLogsDirectory:logsDirectory defaultFileProtectionLevel:fileProtectionLevel])) {
        _uploadRequest = uploadRequest;
        [self setupSession];
    }
    return self;
}
#endif

- (NSString *)sessionIdentifier
{
    return [self logsDirectory];
}

#pragma mark - Notifications from DDFileLogger

- (void)didArchiveLogFile:(NSString *)logFilePath
{
    NSLog(@"BackgroundUploadLogFileManager: didArchiveLogFile: %@", [logFilePath lastPathComponent]);
    [self uploadArchivedFiles];
}

- (void)didRollAndArchiveLogFile:(NSString *)logFilePath
{
    NSLog(@"BackgroundUploadLogFileManager: didRollAndArchiveLogFile: %@", [logFilePath lastPathComponent]);
    [self uploadArchivedFiles];
}

#pragma mark - private

- (void)setupSession
{
    NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self sessionIdentifier]];
    backgroundConfiguration.discretionary = YES; // prevent uploading unless on wi-fi even if log is rolled in foreground
    self.session = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:self delegateQueue:nil];
}

// retries any files that may have errored
- (void)uploadArchivedFiles
{
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        dispatch_async([DDLog loggingQueue], ^{ @autoreleasepool {
            NSArray *fileInfos = [self unsortedLogFileInfos];
            NSMutableSet *filesToUpload = [NSMutableSet setWithCapacity:[fileInfos count]];
            for (DDLogFileInfo *fileInfo in fileInfos) {
                if (fileInfo.isArchived) {
                    [filesToUpload addObject:fileInfo.filePath];
                }
            }
            
            for (NSURLSessionTask *task in uploadTasks) {
                [filesToUpload removeObject:[self filePathForTask:task]];
            }
            
            for (NSString *filePath in filesToUpload) {
                [self uploadLogFile:filePath];
            }
        }});
    }];
}

- (void)uploadLogFile:(NSString *)logFilePath
{
    NSURLSessionTask *task = [self.session uploadTaskWithRequest:self.uploadRequest fromFile:[NSURL fileURLWithPath:logFilePath]];
    task.taskDescription = logFilePath;
    NSLog(@"BackgroundUploadLogFileManager: started uploading: %@", [self filePathForTask:task]);
    [task resume];
}

- (NSString *)filePathForTask:(NSURLSessionTask *)task
{
    return task.taskDescription;
}

#pragma mark - app delegate forwarding

- (void)handleEventsForBackgroundURLSession:(void (^)())completionHandler
{
    self.completionHandler = completionHandler;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"BackgroundUploadLogFileManager: task: %@ didCompleteWithError: %@", [self filePathForTask:task], error);
    
    if (!error) {
        dispatch_async([DDLog loggingQueue], ^{
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:[self filePathForTask:task] error:&error];
            if (error) {
                NSLog(@"BackgroundUploadLogFileManager: Error deleting file %@: %@", [self filePathForTask:task], error);
            }
        });
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([uploadTasks count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.completionHandler) {
                    self.completionHandler();
                    self.completionHandler = nil;
                }
            });
        } else {
            NSLog(@"BackgroundUploadLogFileManager: did finish but tasks present %@", uploadTasks);
        }
    }];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"BackgroundUploadLogFileManager: session: %@ didBecomeInvalidWithError: %@", session, error);
    [self setupSession];
}

@end
