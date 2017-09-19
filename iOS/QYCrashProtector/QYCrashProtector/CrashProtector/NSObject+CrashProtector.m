//
//  NSObject+CrashProtector.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "NSObject+CrashProtector.h"
#import <objc/runtime.h>

// CrashProxy
// get crash message
@implementation CrashProxy

- (void)getCrashMsg{
    NSLog(@"%@",_crashMsg);
}

@end

// NSObject (CrashProtector)
// fix "unrecognized selector" ,"KVC"
@implementation NSObject (CrashProtector)

//在进行方法swizzing时候，一定要注意类簇 ，比如 NSArray NSDictionary 等。
+ (BOOL)swizzingInstanceMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector
{
    Method original = class_getInstanceMethod(self, originalSelector);
    Method replace = class_getInstanceMethod(self, replaceSelector);
    BOOL didAddMethod =
    class_addMethod(self,
                    originalSelector,
                    method_getImplementation(replace),
                    method_getTypeEncoding(replace));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            replaceSelector,
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, replace);
    }
    return YES;
}

+ (BOOL)swizzingClassMethod:(SEL)originSelector replaceMethod:(SEL)replaceSelector
{
    return [object_getClass((id)self) swizzingInstanceMethod:originSelector replaceMethod:replaceSelector];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-protocol-method-implementation"
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([NSStringFromClass([self class]) hasPrefix:@"_"] || [self isKindOfClass:NSClassFromString(@"UITextInputController")] || [NSStringFromClass([self class]) hasPrefix:@"UIKeyboard"] || [methodName isEqualToString:@"dealloc"]) {
        
        return nil;
    }

    CrashProxy * crashProxy = [CrashProxy new];
    crashProxy.crashMsg =[NSString stringWithFormat:@"CrashProtector: [%@ %p %@]: unrecognized selector sent to instance",NSStringFromClass([self class]),self,NSStringFromSelector(aSelector)];
    class_addMethod([CrashProxy class], aSelector, [crashProxy methodForSelector:@selector(getCrashMsg)], "v@:");
    
    return crashProxy;
}
#pragma clang diagnostic pop


#pragma KVC Protect
-(void)setNilValueForKey:(NSString *)key
{
    
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    return self;
}

@end


//  NSDictionary (CrashProtector)
//  fix
@implementation NSDictionary (CrashProtector)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzingClassMethod:@selector(initWithObjects:forKeys:count:) replaceMethod:@selector(qiye_initWithObjects:forKeys:count:)];
        [self swizzingClassMethod:@selector(dictionaryWithObjects:forKeys:count:) replaceMethod:@selector(qiye_dictionaryWithObjects:forKeys:count:)];
    });
}

- (instancetype)qiye_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return  [self qiye_initWithObjects:safeObjects forKeys:safeKeys count:j];
}


+ (instancetype)qiye_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return [self qiye_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end


//  NSMutableDictionary (CrashProtector)
//  fix
@implementation NSMutableDictionary (CrashProtector)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzingInstanceMethod:@selector(setObject:forKey:) replaceMethod:@selector(qiye_setObject:forKey:)];
    });
}

- (void)qiye_setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey{
        if (!anObject || !aKey) {
            return;
        }
        NSLog(@"ccccccccc");
    [self qiye_setObject:anObject forKey:aKey];
}

@end

