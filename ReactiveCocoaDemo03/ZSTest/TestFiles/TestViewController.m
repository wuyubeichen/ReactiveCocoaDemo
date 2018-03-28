//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "SecondViewController.h"
#import "AccountManager.h"
@interface TestViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtField;

@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (nonatomic, copy) NSString *currentText;

@property (nonatomic, strong) RACSignal *timerSignal;
@property (nonatomic, strong) RACSubject *subjectSignal;

@property (nonatomic, strong) RACCommand *command;

@end

@implementation TestViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"RACDemo03";
    
    //======第一部分:理解信号
    //测试自定义信号,理解信号机制
    //[self createMySignal];
    
    

    //======第二部分:了解RAC常用类
    //1.RACSubject
    //[self studyRAC1];
    
    //2.RACTuple、RACSequence、
    //[self studyRAC2];
    
    //3.RACCommand的使用
    //[self studyRAC3];
    
    //4.RACMulticastConnection
    //[self studyRAC4];
    

    
    //======第三部分:关于信号的常用方法
    //1.信号映射：map 、flattenMap、
    //[self signalTest1];
    
    //2.信号过滤：filter、ignore、distinctUntilchanged
    //[self signalTest2];
    
    //3.信号合并： combineLatest、reduce、merge、zipWith
    //[self signalTest3];
    
    //4.信号连接：concat、then
    //[self signalTest4];
    
    //5.信号操作时间：timeout、interval、dely
    //[self signalTest5];
    
    //6.信号取值：take、takeLast、takeUntil
    //[self signalTest6];
    
    //7.信号跳过：skip
    //[self signalTest7];

    //8.发送信号前与发送信号后的操作：doNext、Docompleted
    //[self signalTest8];
    
    //9.获取信号中的信号：switchToLatest
    //[self signalTest9];
    
    //10.信号错误重试:retry
    //[self signalTest10];
    
    //11.信号节流：throttle
    [self signalTest11];
    
    //12.信号关于线程的操作：deliverON、subscribeOn
    //[self signalTest12];
    
    //13.信号的重复订阅replay、ReplayLast、ReplayLazily
    //[self signalTest13];

 }




#pragma mark - Respond To Events
//当前视图控制器跳转按钮的响应方法中，创建secondVC，并为其添加信号属性和订阅信号。
- (IBAction)testBtnClick:(id)sender {
    //创建将要跳转的视图控制器firstVC
    SecondViewController *secondVC = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    //为secondVC设置RACSubject属性，并订阅信号
    secondVC.racSubject = [RACSubject subject];
    __weak typeof(self) weakSelf = self;
    //定阅信号的block会更新文字的显示
    [secondVC.racSubject subscribeNext:^(id  _Nullable x) {
        NSDictionary *infoDic =(NSDictionary *)x;
        weakSelf.testLabel.text =  infoDic[@"text"];
    }];
    //跳转secondVC
    [self.navigationController pushViewController:secondVC animated:YES];
}




#pragma mark - private Methods
#pragma mark 理解RAC信号机制
- (void)createMySignal{
    //===================测试自定义信号===================
    //分析信号机制
     RACSignal *testSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
         //订阅者发送信号内容。每当订阅者订阅信号，会执行此Block
         [subscriber sendNext:@"发送信号内容"];
         //[subscriber sendError:nil];
         //订阅者发送信号完成的信息。不再发送数据时，最好发送信号完成，可以内部调起清理信号的操作。
         [subscriber sendCompleted];
         //创建信号的这个Block参数，需要返回一个RACDisposable对象
         RACDisposable *racDisposable = [RACDisposable disposableWithBlock:^{
             //RACDisposable对象用于取消订阅信号，此block在信号完成或者错误时调用。
             NSLog(@"信号Error或者Complete时销毁");
         }];
         return racDisposable;
     }];
     
     //订阅信号
     [testSignal subscribeNext:^(id  _Nullable x) {
         //新变化的值
         NSLog(@"订阅信号：subscribeNext:%@",x);
     } error:^(NSError * _Nullable error) {
         //信号错误，被取消订阅,被移除观察
         NSLog(@"订阅信号：Error:%@",error.description);
     } completed:^{
         //信号已经完成，被取消订阅，被移除观察
         NSLog(@"订阅信号：subscribeComplete");
     }];
}


