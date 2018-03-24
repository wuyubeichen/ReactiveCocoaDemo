//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//

#import "TestViewController.h"
#import "FirstViewController.h"
#import "AccountManager.h"
@interface TestViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtField;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UILabel *signInFailureLabel;

@property (nonatomic, assign) BOOL passwordIsValid;
@property (nonatomic, assign) BOOL usernameIsValid;

@end

@implementation TestViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"RACDemo01";
    
    //初始化各控件状态
    self.signInFailureLabel.hidden = YES;
    [self updateUIState];

    //监听输入视图状态
    [self.userNameTxtField addTarget:self action:@selector(onChangeForUserNameTextFile) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTxtField addTarget:self action:@selector(onChangeForPasswordTextField) forControlEvents:UIControlEventEditingChanged];
 }



#pragma mark - Respond To Events
//点击登录按钮
- (IBAction)signInBtnClick:(id)sender {
    //点击按钮后：隐藏键盘、登录按钮响应关闭、隐藏错误视图
    [self.view endEditing:YES];
    self.signInBtn.enabled = NO;
    self.signInFailureLabel.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    [AccountManager signInWithUsername:self.userNameTxtField.text password:self.passwordTxtField.text complete:^(BOOL success) {
        //请求结束：开启登录按钮响应、重置错误视图
        self.signInBtn.enabled = YES;
        self.signInFailureLabel.hidden = success;
        if (success) {
            //登录成功后，跳转下一界面
            FirstViewController *firstVC = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
            [weakSelf.navigationController pushViewController:firstVC animated:YES];
        }
    }];
}


//点击隐藏键盘
- (IBAction)onSingleTapAction:(id)sender {
    [self.view endEditing:YES];
}


- (void)onChangeForUserNameTextFile{
    self.usernameIsValid = [self isValidForUserName:self.userNameTxtField.text];
    [self updateUIState];
}

- (void)onChangeForPasswordTextField{
    self.passwordIsValid = [self isValidForPassword:self.passwordTxtField.text];
    [self updateUIState];
}


#pragma mark - private Methods
//输入框字符串检测方法
- (BOOL)isValidForUserName:(NSString *)userName{
    return userName.length > 6;
}

- (BOOL)isValidForPassword:(NSString *)password{
    return password.length > 6;
}

- (void)updateUIState{
    self.userNameTxtField.backgroundColor = self.usernameIsValid ? [UIColor whiteColor] :[UIColor yellowColor];
    self.passwordTxtField.backgroundColor = self.passwordIsValid ? [UIColor whiteColor] : [UIColor yellowColor];
    
    self.signInBtn.enabled = self.usernameIsValid && self.passwordIsValid;
    self.signInBtn.backgroundColor = self.signInBtn.enabled ? [UIColor orangeColor]: [UIColor lightGrayColor];
}


@end
