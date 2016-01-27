//
//  ViewController.m
//  FQY_BadgeView
//
//  Created by DEVP-IOS-03 on 16/1/22.
//  Copyright © 2016年 DEVP-IOS-03. All rights reserved.
//

#import "ViewController.h"
#import "BadgeView.h"
@interface ViewController ()<BadgeViewDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor   = [UIColor whiteColor];
    CGPoint point               = CGPointMake(20, 70);
    BadgeView *badgeView        = [[BadgeView alloc]initWithSuperView:self.view position:point radius:15 andValidAttachDistance:30];
//  验证 index 和 badgeNumber 2个属性,index 的正确性
    badgeView.badgeNumber       = 30;
    NSLog(@"badgeNumber:%lu",badgeView.badgeNumber);
    badgeView.index             = 10;
    badgeView.delegate          = self;
    [self.view addSubview:badgeView];
//    添加按钮
    UIButton *btn               = [[UIButton alloc]initWithFrame:CGRectMake(20, 300, 40, 40)];
    [btn                        setTitle:@"添加" forState:UIControlStateNormal];
    btn.titleLabel.font         = [UIFont boldSystemFontOfSize:10];
    [btn                        setBackgroundColor:[UIColor blackColor]];
    [btn                        setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn                        addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view                  addSubview:btn];
    
}

-(void)badgeViewDidRemoveFromSuperViewWithIndex:(NSInteger)index
{
    NSLog(@"index:%lu",index);
}

-(void)btnClick
{
    CGPoint point = CGPointMake(20, 70);
    BadgeView *badgeView = [[BadgeView alloc]initWithSuperView:self.view position:point radius:15 andValidAttachDistance:30];
    badgeView.badgeNumber       = 40;
    NSLog(@"badgeNumber:%lu",badgeView.badgeNumber);
    badgeView.index             = 11;
    badgeView.delegate          = self;
    [self.view addSubview:badgeView];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
