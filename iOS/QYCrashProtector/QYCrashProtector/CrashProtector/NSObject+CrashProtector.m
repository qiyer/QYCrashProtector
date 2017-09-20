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
    return [self swizzingInstance:self orginalMethod:originalSelector replaceMethod:replaceSelector];
}

+ (BOOL)swizzingClassMethod:(SEL)originSelector replaceMethod:(SEL)replaceSelector
{
    return [object_getClass((id)self) swizzingInstanceMethod:originSelector replaceMethod:replaceSelector];
}

+(BOOL)swizzingClass:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector{
    return [object_getClass((id)clz) swizzingInstance:clz orginalMethod:originalSelector replaceMethod:replaceSelector];
}

+(BOOL)swizzingInstance:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector{

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
    NSLog(@"need log msg");
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"need log msg");
}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"need log msg");
    return self;
}

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzingClass:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(initWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"qiye_initWithObjects:forKeys:count:")];
        
        [self swizzingClass:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(dictionaryWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"qiye_dictionaryWithObjects:forKeys:count:")];
        
        [self swizzingInstance:objc_getClass("__NSDictionaryM") orginalMethod:@selector(setObject:forKey:) replaceMethod:NSSelectorFromString(@"qiye_setObject:forKey:")];
        
        [self swizzingInstance:objc_getClass("__NSPlaceholderArray") orginalMethod:@selector(initWithObjects:count:) replaceMethod:NSSelectorFromString(@"qiye_initWithObjects:count:")];
        
        [self swizzingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"qiye_objectAtIndex:")];
        
        [self swizzingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(addObject:) replaceMethod:NSSelectorFromString(@"qiye_addObject:")];
    });
}
@end


//  NSDictionary (CrashProtector)
//  fix
@implementation NSDictionary (CrashProtector)

- (instancetype)qiye_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            NSLog(@"need log msg");
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
            NSLog(@"need log msg");
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

- (void)qiye_setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey{
        if (!anObject || !aKey) {
            NSLog(@"need log msg");
            return;
        }
    [self qiye_setObject:anObject forKey:aKey];
}

@end

//  NSArray (CrashProtector)
//  fix
@implementation NSArray (CrashProtector)

- (instancetype)qiye_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id obj = objects[i];
        if ( !obj) {
            NSLog(@"need log msg");
            continue;
        }
        safeObjects[j] = obj;
        j++;
    }
    return [self qiye_initWithObjects:safeObjects count:j];
}

- (id)qiye_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self qiye_objectAtIndex:index];
}

@end

//  NSMutableArray (CrashProtector)
//  fix
@implementation NSMutableArray (CrashProtector)

- (void)qiye_addObject:(id)anObject
{
    if(nil == anObject){
        NSLog(@"need log msg");
        return ;
    }
    [self qiye_addObject:anObject];
}

- (void)qiye_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if(nil == anObject){
        NSLog(@"need log msg");
        return ;
    }
    [self qiye_insertObject:anObject atIndex:index];
}

@end

