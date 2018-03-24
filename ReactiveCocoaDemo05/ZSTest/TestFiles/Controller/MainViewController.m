//
//  FirstViewController.m
//  ZSTest
//
//  Created by zhoushuai on 16/8/10.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "MainViewController.h"
#import "VideoViewModel.h"
//这里测试登录界面后的一个界面，展示视频列表

@interface MainViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) VideoViewModel *videoViewModel;

@end

@implementation MainViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"RAC布局表视图界面";
    
    [self.view addSubview:self.tableView];
    // 添加下拉刷新头部控件
    WS(weakSelf);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //[weakSelf requestForSpecialistWihtHeaderRefresh:YES];
     }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //[weakSelf requestForSpecialistWihtHeaderRefresh:NO];
    }];
    [self.tableView.mj_header beginRefreshing];

}


#pragma mark - private Methods
- (void)resetRefreshView{
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
    }
}


#pragma mark - Getter && Setter
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain
                      ];
        self.tableView.estimatedRowHeight = 50.0f;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self.videoViewModel;
        _tableView.delegate = self.videoViewModel;
    }
    return _tableView;
}

- (VideoViewModel *)videoViewModel{
    if (!_videoViewModel) {
        _videoViewModel = [[VideoViewModel alloc] init];
    }
    return _videoViewModel;
}

@end
