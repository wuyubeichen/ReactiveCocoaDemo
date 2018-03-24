//
//  FirstViewController.m
//  ZSTest
//
//  Created by zhoushuai on 16/8/10.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtField;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    //自定义导航栏左侧按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backLastVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftItem;

}


- (void)backLastVC{
    [self.navigationController popViewControllerAnimated:YES];
}


//SecondVC中点击按钮发起通知
- (IBAction)completeBtnClick:(id)sender {
//    if(self.racSubject){
//        [self.racSubject sendNext:@{@"text":self.txtField.text}];
//    }
   // [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondVCNotificaitonName" object:@{@"text":self.txtField.text}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
