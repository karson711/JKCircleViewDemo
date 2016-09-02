//
//  ViewController.m
//  JKCircleViewDemo
//
//  Created by kunge on 16/9/2.
//  Copyright © 2016年 kunge. All rights reserved.
//

#import "ViewController.h"
#import "JKCircleView.h"
//#import <math.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-star"]];
    CGFloat width = self.view.frame.size.width;
    
    NSArray *imageArr = @[@"9-icon-sem4",@"9-icon-wind4",@"9-icon-sg4",@"9-icon-wet4"];
    NSArray *tipArr = @[@"℃",@"m³/h",@"%",@"%"];
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width*(i%2)/2, i >= 2?width/2+180:180, width/2, width/2)];
        [self.view addSubview:view];
        
        //视图显示大小固定130
        JKCircleView *dialView = [[JKCircleView alloc] initWithFrame:CGRectMake(width/4-75, width/4-75, 130, 130)];
        //取值范围：最大值、最小值
        if (i == 0) {
            dialView.minNum = 17;
            dialView.maxNum = 40;
        }else{
            dialView.minNum = 0;
            if (i == 1) {
                dialView.maxNum = 1000;
            }else{
                dialView.maxNum = 100;
            }
        }
        dialView.flag = i+100;
        dialView.tag = i+100;
        dialView.units = tipArr[i];//单位名称
        dialView.iconName = imageArr[i];//中间图标
        dialView.progress = 0.0;
        dialView.enableCustom = NO;//是否采用自定义滑动模式
        [dialView setProgressChange:^(NSString *result, int flag) {
            //flag=tag,根据flag标识视图
            NSLog(@"第%d个视图,结果result====%@",flag-99,result);
        }];
        
        [view addSubview:dialView];
    }
}

- (IBAction)switchAction:(UISwitch *)sender {
    sender.selected = !sender.selected;
    for (int i = 0; i < 4; i++) {
        JKCircleView *circle = [self.view viewWithTag:100+i];
        circle.enableCustom = sender.selected;
    }
}

- (IBAction)progressChangeAction:(UISlider *)sender {
    for (int i = 0; i < 4; i++) {
        JKCircleView *circle = [self.view viewWithTag:100+i];
        circle.progress = sender.value;
    }
}



@end
