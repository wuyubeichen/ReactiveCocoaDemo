//
//  VideoViewModel.m
//  ZSTest
//
//  Created by Bjmsp on 2018/3/24.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import "VideoViewModel.h"
#import "VideoListTableViewCell.h"
@interface VideoViewModel()
//数据源
@property(nonatomic,strong)NSMutableArray *videoModels;
@property(nonatomic,strong)NSNumber *currentPage;
@end

@implementation VideoViewModel

- (id) init{
    if (self = [super init]) {
        [self setupBind];
    }
    return self;
}

#pragma mark - private Methods
- (void)setupBind{
    
    //3.RACCommand事件
    WS(weakSelf);
    //封装登录网络请求操作
    _requestVideoListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            //使用延时操作，模拟登录网络请求,并在这里发送消息
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2)*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                //发送登录请求的数据
                [subscriber sendNext:nil];
                //必须sendCompleted，否则命令永远处于执行状态
                [subscriber sendCompleted];
            });
            return nil;
        }];
    }];
    
    //监听登录操作产生的数据
    //switchToLatest获取最新发送的信号，只能用于信号中信号
    [_requestVideoListCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSDictionary *data = (NSDictionary *)x;
        if ([data[@"status"] isEqualToString:@"0"]) {
            VideoListDataModel *videoListDataModel = [VideoListDataModel yy_modelWithJSON:data[@"archive"]];
            if ([weakSelf.currentPage integerValue] == 0) {
                [weakSelf.videoModels removeAllObjects];
                [weakSelf.videoModels addObject:videoListDataModel.archive];
            }else{
                
            }
            
        }

    }];
    
    //监听登录操作的状态：正在进行或者已经结束
    //默认会监测一次，所以这里使用skip表示跳过第一次信号。
    [[_requestVideoListCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x isEqual:@(YES)]) {
            //正在执行，显示MBProgressHUD
        }else{
            //正在执行或者没有执行，隐藏MBProgressHUD
        }
    }];

    
}



#pragma mark - Delegate：UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"VideoListTableViewCellID";
     VideoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[VideoListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.videoListModel = self.videoModels[indexPath.row];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

@end
