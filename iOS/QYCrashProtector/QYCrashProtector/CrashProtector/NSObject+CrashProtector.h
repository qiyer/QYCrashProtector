//
//  NSObject+CrashProtector.h
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CP_OPEN  YES

@interface CrashProxy : NSObject

@property (nonatomic,copy) NSString * _Nullable crashMsg;

- (void)getCrashMsg;

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSObject
@interface NSObject (CrashProtector)

+ (BOOL)swizzlingInstanceMethod:(SEL _Nullable )originalSelector  replaceMethod:(SEL _Nullable )replaceSelector;

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSDictionary
@interface NSDictionary (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSMutableDictionary
@interface NSMutableDictionary (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSArray
@interface NSArray (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSMutableArray
@interface NSMutableArray (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSString
@interface NSString (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSMutableString
@interface NSMutableString (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
//CPWeakProxy
//拿了YY大神的YYWeakProxy，感谢YY大神   链接 :https://github.com/ibireme/YYKit/blob/master/YYKit/Utility/YYWeakProxy.h
@interface CPWeakProxy : NSProxy

/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype _Nullable )initWithTarget:(id _Nullable )target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype _Nullable )proxyWithTarget:(id _Nullable )target;

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSTimer
@interface NSTimer (CrashProtector)

@end

//-----------------------------------------------------------------------------------------------------------------------------
//KVOProxy
@class CPKVOInfo;
@interface KVOProxy : NSObject

-(BOOL)addKVOinfo:(id _Nullable )object info:(CPKVOInfo *_Nullable)info;
-(void)removeKVOinfo:(id _Nullable )object keyPath:(NSString *_Nullable)keyPath block:(void(^_Nullable)()) block;
-(void)removeAllObserve;
@end

typedef void (^CPKVONotificationBlock)(id _Nullable observer, id _Nullable object, NSDictionary<NSKeyValueChangeKey, id> * _Nullable change);

//-----------------------------------------------------------------------------------------------------------------------------
//CPKVOInfo
@interface CPKVOInfo : NSObject

- (instancetype _Nullable )initWithKeyPath:(NSString *_Nullable)keyPath options:(NSKeyValueObservingOptions)options context:(void *_Nullable)context;

@end
