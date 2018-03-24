//
//  AccountManager.m
//  ZSTest
//
//  Created by Bjmsp on 2018/3/20.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import "AccountManager.h"
const float delayInSeconds = 1.0f;

@implementation AccountManager

+ (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
                  complete:(SignInResponse)completeBlock
{
    //作一个延时操作, 模仿网络验证
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //判断账号密码是否有误
        BOOL success = [username isEqualToString:@"username"] && [password isEqualToString:@"password"];
        //调用block
        completeBlock(success);
    });
}



@end