#pragma mark 学习RAC信号中常用类或属性
- (void)studyRAC1{
//RACSubject是信号RACSignal的一个子类，但它的底部实现与RACSignal有所不同。其订阅信号subscribeNext的方法只是使用nextBlock创建了一个订阅者并保存起来待用，多次调用subscribeNext会保存多个订阅者。只有发送信号sendNext方法执行时，订阅者才会执行nextBlock里的内容，多个订阅者会执行多次。
    //1.使用示例：
    //创建信号：创建RACSubject不需要block参数
    RACSubject *subject = [RACSubject subject];
    
    //订阅信号：那么每当信号有新值发出的时候，每个订阅者都会执行。
    //这里信号被订阅两次，那么订阅者也创建了两次，保存在RACSubject的subscribers属性数组中。
    [subject subscribeNext:^(id x) {
        //block在信号发出新值时调用
        NSLog(@"第一个订阅者:%@",x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者:%@",x);
    }];
    
    //发送信号
    [subject sendNext:@"6"];
    
    
    
    //2.应用实例：代替按钮等控制视图的响应事件
    //我们测试这样一个功能：在当前视图控制器A中点击按钮调转到下一视图控制器B，在B的文本框中输入内容，点击编辑完成按钮回到A，显示B中输入的内容到A的UILabel上。通常我们使用代理来解决这样的问题，那么现在我们可以利用RACSubject的特性来代替常用的代理的功能，其实就跟我们使用block回调一样。
    //此部分的代码请查看testBtn的响应方法
}

- (void)studyRAC2{
    //RACTuple：类似OC的数组，是RAC中用来封装值的元组类，可以配合RACTupleUnpack解元组。
    //RACSequeue：数组和字典经过rac_sequence方法会被转化为RACSequeue类型，并进一步转为我们常用的信号。订阅此类信号的时候，信号就会被激活并遍历其中的所有值。
   
    //1.遍历数组
    NSArray *characters = @[@"A",@"C",@"B",@"E",@"D"];
    [characters.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"char:%@",x);
    }];
    //打印结果：
    //char:A
    //char:C
    //char:B
    //char:E
    //char:D
    
    //2.遍历字典
    NSDictionary *myInfoDic = @{@"name":@"zs",@"nickname":@"FengZi",@"age":@"18"};\
    [myInfoDic.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        //解元组，注意一一对应
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"myInfoDic:%@-%@",key,value);
    }];
    //打印结果：
    //myInfoDic:name-zs
    //myInfoDic:nickname-FengZi
    //myInfoDic:age-18
}

- (void)studyRAC3{
    //RACCommand：用于处理事件的类
    //RACCommand可以把事件如何处理，如何传递都封装到类中。之后就可以方便的调起它的执行方法。
    
    //1.创建RACCommand：initWithSignalBlock
    //创建方法中block返回一个信号，且不能为nil，但是可以使用[RACSignal empty]表示空信号
    //RACCommand必须被强引用，否则容易被释放
    self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        //我们常在这里创建一个网络请求的信号，也就是封装一个请求数据的操作。
        RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"网络请求的信号"];
            //数据传递完成，必须调用sendComplleted.,否则永远处于执行中。
            [subscriber sendCompleted];
            return nil;
        }];
        return signal;
    }];
    
    //2.订阅RACCommand中的信号，要等到RACCommand执行后，才能收到消息
    [self.command.executionSignals subscribeNext:^(id  _Nullable x) {
        //这里是一个信号中信号
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"收到信号：%@",x);
        }];
    }];
    //改进订阅方法：switchToLatest可以直接获取信号中信号
    [self.command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"改进-收到信号：%@",x);
    }];
    
    //3.监听RACCommand命令是否执行完毕的信号
    //默认会监测一次，所以可以使用skip表示跳过第一次信号。
    //这里可以用于App网络请求时，控制加载提示视图的隐藏或者显示
    [[self.command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if([x boolValue] == YES){
            NSLog(@"RACCommand命令正在执行...");
        }else{
            NSLog(@"RACCommand命令不在执行中！！！");
        }
    }];

    //4.执行RACComand
    //方法：- (RACSignal *)execute:(id)input
    [self.command execute:@""];
}

