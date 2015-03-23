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
    // WARNING: to minimize battery usage, avoid energy intensive operations such as network requests from controllers
    //          when launched in UIApplicationStateBackground in response to log uploads until applicationDidBecomeActive
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:3000/logs"]];
    [request setHTTPMethod:@"POST"];

    self.fileManager = [[PDBackgroundUploadLogFileManager alloc] initWithUploadRequest:request];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:self.fileManager];
    [DDLog addLogger:fileLogger];

    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    if ([[self.fileManager sessionIdentifier] isEqualToString:identifier]) {
        [self.fileManager handleEventsForBackgroundURLSession:completionHandler];
    }
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

## Discretionary background uploads

Unless you override using initWithUploadRequest:discretionary:delegate:, the default is to set the discretionary flag on all upload tasks.  As per [NSURLSessionConfiguration](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSessionConfiguration_class/index.html#//apple_ref/occ/instp/NSURLSessionConfiguration/discretionary), this means uploads only happen when connected to a wifi network with enough battery.  Therefore, users who never connect to wifi or uninstall your app before they do won't upload any logs, and even those who do will have their logs delayed until they are on wifi.  This is typically an acceptable tradeoff for logs that reduces battery and data usage.  If you implement the delegate protocol, you'll see users who keep the app but don't connect to wifi for your maximum log retention time call back with Error Domain=NSPOSIXErrorDomain Code=2 "The operation couldn’t be completed. No such file or directory"

## Battery usage

We ran our app which uses background location on two test iphone 5s that we carried together, one with this pod uploading to loggly and one without it, barely unlocking them from 100% charge until they powered down so we could isolate background battery usage (even though foreground usage of the phone typically dominates).  The difference between uploading logs and not was within the noise:  ~4% in terms of both hours of battery life and reported battery usage in settings.  Over the course of about 6 days, it logged about 10,000 lines (less than 2MB total) and probably uploaded on 10 different occasions.  Cellular data usage was identical, confirming it did indeed only upload on wifi.

## Author

Eric Jensen, ej@pushd.com

## License

BackgroundUpload-CocoaLumberjack is available under the MIT license. See the LICENSE file for more info.

## TODO

Compression:  Loggly doesn't support compression even via Content-Encoding, but it seems like the sane thing to do.  CocoaLumberjack has an example but it's not included in the pod and the DDLogFileManager interface should probably be refactored to delegate rather than require inheritance to be sent didRollAndArchiveLogFile: [CompressingLogFileManager](https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Demos/LogFileCompressor/CompressingLogFileManager.m)
