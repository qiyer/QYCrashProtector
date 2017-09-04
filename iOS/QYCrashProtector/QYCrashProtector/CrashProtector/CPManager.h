//
//  CPManager.h
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPConfiguration;


@interface CPManager : NSObject

+(instancetype)instance;

-(void)initWithConfig:(CPConfiguration *) config;

-(void)start;
-(void)stop;

-(void)setLog:(Boolean) isOpen;

@end
