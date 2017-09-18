//
//  CPConfiguration.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "CPConfiguration.h"

@implementation CPConfiguration

-(instancetype)initDefault
{
    if(self = [super init]){
        self.isDebug = NO;
        self.openLog = NO;
        self.style   = CrashProtectorAll;
    }
    return self;
}
@end
