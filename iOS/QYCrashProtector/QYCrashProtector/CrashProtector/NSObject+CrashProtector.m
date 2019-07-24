//
//  NSObject+CrashProtector.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "NSObject+CrashProtector.h"
#import <objc/runtime.h>
#import <pthread.h>

// CrashProxy
// get crash message
@implementation CrashProxy

- (id)getCrashMsg{
    NSLog(@"%@",_crashMsg);
    return nil;
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSObject (CrashProtector)
// fix "unrecognized selector" ,"KVC"
static void *NSObjectKVOProxyKey = &NSObjectKVOProxyKey;
@implementation NSObject (CrashProtector)

+ (void)openCP
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzlingInstance:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(initWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"qiye_initWithObjects:forKeys:count:")];
        
        [self swizzlingInstance:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(dictionaryWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"qiye_dictionaryWithObjects:forKeys:count:")];
        
        [self swizzlingInstance:objc_getClass("__NSDictionaryM") orginalMethod:@selector(setObject:forKey:) replaceMethod:NSSelectorFromString(@"qiye_setObject:forKey:")];
        
        [self swizzlingInstance:objc_getClass("__NSPlaceholderArray") orginalMethod:@selector(initWithObjects:count:) replaceMethod:NSSelectorFromString(@"qiye_initWithObjects:count:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"qiye_objectAtIndex:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndexedSubscript:) replaceMethod:@selector(qiye_objectAtIndexedSubscript:)];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(addObject:) replaceMethod:NSSelectorFromString(@"qiye_addObject:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(insertObject:atIndex:) replaceMethod:NSSelectorFromString(@"qiye_insertObject:atIndex:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"qiye_objectAtIndex:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(objectAtIndexedSubscript:) replaceMethod:NSSelectorFromString(@"qiye_objectAtIndexedSubscript:")];
        
        [self swizzlingInstance:objc_getClass("NSPlaceholderString") orginalMethod:@selector(initWithString:) replaceMethod:NSSelectorFromString(@"qiye_initWithString:")];
        
        [self swizzlingInstance:objc_getClass("__NSCFConstantString") orginalMethod:@selector(hasSuffix:) replaceMethod:NSSelectorFromString(@"qiye_hasSuffix:")];
        
        [self swizzlingInstance:objc_getClass("__NSCFConstantString") orginalMethod:@selector(hasPrefix:) replaceMethod:NSSelectorFromString(@"qiye_hasPrefix:")];
        
        [self swizzlingInstance:objc_getClass("NSPlaceholderMutableString") orginalMethod:@selector(initWithString:) replaceMethod:NSSelectorFromString(@"qiye_initWithString:")];
        
        [self swizzlingClass:objc_getClass("NSTimer") replaceClassMethod:NSSelectorFromString(@"scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:") withMethod:NSSelectorFromString(@"qiye_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:")];
        
        [self swizzlingClass:objc_getClass("NSTimer") replaceClassMethod:@selector(timerWithTimeInterval:target:selector:userInfo:repeats:) withMethod:NSSelectorFromString(@"qiye_timerWithTimeInterval:target:selector:userInfo:repeats:")];
        
        [self swizzlingInstance:objc_getClass("NSNotificationCenter") orginalMethod:NSSelectorFromString(@"addObserver:selector:name:object:") replaceMethod:NSSelectorFromString(@"qiye_addObserver:selector:name:object:")];
        
        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"dealloc") replaceMethod:NSSelectorFromString(@"qiye_dealloc")];
        
        //暂时注释kvo预防，该逻辑在 xcode9.2 真机测试会 crash
        
//        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"addObserver:forKeyPath:options:context:") replaceMethod:NSSelectorFromString(@"qiye_addObserver:forKeyPath:options:context:")];
//
//        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"removeObserver:forKeyPath:") replaceMethod:NSSelectorFromString(@"qiye_removeObserver:forKeyPath:")];
        
    });
}

#pragma load
+(void)load
{
    if (!CP_OPEN) {
        NSLog(@"CrashProtector  close !");
        return;
    }
    NSLog(@"CrashProtector  open !");
    [self openCP];
}

