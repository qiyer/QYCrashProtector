# QYCrashProtector
iOS crash protect

如何使用？

1.导入 NSObject+CrashProtector.h NSObject+CrashProtector.m  ；

2.NSObject+CrashProtector.h 文件里面 #define CP_OPEN  YES 为开启保护， NO为关闭保护 ；

3.建议测试期间 CP_OPEN 设为NO，这样能暴露问题 解决问题，待上线时候设为YES，减少APP的崩溃率 ；

作用？

1. unrecognized selector crash
2. NSTimer crash
3. Container crash（数组越界，插nil等）
4. NSString crash （字符串操作的crash）
5. NSNotification crash
6. KVO crash（譬如某一属性的多次侦听，或是忘记removeObserver 或是多次removeObserver导致的crash）


