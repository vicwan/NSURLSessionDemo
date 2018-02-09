//
//  ViewController.m
//  Session
//
//  Created by 万伟琦 on 2018/2/9.
//  Copyright © 2018年 万伟琦. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


static NSString *urlString = @"http://papers.co/wallpaper/papers.co-ad02-wallpaper-apple-ios8-iphone6-plus-official-darker-starry-night-8-wallpaper.jpg";


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *ImgView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseBtn;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;

@end

@implementation ViewController

- (void)testDD {
	NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"background"];
	NSURLSessionConfiguration *ephemeralConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
	NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
	[self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
		
	}];
	[self.session downloadTaskWithResumeData:nil];
	[self.session downloadTaskWithResumeData:nil completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		
	}];
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.session = [self backgroundSession];
	self.ImgView.hidden = NO;
	self.progressView.hidden = YES;
	self.pauseBtn.enabled = NO;
}


- (IBAction)start:(id)sender {
	
	if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateRunning) {
		return;
	}
	
//	if (self.downloadTask && self.downloadTask.state == NSURLSessionTaskStateSuspended) {
//
//	}
	if (self.resumeData) {
		self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
		[self.downloadTask resume];
	}else {
		
		NSURL *url = [NSURL URLWithString:urlString];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		self.downloadTask = [self.session downloadTaskWithRequest:request];
		[self.downloadTask resume];
	}
	
	self.ImgView.hidden = YES;
	self.progressView.hidden = NO;
	self.pauseBtn.enabled = YES;
}
- (IBAction)pause:(id)sender {
	if (!self.downloadTask) {
		return;
	}
//	[self.downloadTask suspend];
	[self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
		self.resumeData = resumeData;
		NSLog(@"...");
	}];
	self.pauseBtn.enabled = NO;
}

- (NSURLSession *)backgroundSession {
	static NSURLSession *session = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURLSessionConfiguration *c = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"cn.com.zte.zmail_vicwan_session_test"];
		session = [NSURLSession sessionWithConfiguration:c delegate:self delegateQueue:nil];
	});
	return session;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
	
	if (downloadTask == self.downloadTask) {
		double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
		dispatch_async(dispatch_get_main_queue(), ^{
			self.progressView.progress = progress;
		});
	}
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
	NSURL *documentsDirectory = URLs.firstObject;
	
	NSURL *originalURL = [downloadTask currentRequest].URL;
	NSURL *destURL = [documentsDirectory URLByAppendingPathComponent:originalURL.lastPathComponent];
	NSError *errorCopy;
	
	[fileManager removeItemAtURL:destURL error:&errorCopy];
	BOOL success = [fileManager copyItemAtURL:location toURL:destURL error:&errorCopy];

	if (success) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.ImgView.image = [UIImage imageWithContentsOfFile:destURL.path];
			self.ImgView.hidden = NO;
			self.progressView.hidden = YES;
		});
	}
	self.resumeData = nil;
}

- (void)fullDataHandler {
	
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
	if (nil == error) {
		NSLog(@"Task finished in success.");
	}else {
		NSLog(@"Task finished with error: %@", error);
	}
	
	double progress =  (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.progressView.progress = progress;
	});
	self.downloadTask = nil;
	
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
	UIApplication *app = [UIApplication sharedApplication];
	AppDelegate *appDelegate = (AppDelegate *)app.delegate;
	if (appDelegate.backgroundSessionCompletionHandler) {
		void(^completion)(void) = appDelegate.backgroundSessionCompletionHandler;
		completion();
		appDelegate.backgroundSessionCompletionHandler = nil;
	}
	NSLog(@"Session: %@. All tasks finished", session);
}

@end
