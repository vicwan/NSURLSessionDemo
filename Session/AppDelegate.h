//
//  AppDelegate.h
//  Session
//
//  Created by 万伟琦 on 2018/2/9.
//  Copyright © 2018年 万伟琦. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy) void(^backgroundSessionCompletionHandler)(void);

@end

