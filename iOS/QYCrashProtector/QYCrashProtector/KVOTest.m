//
//  KVOTest.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/10/20.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "KVOTest.h"
#import <objc/runtime.h>

@implementation NSObject (Test)



+(void)doSw
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"addObserver:forKeyPath:options:context:") replaceMethod:NSSelectorFromString(@"qiyes_addObserver:forKeyPath:options:context:")];
        
    });
}


+(BOOL)swizzlingInstance:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector{
    
    Method original = class_getInstanceMethod(clz, originalSelector);
    Method replace = class_getInstanceMethod(clz, replaceSelector);
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSelector,
                    method_getImplementation(replace),
                    method_getTypeEncoding(replace));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            replaceSelector,
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, replace);
    }
    return YES;
}

- (KVODelegate *)KVO_Proxy
{
    id proxy = objc_getAssociatedObject(self, @"KVODelegate_Key");
    
    if (nil == proxy) {
        proxy = [[KVODelegate alloc] init];
        self.KVO_Proxy = proxy;
        NSLog(@"KVODelegate_Key");
    }
    
    return proxy;
}

- (void)setKVO_Proxy:(KVODelegate *)proxy
{
    objc_setAssociatedObject(self, @"KVODelegate_Key", proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)qiye_dealloc
{
    
    [self qiye_dealloc];
}

#pragma KVO
- (void)qiyes_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    NSLog(@"qiyes_addObserver:%@",self);
    [self.KVO_Proxy setSelf:observer];
    [self qiyes_addObserver:self.KVO_Proxy forKeyPath:keyPath options:options context:context];
}

@end

@implementation KVOTest{
    KVODelegate * dele;
    KVOObj      * obj;
}


-(BOOL)swizzlingInstance:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector{
    
    Method original = class_getInstanceMethod(clz, originalSelector);
    Method replace = class_getInstanceMethod(clz, replaceSelector);
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSelector,
                    method_getImplementation(replace),
                    method_getTypeEncoding(replace));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            replaceSelector,
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, replace);
    }
    return YES;
}

-(void)doSwizzling
{
    [NSObject doSw];
//    [self swizzlingInstance:[self class] orginalMethod:NSSelectorFromString(@"addObserver:forKeyPath:options:context:") replaceMethod:NSSelectorFromString(@"qiye_addObserver:forKeyPath:options:context:")];
}

#pragma KVO
//- (void)qiye_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
//{
//    dele = [KVODelegate new];
//    [dele setSelf:observer];
//    [self qiye_addObserver:dele forKeyPath:keyPath options:options context:context];
//}


-(void)doAddObserver
{
    NSLog(@"addObserver");
    obj = [KVOObj new];
    
    [self addObserver:self forKeyPath:@"kvoName" options:NSKeyValueObservingOptionNew context:nil];
    [obj  addObserver:self forKeyPath:@"kvoNames" options:NSKeyValueObservingOptionNew context:nil];
    
    self.kvoName = @"ddsdsddssds";
    obj.kvoNames = @"objobjobj";
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    NSLog(@"observeValueForKeyPath:%@",change);
}

-(void)dealloc
{
    [self removeObserver:[self valueForKey:@"KVO_Proxy"] forKeyPath:@"kvoName"];
    [obj  removeObserver:[obj  valueForKey:@"KVO_Proxy"] forKeyPath:@"kvoNames"];
    NSLog(@"kvoName dealloc");
}

@end

@implementation KVODelegate{
    __weak NSObject  * ktest;
}

-(void)setSelf:(NSObject*) weak
{
    ktest = weak;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    NSLog(@"KVODelegate - observeValueForKeyPath:%@",change);
    if(ktest) [ktest observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(void)dealloc
{
    
    NSLog(@"KVODelegate - kvoName dealloc");
}
@end


@implementation KVOObj
@end