- (void)studyRAC4{
    //RACMulticastConnection
    //用于一个信号被多次订阅的情况下，创建信号中的block被重复调用的问题
    //RACMulticastConnection可以解决网络重复请求的问题
    //测试1:普通的信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送信号A");
        [subscriber sendNext:@"发送信号A"];
        return nil;
    }];
    [signalA subscribeNext:^(id  _Nullable x) {
        NSLog(@"第一次订阅：%@",x);
    }];
    [signalA subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二次订阅：%@",x);
    }];
    
    
    
    //测试2：使用RACMulticastConnection
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送信号B");
        [subscriber sendNext:@"发送信号B"];
        return nil;
    }];
    
    //连接信号：publish或者muticast方法
    //连接后的信号使用订阅方法时，并不能激活信号，而是将其订阅者保存到数组中。
    //在连接对象执行connect方法时，信号中的订阅者会统一调用sendNext方法。
    RACMulticastConnection *signalBconnect = [signalB publish];
    
    //订阅信号
    //使用signalBconnect而不再是signalB
    [signalBconnect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第一次订阅：%@",x);
    }];
    [signalBconnect.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二次订阅：%@",x);
    }];
    //连接后激活信号
    [signalBconnect connect];
}



#pragma mark 关于RAC信号的常用方法
- (void)signalTest1{
    //===================一、信号映射===================
    //信号映射：map 、flattenMap
    //map:将信号内容修改为另一种新值。改变了传递的值
    //flattenMap:将源信号映射修改为另一种新的信号。修改了信号本身
    
    //测试map:将信号文本值修改为文本长度
    //block中return的是你希望接收到的值
    [[self.txtField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length);//必须返回一个对象
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"打印x:%@",x);
    }];
    
    //测试flattenMap：
    //block中return的是你想要的信号
    //创建一个普通信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送信号：1"];
        [subscriber sendCompleted];
        return nil;
    }];
    //创建一个发送信号的信号，信号的信号
    RACSignal *signalOfSignals = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:signal];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [signalOfSignals subscribeNext:^(id  _Nullable x) {
        //不使用flattenMap打印出内部信号
        NSLog(@"订阅signalOfSignals：%@",x);
    }];
    
    [[signalOfSignals flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        //使用flattenMap打印内部信号的值
        NSLog(@"使用flattenMap后订阅signalOfSignals：%@",x);
    }];
    
    //特别说明：信号中信号常出现在我们封装一个网络请求为信号的时候，这时候注意flattenMap的使用
}





