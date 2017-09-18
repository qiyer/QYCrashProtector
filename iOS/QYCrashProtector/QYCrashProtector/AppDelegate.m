//
//  AppDelegate.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "AppDelegate.h"
#import "Test.h"
//#import "NSObject+CrashProtector.h"
#import "SwizzlingTest.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    int a[10];
    
    Test * test = [[Test alloc] init];
    [test performSelector:@selector(haha) withObject:nil];
    
    NSLog(@"=============================================");
    SwizzlingTest * stest = [SwizzlingTest new];
    
    [stest doFuncA];
    [stest doFuncB];
    NSLog(@"=============================================");
    [stest swizzling];
    
    [stest doFuncA];
    [stest doFuncB];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}


@end
