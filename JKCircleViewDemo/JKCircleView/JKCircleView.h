//
//  JKCircleView.h
//  JKCircleWidget
//
//  Created by kunge on 16/8/31.
//  Copyright © 2016年 kunge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKCircleView : UIView

// set min and max range for dial
// default values are 0 to 100

@property int minNum;

@property int maxNum;

@property NSString *units;

@property(nonatomic,strong) NSString *iconName;

//进度 [0...1]
@property(nonatomic,assign) CGFloat progress;

//是否可以手动调节进度
@property (nonatomic, assign)CGFloat enableCustom;

@property int flag;

@property (nonatomic,copy) void (^progressChange)(NSString *result,int flag);



@end
