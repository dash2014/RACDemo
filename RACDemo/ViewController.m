//
//  ViewController.m
//  RACDemo
//
//  Created by dash007 on 2018/2/13.
//  Copyright © 2018年 dash007. All rights reserved.
//

#import "ViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>
#import <ReactiveObjC/RACReturnSignal.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testSignal];
//    [self testSubject];
//    [self testRelaySubject];
//    [self testDelay];
//    [self testInterval];
//    [self testTuple];
//    [self testArray];
//    [self testDictionary];
//    [self testArrayMap];
//    [self testMulticastConnection];
//    [self testCommand];
//    [self testBind];
//    [self testMap];
//    [self testConcatSignal];
//    [self testThenSignal];
//    [self testMerge];
//    [self testZipWith];
//    [self testReduce];
//    [self testIgnore];
//    [self testTake];
//    [self testDistinct];
//    [self testSkip];
//    [self testDoNext];
//    [self testTimeout];
//    [self testReply];
    [self testSignalInSignal];
}

#pragma mark - testSignal
- (void)testSignal
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1111"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号取消订阅");
        }];
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"signal1:%@", x);
    }];
}

- (void)testSubject
{
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"Subject1 : %@", x);
    }];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"Subject2 : %@", x);
    }];
    [subject sendNext:@"2222222"];
}

- (void)testRelaySubject
{
    RACReplaySubject *relaySubject = [RACReplaySubject subject];
    [relaySubject sendNext:@"33333"];
    [relaySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"RelaySubject:%@", x);
    }];
}

- (void)testDelay
{
    [[RACScheduler mainThreadScheduler] afterDelay:2.0 schedule:^{
        NSLog(@"Delay");
    }];
}

- (void)testInterval
{
    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLog(@"Interval:%@", [formatter stringFromDate:date]);
    }];
}

- (void)testTuple
{
    RACTuple *tuple = [RACTuple tupleWithObjects:@"1",@"2", nil];
    NSNumber *first = [tuple objectAtIndex:0];
    NSLog(@"tuple:%@", first);
}

- (void)testArray
{
    NSArray *array = @[@"123",@"456"];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"array:%@", x);
    }];
}

- (void)testDictionary
{
    NSDictionary *dict = @{@"name" : @"小明", @"age" : @"20"};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"Dictionary:%@--%@", key, value);
    }];
}

- (void)testArrayMap
{
    NSArray *allModels = @[@"1",@"3"];
    NSArray *models = [[allModels.rac_sequence map:^id(id value) {
        return @"3";
    }] array];
    NSLog(@"models:%@", models);
}

- (void)testMulticastConnection
{
    // 1.发送请求，用一个信号内包装，不管有多少个订阅者，只想发一次请求
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"444444444444444"];
        return nil;
    }];
    //2. 创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    //3. 连接。只有连接了才会把信号源变为热信号
    [connection connect];
}

- (void)testCommand
{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"5555555"];
            return nil;
        }];
    }];
    RACSignal *signal = [command execute:nil];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"command:%@",x);
    }];
    //TODO:信号中的信号
}

- (void)testBind
{
    RACSubject *subject = [RACSubject subject];
    RACSignal *bindSignal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal *(id value, BOOL *stop) {
            value = @"bindValue:6666666";
            return [RACReturnSignal return:value];
        };
    }];
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@"777"];
}

- (void)testMap
{
    RACSubject *subject = [RACSubject subject];
    RACSignal *bindSignal = [subject map:^id _Nullable(id  _Nullable value) {
        return @"8888";
    }];
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"99"];
}

//信号组合，有先后顺序关系
- (void)testConcatSignal
{
    RACSignal *siganlA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"AAAAAA"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *siganlB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"BBBBB"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *concatSignal = [siganlB concat:siganlA];

    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

//忽略第一个信号
- (void)testThenSignal
{
    RACSignal *siganlA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"AAAAAA"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *siganlB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"BBBBB"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *thenSiganl = [siganlA then:^RACSignal *{
        return siganlB;
    }];
    
    [thenSiganl subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

//任意一个信号过来都会执行block，没有先后顺序关系
- (void)testMerge
{
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    RACSignal *mergeSiganl = [signalA merge:signalB];
    [mergeSiganl subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}

//将所有信号压缩成一个信号，输出tuple
- (void)testZipWith
{
    RACSubject *signalC = [RACSubject subject];
    RACSubject *signalD = [RACSubject subject];
    RACSignal *zipSignal = [signalC zipWith:signalD];
    [zipSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    [signalD sendNext:@"xxxxx"];
    [signalC sendNext:@"11132"];
}

- (void)testReduce
{
    //TODO:
}

//忽略某些值
- (void)testIgnore
{
    RACSubject *subject = [RACSubject subject];
//    RACSignal *ignoreSignal = [subject ignoreValues];
    RACSignal *ignoreSignal = [subject ignore:@"13"];
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"13"];
    [subject sendNext:@"2"];
    [subject sendNext:@"44"];
}

- (void)testTake
{
    RACSubject *subject2 = [RACSubject subject];
//    [[subject2 take:2] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    
//    [[subject2 takeLast:2] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//    [subject2 takeUntil:<#(nonnull RACSignal *)#>]
    [subject2 sendNext:@"1"];
    [subject2 sendNext:@"2"];
    [subject2 sendNext:@"3"];
    [subject2 sendCompleted];
}

//重复的值不会被订阅
- (void)testDistinct
{
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"1"];
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
}

//越过某些值
- (void)testSkip
{
    RACSubject *subject4 = [RACSubject subject];
    [[subject4 skip:0] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [subject4 sendNext:@"1"];
    [subject4 sendNext:@"2"];
    [subject4 sendNext:@"3"];
}

- (void)testDoNext
{
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        NSLog(@"doNext");;
    }] doCompleted:^{
        NSLog(@"doCompleted");
        
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

- (void)testTimeout
{
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        // 1秒后会自动调用
        NSLog(@"%@",error);
    }];
    
}

- (void)testReply
{
    RACSignal *signal3 = [[RACSignal createSignal:^RACDisposable* (id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        
        return nil;
    }] replay];
    
    [signal3 subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    
    [signal3 subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
}

//信号中包含信号
- (void)testSignalInSignal
{
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 发送信号
    [signalOfSignals sendNext:signalB];
    [signalA sendNext:@1];
    [signalB sendNext:@"BB"];
    [signalA sendNext:@"11"];
}

//剩下的基本都类似button的点击事件，通知等，暂且不写了。

@end