- (void)signalTest2{
    //===================二、信号过滤===================
    //信号过滤：filter、ignore、distinctUntilChanged
    //1.filter：过滤信号，符合条件的信号能发出消息
    //filter：输入1234，当输入到4(文本长度大于3)的时候才开始打印如下的信息
    [[self.txtField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 3;
    }] subscribeNext:^(NSString * _Nullable x) {
        //2018-03-23 11:39:23.371432+0800 ZSTest[1428:68939] 打印x：1234
        NSLog(@"打印x：%@",x);
    }];
    
    //2.ignore:忽略信号，针对信号值的某一种状态进行忽略，忽略时不会发送消息。
    //ignore：可以监听每次的输入，但是当文本框内的内容是"a"时不会打印
    [[self.txtField.rac_textSignal ignore:@"a"] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"ignore测试打印：%@",x);
    }];
    
    //3.distinctUntilChanged:当上次的值与当前值有变化时才会发出消息，否则信息被忽略
    //为了方便测试，我们监测控制器的currentText属性来修改Label的文本值。
    __weak typeof(self)weakSelf = self;
    [[RACObserve(self, currentText) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"使用%@更新testLabel的值",x);
        weakSelf.testLabel.text = x;
    }];
    //currentTxt未被赋初值，所以第一次打印null,我们自己修改的两次值，只打印两次
    self.currentText = @"hello";
    self.currentText = @"world";
    self.currentText = @"world";
}




- (void)signalTest3{
    //===================三、信号合并===================
    //信号合并：combineLatest、reduce、merge、zipWith
   
    //首先创建两个RACSubject类型的信号用于测试，此类信号只有发送信号sendNext方法执行时，订阅者才会执行nextBlock里的内容;
    RACSubject *signalOne = [RACSubject subject];
    [signalOne subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号one：%@",x);
    }];
    RACSubject *signalTwo = [RACSubject subject];
    [signalTwo subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号Two：%@",x);
    }];
    
    
    //1.combineLatest：合并信号
    //合并信号的效果就是，这多个信号都至少有过一次订阅信号sendNext的操作，才会触发合并的信号。
    //下面的测试如果只有signalOne执行sendNext方法，那么combineLatest后的信号不会被触发。
    /*
    [[RACSignal combineLatest:@[signalOne,signalTwo]] subscribeNext:^(RACTuple * _Nullable x) {
        //解元组：合并信号得到的是一个元组,里面存放的是两个信号发送的消息
        RACTupleUnpack(NSString *str1,NSString *str2) = x;
        NSLog(@"combineLatest:str1-%@,str2-%@",str1,str2);
    }];
    [signalOne sendNext:@"1"];
    [signalTwo sendNext:@"2"];
    */
    
    
    
    //2.reduce：聚合信号
    //combineLatest合并后的信号订阅后，得到的是一个元组(包含每个被合并信号的新值)。然而在开发中，我们往往需要检测多个信号合并后的效果(比如用户名和密码信号有效时，登录按钮才可以点击)，这里就用到了reduce来实现信号聚合。
    //reduce聚合操作中的block参数个数随合并信号的数量而定，有多少个信号被合并，blcok中的参数就有多少个。这些参数一一对应被合并的信号，是它们对应的新值。
    /*
    [[RACSignal combineLatest:@[signalOne,signalTwo] reduce:^id(NSString *strOne,NSString *strTwo){
        return [NSString stringWithFormat:@"%@-%@",strOne,strTwo];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"combineLatest-reduce：%@",x);
    }];
    
    [signalOne sendNext:@"1"];
    [signalTwo sendNext:@"2"];
    */
    
    
    //3.merge：合并信号
    //当合并后的信号被订阅时，就会订阅里面所有的信号
    //第一种测试：将多个信号合并之后，当其中任何一个信号发送消息时，都能被监测到
    /*
    RACSignal *mergeSignal = [signalOne merge:signalTwo];
    [mergeSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"mergeSignal：%@",x);
    }];
    
    //只调用其中一个信号,就会触发merge合并的信号
    [signalOne sendNext:@"测试信号1"];
    //[signalTwo sendNext:@"测试信号2"];
    */
    
    //第二种测试:当合并后的信号被订阅时，就会订阅里面所有的信号
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"signal1"];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"signal2"];
        return nil;
    }];
    RACSignal *mergeSignals = [signal1 merge:signal2];
    [mergeSignals subscribeNext:^(id x) {
        NSLog(@"mergeSignals：%@",x);
    }];
    
    
    //4.zipWith:压缩信号
    //把两个信号压缩成为一个信号。
    //只有当两个信号同时发出信号时，两个信号的内容才会被合并为一个元组，触发压缩流的next事件。
    //比如：当一个界面多个请求的时候，要等所有请求完成才更新UI。
    //元组内元素顺序不变只与压缩信号的顺序有关，与发送信号的顺序无关。
    /*
    RACSignal *zipSignal = [signalOne zipWith:signalTwo];
    [zipSignal subscribeNext:^(id  _Nullable x) {
        //解元组：合并信号得到的是一个元组,里面存放的是两个信号发送的消息
        RACTupleUnpack(NSString *str1,NSString *str2) = x;
        NSLog(@"zipSignal：str1-%@,str2-%@",str1,str2);
    }];
    
    [signalOne sendNext:@"测试zipSignalMsgOne"];
    [signalTwo sendNext:@"测试zipSignalMsgTwo"];
    */
}



