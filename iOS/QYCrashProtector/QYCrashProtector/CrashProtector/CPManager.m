//
//  CPManager.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "CPManager.h"
#import "CPConfiguration.h"

@implementation CPManager
{
    CPConfiguration* configs;
}

+(instancetype)instance
{
    static CPManager* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == _instance) {
            _instance = [[CPManager alloc] init];
        }
    });
    return _instance;
}

-(void)initWithConfig:(CPConfiguration*) config
{
    configs = config?:[CPConfiguration initDefault];
}

-(void)start
{
    
}

-(void)stop
{
    
}

-(void)setLog:(Boolean) isOpen
{
    
}

@end
