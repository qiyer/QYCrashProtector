//
//  CPManager.h
//  QYCrashProtector
//
//  Created by Zhi Zhuang on 2017/9/4.
//  Copyright © 2017年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CrashProtectorStyle) {
    CrashProtectorNone = 0,
    CrashProtectorAll ,
    CrashProtectorUnrecognizedSelector,
    CrashProtectorKVO ,
    CrashProtectorNotification ,
    CrashProtectorTimer ,
    CrashProtectorContainer ,
    CrashProtectorString ,
};

@interface CPConfiguration : NSObject

@property(nonatomic,assign) Boolean             openLog;
@property(nonatomic,assign) Boolean             isDebug;
@property(nonatomic,assign) CrashProtectorStyle style;

-(instancetype)initDefault;

@end


@interface CPManager : NSObject

+(instancetype)instance;

-(void)initWithConfig:(CPConfiguration *) config;

-(void)start;
-(void)stop;

-(void)setLog:(Boolean) isOpen;

@end
