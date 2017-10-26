//
//  KVOTest.h
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/10/20.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Test)
+(void)doSw;
@end

@interface KVOTest : NSObject
@property (nonatomic,strong) NSString * kvoName;

-(BOOL)swizzlingInstance:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector;
-(void)doAddObserver;
-(void)doSwizzling;
@end


@interface KVODelegate : NSObject

-(void)setSelf:(NSObject*) weak;

@end

@interface KVOObj : NSObject

@property (nonatomic,strong) NSString * kvoNames;

@end


