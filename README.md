# BackgroundUpload-CocoaLumberjack

[![CI Status](http://img.shields.io/travis/pushd/BackgroundUpload-CocoaLumberjack.svg?style=flat)](https://travis-ci.org/pushd/BackgroundUpload-CocoaLumberjack)
[![Version](https://img.shields.io/cocoapods/v/BackgroundUpload-CocoaLumberjack.svg?style=flat)](http://cocoadocs.org/docsets/BackgroundUpload-CocoaLumberjack)
[![License](https://img.shields.io/cocoapods/l/BackgroundUpload-CocoaLumberjack.svg?style=flat)](http://cocoadocs.org/docsets/BackgroundUpload-CocoaLumberjack)
[![Platform](https://img.shields.io/cocoapods/p/BackgroundUpload-CocoaLumberjack.svg?style=flat)](http://cocoadocs.org/docsets/BackgroundUpload-CocoaLumberjack)

A CocoaLumberjack log file manager that uses NSURLSession background transfer to upload files when they roll.
This can be used to integrate with any log aggregation service that accepts the log file as the body of an HTTP request,
such as loggly, amazon S3, or your own server.

Uploads are retried everytime another file is rolled (as per DDFileLogger's maximum file size and rolling frequency),
until the file is no longer available (as per DDLogFileManager's maximum number of log files and disk quota).  Log files
are immediately removed from log directory upon successful upload.

## Installation

BackgroundUpload-CocoaLumberjack is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "BackgroundUpload-CocoaLumberjack"

Compatible with CocoaLumberjack 1.x or 2.x.
Use PDBackgroundUploadLogFileManager as the file manaager for your DDFileLogger,
passing it a template NSURLRequest whose body will be set to the content of the log files,
and delegate the application:handleEventsForBackgroundURLSession:completionHandler: method from your application delegate as follows:


```
@interface PDAppDelegate()

@property (strong, nonatomic) PDBackgroundUploadLogFileManager *fileManager;

@end

@implementation PDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000/logs"]];
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
```

## Loggly integration

The above will work to send plain text logs to loggly simply by replacing the URL with the one from https://www.loggly.com/docs/http-bulk-endpoint  To send JSON format logs that will thereby have their original timestamps respected and zoomable in the loggly UI, also use the following:

```
pod 'LogglyLogger-CocoaLumberjack/Formatter'

#import "LogglyFormatter.h"
#import "LogglyFields.h"

[fileLogger setLogFormatter:[[LogglyFormatter alloc] initWithLogglyFieldsDelegate:[LogglyFields new]]];
```

## Author

Eric Jensen, ej@pushd.com

## License

BackgroundUpload-CocoaLumberjack is available under the MIT license. See the LICENSE file for more info.

## TODO

Compression:  Loggly doesn't support compression even via Content-Encoding, but it seems like the sane thing to do.  CocoaLumberjack has an example but it's not included in the pod and the DDLogFileManager interface should probably be refactored to delegate rather than require inheritance to be sent didRollAndArchiveLogFile: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Demos/LogFileCompressor/CompressingLogFileManager.m