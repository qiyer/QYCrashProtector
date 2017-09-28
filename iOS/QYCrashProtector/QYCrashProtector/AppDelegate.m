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

#import "NSObject+CrashProtector.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    int a[10];
    
    Test * test = [[Test alloc] init];
    [test performSelector:@selector(haha) withObject:nil];
    
    
    NSString * tt  = nil;
    NSDictionary * dic = @{@"sss":@"cccc",@"name":tt};
    NSMutableDictionary * dic2 = [[NSMutableDictionary alloc] init];
    [dic2 setObject:tt forKey:@"cccc"];
    [dic2 setObject:@"xxxx" forKey:@"key1"];
    [dic2 setObject:@"xxxx" forKey:@"key2"];
    
    [dic objectForKey:tt];
    NSLog(@"dddd");
    
    NSArray * arr = @[@"111",@"222",tt,@"ddd"];
    NSArray * arr2 = @[@[@"aa",@"bb"],@[@"dd",tt]];
    NSArray *arr3 = [NSArray arrayWithObjects:@"dsd",tt,@"sdsd", nil];
    arr[3];
    
    NSMutableArray * arr4 = [NSMutableArray array];
    [arr4 addObject:tt];
    [arr4 insertObject:tt atIndex:0];
    [arr4 insertObject:@"ccc" atIndex:0];
    [arr4 objectAtIndex:2];
    
    NSString * str = [[NSString alloc] initWithString:nil];
    [@"dddd" hasSuffix:nil];
    
    NSString * str2 = [NSMutableString stringWithString:nil];
    
    [test doTimerTest];
    
    [test doNotificationTest];
    NSLog(@"xxxxxx");
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
