//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "SecondViewController.h"
#import "CustomView.h"
@interface TestViewController ()

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) UIButton  *testBtn;

@property (nonatomic, strong) UITextView *testTxtView;

@end

@implementation TestViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"RACDemo06";
    
    //1.代替代理
    //[self signalTest1];
    
    //2/代替按钮等控制视图的响应事件
    //[self signalTest2];
    
    //3.代替KVO，监听对象属性变化
    //[self signalTest3];
    
    //4.监听文本输入变化
    //[self signalTest4];
    
    //5.代替通知的使用
    //[self signalTest5];
    
    //6.多请求汇总处理
    //[self signalTest6];

 }


#pragma mark - Respond To Events
//集中处理所有的请求
- (void)handleAllTasksWithT1:(id)data1 withT2:(id)data2{

    NSLog(@"下载任务全部完成：%@，%@",data1,data2);
}

#pragma mark - private Methods
- (void)signalTest1{
    //1.代替代理的使用
    _customView  = [[CustomView alloc] initWithFrame:CGRectMake(15, 100, kDeviceWidth - 15*2, 300)];
    [self.view addSubview:_customView];
    //第一步：通过rac_signalForSelector获取了视图的信号，
    //第二步：订阅信号，按钮点击时发出信号
    //经过测试，即使testBtnClick没有在自定义视图的h文件中声明，执行也是正常的。
    [[_customView  rac_signalForSelector:@selector(testBtnClick:)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"testBtn点击了。。。");
    }];
}

- (void)signalTest2{
    //2.代替按钮等控制视图的响应事件
    UIButton *testBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 100, kDeviceWidth - 15*2, 50)];
    testBtn.backgroundColor = [UIColor redColor];
    [self.view addSubview:testBtn];
    //关键方法：rac_signalForControlEvents
    __weak typeof(self) weakSelf = self;
    [[testBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"testBtn点击了。。。");
        SecondViewController *secondVC = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
        [weakSelf.navigationController pushViewController:secondVC animated:YES];
    }];
}

- (void)signalTest3{
    //3.代替KVO，监听对象属性
    //自定义视图_customView属性变化被转化信号，值发生变化的时候，会发送信号。
    //observer可以为nil,但是会报警告
    //关键方法：rac_valuesAndChangesForKeyPath
    _customView  = [[CustomView alloc] initWithFrame:CGRectMake(15, 100, kDeviceWidth - 15*2, 300)];
    [self.view addSubview:_customView];
    [[_customView rac_valuesAndChangesForKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer: @{}] subscribeNext:^(id x) {
        NSLog(@"CustomView的Frame值变化了：%@",x);
        
    }];
    _customView.frame = CGRectZero;
}

- (void)signalTest4{
    //4.代替文本框的响应方法，监听文本输入
    _testTxtView = [[UITextView alloc] initWithFrame:CGRectMake(15, 100, kDeviceWidth - 15*2, 100)];
    _testTxtView.backgroundColor  = [UIColor orangeColor];
    [self.view addSubview:_testTxtView];
    //关键方法：rac_textSignal
    [[_testTxtView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"当前文本输入内容：%@",x);
    }];
}

- (void)signalTest5{
    //5.代替通知，处理通知事件
    //关键方法：rac_addObserverForName
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"SecondVCNotificaitonName" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSDictionary *objectDic = (NSDictionary *)x.object;
        NSLog(@"获取到通知里的文本：%@",objectDic[@"text"]);
    }];
}

- (void)signalTest6{
    //6.多请求汇总处理
    //下载任务1
    RACSignal *downLoad1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@{@"data2":@"value1"}];
        [subscriber sendCompleted];
        return nil;
    }];
    //下载任务2
    RACSignal *downLoad2  = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@{@"data2":@"value2"}];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //多信号对应多参数，注意顺序与格式
    [self rac_liftSelector:@selector(handleAllTasksWithT1:withT2:) withSignals:downLoad1,downLoad2, nil];
}


@end
