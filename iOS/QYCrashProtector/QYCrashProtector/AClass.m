//
//  AClass.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/10/18.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "AClass.h"

@implementation AClass
{
    NSString * name;
}

-(void)dealloc
{
//    __weak __typeof(self) wkself = self;
//    NSLog(@"DD：%@",wkself);
    name = @"ddddd";
    NSLog(@"xxxx:%@",name);
    NSLog(@"DD：%@",self);
     id __weak obj1 = self;
    NSLog(@"DD：%@",obj1);
}

@end
