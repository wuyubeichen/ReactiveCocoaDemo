//
//  AccountManager.h
//  ZSTest
//
//  Created by Bjmsp on 2018/3/20.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SignInResponse)(BOOL success);

@interface AccountManager : NSObject

/**
 *  登陆的方法
 *
 *  @param username      用户名
 *  @param password      密码
 *  @param completeBlock 登陆成功后的回调
 */
+ (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
                  complete:(SignInResponse)completeBlock;

@end
