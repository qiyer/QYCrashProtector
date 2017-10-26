//
//  BClass.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/10/24.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "BClass.h"

@implementation BClass

-(void)doAddObserver
{
    NSLog(@"addObserver");
    [self addObserver:self forKeyPath:@"kvoName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"kvoName" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"kvoName" options:NSKeyValueObservingOptionNew context:nil];
    self.kvoName = @"ddsdsddssds";
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    NSLog(@"observeValueForKeyPath:%@",change);
}

-(void)dealloc
{
//    [self removeObserver:self forKeyPath:@"kvoName"];
//    [self removeObserver:self forKeyPath:@"kvoName"];
    NSLog(@"Bclass is dealloc");
}

@end
