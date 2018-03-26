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
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *logInFailureLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;

@end

@implementation TestViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"RACDemo02";
    
    self.logInFailureLabel.hidden = YES;
    
    
    //第一步：创建表示用户名和密码有效的信号
    RACSignal *validUserNameSignal = [self.userNameTxtField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidForUserName:value]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTxtField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidForPassword:value]);
    }];
    //用户名和密码两个信号聚合才能决定登录按钮是否可用
    RACSignal *validLoginSignal = [RACSignal combineLatest:@[validUserNameSignal,validPasswordSignal] reduce:^id(NSNumber *userNameValid,NSNumber *passwordValid){
      
        return@([userNameValid boolValue] && [passwordValid boolValue]);
    }] ;
    
    //第二步：将信号的变化与视图的属性连接起来
    //输入框颜色变化、登录是否enable、错误提示信息的显示
     RAC(self.userNameTxtField,backgroundColor) = [validUserNameSignal map:^id _Nullable(NSNumber *userNameValid) {
        return [userNameValid boolValue] ? [UIColor whiteColor] : [UIColor yellowColor];
    }];
    
    RAC(self.passwordTxtField,backgroundColor) = [validPasswordSignal map:^id _Nullable(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor whiteColor] : [UIColor yellowColor];
    }];
    
    RAC(self.loginBtn, backgroundColor) = [validLoginSignal map:^id _Nullable(NSNumber *signupValid) {
        return [signupValid boolValue] ? [UIColor orangeColor] :[UIColor lightGrayColor];
    }];

    RAC(self.loginBtn, enabled) = validLoginSignal;


    //第三步：响应式处理手势点击、按钮登录
    __weak typeof(self) weakSelf = self;
    //处理手势
    [self.tapGesture.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        [self.view endEditing:YES];
    }];
    
    //处理登录：信号中的信号，使用flattenMap
    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^__kindof RACSignal * _Nullable(__kindof UIControl * _Nullable value) {
        //将按钮响应信号转化为登录信号
        weakSelf.logInFailureLabel.hidden = YES;
        return [self loginSignal];
    }] subscribeNext:^(id  _Nullable x) {
        weakSelf.logInFailureLabel.hidden = [x boolValue];
        if ([x boolValue] == YES) {
            //登录成功后，跳转下一界面
            FirstViewController *firstVC = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
            [weakSelf.navigationController pushViewController:firstVC animated:YES];
        }
    }];
    
 }

#pragma mark - Respond To Events
//登录操作的信号
- (RACSignal *)loginSignal{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [AccountManager signInWithUsername:self.userNameTxtField.text password:self.passwordTxtField.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}


#pragma mark - private Methods
- (BOOL)isValidForUserName:(NSString *)userName{
    return userName.length > 6;
}

- (BOOL)isValidForPassword:(NSString *)password{
    return password.length > 6;
}

@end
