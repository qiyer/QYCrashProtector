//
//  NSObject+CrashProtector.h
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashProxy : NSObject

@property (nonatomic,copy) NSString *crashMsg;

- (void)getCrashMsg;

@end

// NSObject
@interface NSObject (CrashProtector)

+ (BOOL)swizzingInstanceMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector;
+ (BOOL)swizzingClassMethod:(SEL)originSelector replaceMethod:(SEL)replaceSelector;

@end

// NSDictionary
@interface NSDictionary (CrashProtector)

@end

// NSMutableDictionary
@interface NSMutableDictionary (CrashProtector)

@end

// NSArray
@interface NSArray (CrashProtector)

@end

// NSMutableArray
@interface NSMutableArray (CrashProtector)

@end