- (void)signalTest4{
    //===================四、信号拼接===================
    //信号拼接：concat、then
    //1.concat
    //使用concat可以按序拼接多个信号，拼接后的信号按序执行。
    //使用concat连接信号后，每个信号无需再单独订阅，其内部会按序自动订阅
    //前面的信号必须执行sendCompleted，后面的信号才会被激活
    RACSignal *signalOne = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signalOne"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalTwo = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signalTwo"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalThree = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signalThree"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *concatSignal = [[signalOne concat:signalThree] concat:signalTwo];
    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号被激活:%@",x);
    }];
    
    
    
    //2.then:连接信号
    //使用then连接信号，上一个信号完成后，才会连接then返回的信号
    //then连接的上一个信号必须使用sendCompleted，否则后续信号无法执行
    //then连接的多个信号，之前的信号会被忽略掉，即订阅信号只会接收到最后一个信号的值
    
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"信号1");
        [subscriber sendNext:@"发送信号1"];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"信号2");
            [subscriber sendNext:@"发送信号2"];
            [subscriber sendCompleted];
            return nil;
        }];
    }]then:^RACSignal * _Nonnull{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"信号3");
            [subscriber sendNext:@"发送信号3"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        //只能接收到最后一个信号的值
        NSLog(@"订阅信号：%@",x);
    }];
}


