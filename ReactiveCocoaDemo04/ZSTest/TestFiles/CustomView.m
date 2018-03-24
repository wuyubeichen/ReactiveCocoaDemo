//
//  CustomView.m
//  ZSTest
//
//  Created by Bjmsp on 2018/3/21.
//  Copyright © 2018年 zhoushuai. All rights reserved.
//

#import "CustomView.h"
@interface CustomView()

@property (nonatomic,strong)UIButton *testBtn;
@end

@implementation CustomView

#pragma mark - Life Cycle
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor orangeColor];
    self.testBtn.frame = CGRectMake(15, 15, self.frame.size.width - 15*2, self.frame.size.height - 15*2);
}

- (void)dealloc{
    
}

#pragma mark - private Methods
- (void)addSubViews{
    _testBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    _testBtn.backgroundColor = [UIColor purpleColor];
    [_testBtn addTarget:self action:@selector(testBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_testBtn];
}

- (void)updateUI{
}

- (void)testBtnClick:(UIButton *)btn{
    
}

@end
