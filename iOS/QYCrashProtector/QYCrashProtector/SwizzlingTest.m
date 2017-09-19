//
//  SwizzlingTest.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/13.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "SwizzlingTest.h"
#import <objc/runtime.h>

@implementation SwizzlingTest


-(void)doFuncA
{
    NSLog(@"%s",__func__);
    
}

-(void)doFuncB
{
    NSLog(@"%s",__func__);
}

-(void)swizzling
{
    Class class = [self class];
    
    SEL originalSelector = @selector(doFuncA);
    SEL swizzledSelector = @selector(doFuncB);
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (!originalMethod || !swizzledMethod) {
        return;
    }
    
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);
    const char *originalType = method_getTypeEncoding(originalMethod);
    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
    
    // 这儿的先后顺序是有讲究的,如果先执行后一句,那么在执行完瞬间方法被调用容易引发死循环
    class_replaceMethod(class,swizzledSelector,originalIMP,originalType);
    
    IMP originalIMP1 = method_getImplementation(originalMethod);
    IMP swizzledIMP1 = method_getImplementation(swizzledMethod);
    
    class_replaceMethod(class,originalSelector,swizzledIMP,swizzledType);
    
    IMP originalIMP2 = method_getImplementation(originalMethod);
    IMP swizzledIMP2 = method_getImplementation(swizzledMethod);
    NSLog(@"dddddd");
}
@end