//在进行方法swizzing时候，一定要注意类簇 ，比如 NSArray NSDictionary 等。
+ (BOOL)swizzlingInstanceMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector
{
    return [self swizzlingInstance:self orginalMethod:originalSelector replaceMethod:replaceSelector];
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

+ (BOOL)swizzlingClass:(Class)klass replaceClassMethod:(SEL)methodSelector1 withMethod:(SEL)methodSelector2
{
    if (!klass || !methodSelector1 || !methodSelector2) {
        NSLog(@"Nil Parameter(s) found when swizzling.");
        return NO;
    }
    
    Method method1 = class_getClassMethod(klass, methodSelector1);
    Method method2 = class_getClassMethod(klass, methodSelector2);
    if (method1 && method2) {
        IMP imp1 = method_getImplementation(method1);
        IMP imp2 = method_getImplementation(method2);
        
        Class classMeta = object_getClass(klass);
        if (class_addMethod(classMeta, methodSelector1, imp2, method_getTypeEncoding(method2))) {
            class_replaceMethod(classMeta, methodSelector2, imp1, method_getTypeEncoding(method1));
        } else {
            method_exchangeImplementations(method1, method2);
        }
        return YES;
    } else {
        NSLog(@"Swizzling Method(s) not found while swizzling class %@.", NSStringFromClass(klass));
        return NO;
    }
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

#pragma NSNotification
-(void)qiye_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject
{
    [observer setIsNSNotification:YES];
    [self qiye_addObserver:observer selector:aSelector name:aName object:anObject];
}

-(void)qiye_dealloc
{
    if ([self isNSNotification]) {
        NSLog(@"[Notification] need log msg");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [self qiye_dealloc];
}

static const char *isNSNotification = "isNSNotification";

-(void)setIsNSNotification:(BOOL)yesOrNo
{
    objc_setAssociatedObject(self, isNSNotification, @(yesOrNo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isNSNotification
{
    NSNumber *number = objc_getAssociatedObject(self, isNSNotification);;
    return  [number boolValue];
}

#pragma KVO
- (void)qiye_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    CPKVOInfo * kvoInfo = [[CPKVOInfo alloc] initWithKeyPath:keyPath options:options context:context];
    __weak typeof(self) wkself = self;
    if([self.KVOProxy addKVOinfo:wkself info:kvoInfo]){
        [self qiye_addObserver:self.KVOProxy forKeyPath:keyPath options:options context:context];
    }else{
        NSLog(@"KVO is more");
    }
}

- (void)qiye_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    NSLog(@"qiye_removeObserver");
    [self.KVOProxy removeKVOinfo:self keyPath:keyPath block:^{
        [self qiye_removeObserver:observer forKeyPath:keyPath];
    }];
}

- (KVOProxy *)KVOProxy
{
    id proxy = objc_getAssociatedObject(self, NSObjectKVOProxyKey);
    
    if (nil == proxy) {
        proxy = [[KVOProxy alloc] init];
        self.KVOProxy = proxy;
    }
    
    return proxy;
}

- (void)setKVOProxy:(KVOProxy *)proxy
{
    objc_setAssociatedObject(self, NSObjectKVOProxyKey, proxy, OBJC_ASSOCIATION_ASSIGN);
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------------------------------------------------------
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

- (id)qiye_objectAtIndexedSubscript:(NSUInteger)index {
    if (index >= self.count ) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self qiye_objectAtIndexedSubscript:index];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
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

- (id)qiye_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self qiye_objectAtIndex:index];
}

- (id)qiye_objectAtIndexedSubscript:(NSUInteger)index {
    if (index >= self.count ) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self qiye_objectAtIndexedSubscript:index];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  NSString (CrashProtector)
//  fix
@implementation NSString (CrashProtector)

- (instancetype)qiye_initWithString:(NSString *)aString
{
    if(nil == aString){
        NSLog(@"need log msg");
        return nil;
    }
    return [self qiye_initWithString:aString];
}

- (BOOL)qiye_hasPrefix:(NSString *)str
{
    if(nil == str){
        NSLog(@"need log msg");
        return NO;
    }
    return [self qiye_hasPrefix:str];
}

- (BOOL)qiye_hasSuffix:(NSString *)str
{
    if(nil == str){
        NSLog(@"need log msg");
        return NO;
    }
    return [self qiye_hasSuffix:str];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  NSMutableString (CrashProtector)
//  fix
@implementation NSMutableString (CrashProtector)

- (instancetype)qiye_initWithString:(NSString *)aString
{
    if(nil == aString){
        NSLog(@"need log msg");
        return nil;
    }
    return [self qiye_initWithString:aString];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  CPWeakProxy
@implementation CPWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[CPWeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  NSTimer (CrashProtector)
//  fix
@implementation NSTimer (CrashProtector)


+ (NSTimer *)qiye_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo
{
    NSLog(@"qiye_scheduledTimerWithTimeInterval");
    return [self qiye_scheduledTimerWithTimeInterval:ti target:[CPWeakProxy proxyWithTarget:aTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)qiye_timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    NSLog(@"qiye_timerWithTimeInterval");
    return [self qiye_timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}
@end

//-----------------------------------------------------------------------------------------------------------------------------
//  KVOProxy
//  fix
@implementation KVOProxy{
    pthread_mutex_t _mutex;
    NSMapTable<id, NSMutableSet<CPKVOInfo *> *> *_objectInfosMap;
}


- (instancetype)init
{
    self = [super init];
    if (nil != self) {

        _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];

        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

-(BOOL)addKVOinfo:(id)object info:(CPKVOInfo *)info
{
    [self lock];
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    __block BOOL isHas = NO;
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([[info valueForKey:@"_keyPath"] isEqualToString:[obj valueForKey:@"_keyPath"]]){
            *stop = YES;
            isHas = YES;
        }
    }];
    if(isHas) {
        [self unlock];
        return NO ;
    }
    if(nil == infos){
        infos = [NSMutableSet set];
        [_objectInfosMap setObject:infos forKey:object];
    }
    [infos addObject:info];
    [self unlock];
    
    return YES;
}

-(void)removeKVOinfo:(id)object keyPath:(NSString *)keyPath block:(void(^)()) block
{
    [self lock];
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    __block CPKVOInfo *info;
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([keyPath isEqualToString:[obj valueForKey:@"_keyPath"]]){
            info = (CPKVOInfo *)obj;
            *stop = YES;
        }
    }];
    
    if (nil != info) {
        [infos removeObject:info];
        block();
        if (0 == infos.count) {
            [_objectInfosMap removeObjectForKey:object];
        }
    }
    [self unlock];
}

-(void)removeAllObserve
{
    if (_objectInfosMap) {
        NSMapTable *objectInfoMaps = [_objectInfosMap copy];
        for (id object in objectInfoMaps) {

            NSSet *infos = [objectInfoMaps objectForKey:object];
            if(nil==infos || infos.count==0) continue;
            [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                CPKVOInfo *info = (CPKVOInfo *)obj;
                [object removeObserver:self forKeyPath:[info valueForKey:@"_keyPath"]];
            }];
        }
        [_objectInfosMap removeAllObjects];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    NSLog(@"KVOProxy - observeValueForKeyPath :%@",change);
    __block CPKVOInfo *info ;
    {
        [self lock];
        NSSet *infos = [_objectInfosMap objectForKey:object];
        [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([keyPath isEqualToString:[obj valueForKey:@"_keyPath"]]){
                info = (CPKVOInfo *)obj;
                *stop = YES;
            }
        }];
        [self unlock];
    }
    
    if (nil != info) {
        [object observeValueForKeyPath:keyPath ofObject:object change:change context:(__bridge void * _Nullable)([info valueForKey:@"_context"])];
    }
}

-(void)lock
{
    pthread_mutex_lock(&_mutex);
}

-(void)unlock
{
    pthread_mutex_unlock(&_mutex);
}

- (void)dealloc
{
    [self removeAllObserve];
    pthread_mutex_destroy(&_mutex);
     NSLog(@"KVOProxy dealloc");
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  CPKVOInfo
@implementation CPKVOInfo{
@public
    NSString *_keyPath;
    NSKeyValueObservingOptions _options;
    SEL _action;
    void *_context;
    CPKVONotificationBlock _block;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(nullable CPKVONotificationBlock)block
                         action:(nullable SEL)action
                        context:(nullable void *)context
{
    self = [super init];
    if (nil != self) {
        _block = [block copy];
        _keyPath = [keyPath copy];
        _options = options;
        _action = action;
        _context = context;
    }
    return self;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    return [self initWithKeyPath:keyPath options:options block:NULL action:NULL context:context];
}

@end
