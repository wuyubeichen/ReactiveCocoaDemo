//
//  VideoViewModel.h
//  ZSTest
//
//  Created by Bjmsp on 2018/3/24.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>



//RACCommand操作：
//获取视频列表
@property (nonatomic, strong, readonly) RACCommand *requestVideoListCommand;

@end