- (void)signalTest5{
    //===================五、信号操作时间===================
    //信号操作时间：timeout、interval、dely
    //1.interval：设置定时器操作
    //创建定时器信号，每隔一秒发送一次信号
    RACSignal *intervalSignal = [RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]];
   
    //只知道使用take结束定时器这一种方法，不知道还有没有其他方法
    [[intervalSignal take:5]subscribeNext:^(id  _Nullable x) {
         //订阅定时器信号，启动定时器，只打印5次
        NSLog(@"interval,定时器打印");
    }];
    
    
    //2.timeout：可以设置超时操作，让一个信号在规定时间之后自动报错
    //创建信号时不能使用sendCompleted，因为这样的话一旦发送了消息就取消订阅了
    RACSignal *timeOutSignal = [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"timeOutSignal发送信号"];
        //[subscriber sendCompleted];
        return nil;
    }] timeout:5 onScheduler:[RACScheduler currentScheduler]];
    
    [timeOutSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"timeOutSignal:%@",x);
    } error:^(NSError * _Nullable error) {
        //5秒后执行打印：
        //timeOutSignal:出现Error-Error Domain=RACSignalErrorDomain Code=1 "(null)"
        NSLog(@"timeOutSignal:出现Error-%@",error);
    } completed:^{
        NSLog(@"timeOutSignal:complete");
    }];
    
    //3.delay：延迟发送sendNext
    RACSignal *delaySignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"delaySignal-sendNext"];
        return nil;
    }];
    //10秒后才收到消息，执行打印
    [[delaySignal delay:10] subscribeNext:^(id  _Nullable x) {
        NSLog(@"delaySignal:%@",x);
    }];
    
    
    

}
- (void)signalTest6{
    //===================六、信号取值===================
    ///6.信号取值：take、takeLast、takeUntil
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送消息1"];
        [subscriber sendNext:@"发送消息2"];
        [subscriber sendNext:@"发送消息3"];
        [subscriber sendNext:@"发送消息4"];
        [subscriber sendCompleted];
        return nil;
    }];
    //1.take：从开始共取N次的next值
    [[signal take:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号:%@",x);
    }];
    
    //2。takeLast：从最后共取值N次next的值
    [[signal takeLast:3]subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号：%@",x);
    }];
    
    
    //3.takeUntil:(RACSignal *):获取信号直到某个信号执行完成
    RACSubject *signalA = [RACSubject subject];
    [signalA subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号A：%@",x);
    }];
    
    __weak typeof(self)weakSelf = self;
    //[RACObserve(self, currentText)发送消息知道signalA信号结束
    [[RACObserve(self, currentText) takeUntil:signalA] subscribeNext:^(id  _Nullable x) {
        NSLog(@"使用%@更新testLabel的值",x);
        weakSelf.testLabel.text = x;
    }];
    self.currentText = @"0";
    self.currentText = @"1";
    self.currentText = @"2";
    [signalA sendCompleted];//信号A结束之后，监听testLabel文本的信号也不在发送消息了
    self.currentText = @"3";
    NSLog(@"代码执行到此行。。。。");
    
}
- (void)signalTest7{
    //===================七、信号跳过===================
    //信号变化：skip
    //使用skip跳过几个信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"第一次发送消息"];
        [subscriber sendNext:@"第二次发送消息"];
        [subscriber sendNext:@"第三次发送消息"];
        [subscriber sendNext:@"第四次发送消息"];
        return nil;
    }];
    [[signal skip:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}




- (void)signalTest8{
    //===================八、发送信号前与发送信号后的操作===================
    //发送信号前与发送信号后操作：doNext、doCompleted
    //doNext：在订阅者发送消息sendNext之前执行
    //doCompleted：在订阅者发送完成sendCompleted之后执行
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送信号：1"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[[signal doNext:^(id  _Nullable x) {
        NSLog(@"执行doNext");
    }] doCompleted:^{
        NSLog(@"执行doComplete");
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号：%@",x);
    }];
}


- (void)signalTest9{
    //================九、获取信号中的信号===================
    //获取信号中的信号：switchToLatest
    //switchToLatest只能用于信号中的信号(否则崩溃)，获取最新发送的信号
    //创建一个普通信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送信号：1"];
        [subscriber sendCompleted];
        return nil;
    }];
    //创建一个发送信号的信号，信号的信号
    RACSignal *signalOfSignals = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:signal];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //订阅最近发出的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        //控制台打印：switchToLatest打印：发送信号：1
        NSLog(@"switchToLatest打印：%@",x);
    }];
    
    //特别说明：
    //可以看出switchToLatest和flattenMap的功能很相似，但是它们有一主要区别：
    //http://www.360doc.com/content/15/0926/01/15193102_501571759.shtml
}


- (void)signalTest10{
    //======十、信号错误重试==============
    //retry:信号错误重试
    //只要发送消息失败，就重新执行创建信号时的block,直至成功
    static int signalANum = 0;
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        if (signalANum == 5) {
            [subscriber sendNext:@"signalANum is 5"];
            [subscriber sendCompleted];
        }else{
            NSLog(@"signalANum错误！！!");
            [subscriber sendError:nil];
        }
        signalANum++;
        return nil;
    }];
    [[signalA retry] subscribeNext:^(id  _Nullable x) {
        NSLog(@"StringA-Next：%@",x);
    } error:^(NSError * _Nullable error) {
        //特别注意：这里并没有打印
        NSLog(@"signalA-Errror");
    }] ;
}


