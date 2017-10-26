//
//  Test.h
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/13.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Test : NSObject

@property(nonatomic,copy) NSString*  kvo_name;


-(void)doTimerTest;
-(void)doNotificationTest;

-(void)testKVO;
@end
