# QYCrashProtector
iOS crash protect

如何使用？

1.导入 NSObject+CrashProtector.h NSObject+CrashProtector.m  ；

2.NSObject+CrashProtector.h 文件里面 #define CP_OPEN  YES 为开启保护， NO为关闭保护 ；

3.建议测试期间 CP_OPEN 设为NO，这样能暴露问题 解决问题，待上线时候设为YES，减少APP的崩溃率 ；

4.log部分楼主还在抽时间完善，公司大大小小会议有点多，写代码时间很少，抱歉。

作用？

1. unrecognized selector crash

2. NSTimer crash

3. Container crash（数组越界，插nil等）

4. NSString crash （字符串操作的crash）

5. NSNotification crash

6. KVO crash（譬如某一属性的多次侦听，或是忘记removeObserver 或是多次removeObserver导致的crash）


了解更多？

因为公司产品比较多，用了一些bug统计，发现某些产品闪退率还不低，为了降低闪退率，于是有了这个crash保护小样。在写的过程也搜索了一下同类的案例，发现一个写得特别好的，且比较全面的产品，即网易开发的 大白（Baymax），也做了比较详细的介绍：http://mp.weixin.qq.com/s/GFt7uqrKw7m3R3KrV43zIQ 。美中不足的是，他们没有开源。楼主实现的功能，该文档都有讲到，思路也基本一致，大家可以学习使用。我也将抽更多时间完善它。


