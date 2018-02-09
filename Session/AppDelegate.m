//
//  AppDelegate.m
//  Session
//
//  Created by 万伟琦 on 2018/2/9.
//  Copyright © 2018年 万伟琦. All rights reserved.
//

#import "AppDelegate.h"




@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	return YES;
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
	
	self.backgroundSessionCompletionHandler = completionHandler = ^(){
		NSLog(@"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
	};
	
}


@end
