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
    self.view.backgroundColor = [UIColor orangeColor];
}


//SecondVC中点击按钮发起通知
- (IBAction)completeBtnClick:(id)sender {
    if(self.racSubject){
        [self.racSubject sendNext:@{@"text":self.txtField.text}];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
