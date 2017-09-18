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

//....
@interface NSObject (CrashProtector)

@end

