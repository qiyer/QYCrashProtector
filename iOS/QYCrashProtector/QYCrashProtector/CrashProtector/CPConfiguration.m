//
//  CPConfiguration.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "CPConfiguration.h"

@implementation CPConfiguration

+(instancetype)initDefault
{
    CPConfiguration * config = [CPConfiguration new];
    config.isDebug = NO;
    config.openLog = NO;
    config.style   = CrashProtectorAll;
    
    return config;
}
@end
