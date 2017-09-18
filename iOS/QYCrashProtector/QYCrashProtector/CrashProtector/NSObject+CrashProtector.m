//
//  NSObject+CrashProtector.m
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import "NSObject+CrashProtector.h"
#import <objc/runtime.h>

@implementation CrashProxy

- (void)getCrashMsg{
    NSLog(@"%@",_crashMsg);
}

@end

@implementation NSObject (CrashProtector)


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
    IMP a = class_getMethodImplementation([CrashProxy class], @selector(getCrashMsg));
    IMP b = class_getMethodImplementation([CrashProxy class], aSelector);
    Method ma = class_getInstanceMethod([CrashProxy class], @selector(getCrashMsg));
    Method mb = class_getInstanceMethod([CrashProxy class], aSelector);
    
    return crashProxy;
}
#pragma clang diagnostic pop

@end