- (void)signalTest11{
    //===================十一、信号节流===================
    //throttle:信号节流
    //当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。
    //测试1：失败，原因未知
    /*
    self.subjectSignal = [RACSubject subject];
    
    static int timeCount = 0;
    self.timerSignal = [RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]];
    [self.timerSignal subscribeNext:^(id  _Nullable x) {
        timeCount++;
        [self.subjectSignal sendNext:@(timeCount)];
    }];
    
    [[self.subjectSignal throttle:5] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subjectSignal-Next:%@",x);
    }];
    */
    

    //测试2：
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"发送消息11"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"发送消息21"];
            [subscriber sendNext:@"发送消息22"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"发送消息31"];
            [subscriber sendNext:@"发送消息32"];
            [subscriber sendNext:@"发送消息32"];
            [subscriber sendNext:@"发送消息33"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"发送消息41"];
            [subscriber sendNext:@"发送消息42"];
            [subscriber sendNext:@"发送消息43"];
            [subscriber sendNext:@"发送消息44"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"发送消息51"];
            [subscriber sendNext:@"发送消息52"];
            [subscriber sendNext:@"发送消息53"];
            [subscriber sendNext:@"发送消息54"];
            [subscriber sendNext:@"发送消息55"];
        });

        return nil;
    }] throttle:3] subscribeNext:^(id  _Nullable x) {
        NSLog(@"Next:%@",x);
    }];

}


- (void)signalTest12{
    //===========十二、信号关于线程的操作：deliverON、subscribeOn=============
    //副作用:关于信号与线程,我们把在创建信号时block中的代码称之为副作用。
    //1.deliverON：切换到指定线程中，可用于回到主线中刷新UI,内容传递切换到指定线程中，
    //2.subscribeOn：内容传递和副作用都会切换到指定线程中。
    //3.deliverOnMainThread：能保证原信号subscribeNext，sendError，sendCompleted都在主线程MainThread中执行。
    
    //测试1：系统并行队列中异步执行,未使用deliverON切换线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"测试1-endNext"];
            NSLog(@"测试1-sendNext当前线程：%@",[NSThread currentThread]);
            return nil;
        }] subscribeNext:^(id  _Nullable x) {
            NSLog(@"测试1-Next:%@",x);
            NSLog(@"测试1-Next当前线程：%@",[NSThread currentThread]);
        }];
    }) ;
    
    //测试2：系统并行队列中异步执行,使用deliverON切换线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"测试2-sendNext"];
            NSLog(@"测试2-sendNext当前线程：%@",[NSThread currentThread]);
            return nil;
        }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id  _Nullable x) {
            NSLog(@"测试2-Next:%@",x);
            NSLog(@"测试2-Next当前线程：%@",[NSThread currentThread]);
        }];
    }) ;
    
    //测试3：系统并行队列中异步执行,使用subscribeOn切换线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"测试3-sendNext"];
            NSLog(@"测试3-sendNext当前线程：%@",[NSThread currentThread]);
            return nil;
        }] subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id  _Nullable x) {
            NSLog(@"测试3-Next:%@",x);
            NSLog(@"测试3-Next当前线程：%@",[NSThread currentThread]);
        }];
    }) ;
 }

- (void)signalTest13{
    //===========十二、信号的重复订阅=============
    //待补充。。。
    //2.replay:信号重复订阅
    //当一个信号被多次订阅,反复播放内容
    //只要发送消息失败，就重新执行创建信号时的block,直至成功
    /*
     RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
     [subscriber sendNext:@"signalB-sendNext1"];
     //        [subscriber sendNext:@"signalB-sendNext2"];
     //        [subscriber sendNext:@"signalB-sendNext3"];
     //        [subscriber sendNext:@"signalB-sendNext4"];
     return nil;
     }];
     [signalB replay];
     [signalB subscribeNext:^(id  _Nullable x) {
     NSLog(@"%@",x);
     }];
     
     [signalB subscribeNext:^(id  _Nullable x) {
     NSLog(@"%@",x);
     }];
     */
}


@end
