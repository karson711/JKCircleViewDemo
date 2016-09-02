//
//  JKCircleView.m
//  JKCircleWidget
//
//
//  Created by kunge on 16/8/31.
//  Copyright © 2016年 kunge. All rights reserved.
//

#define   DEGREES_TO_RADIANS(degrees)  ((M_PI * degrees)/ 180)
#define CATProgressStartAngle     (-90)
#define CATProgressEndAngle       (270)

#import "JKCircleView.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

@interface JKCircleView () <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *panGesture;
}

// dial appearance
@property CGFloat dialRadius;

// background circle appeareance
@property CGFloat outerRadius;  // don't set this unless you want some squarish appearance
@property CGFloat arcRadius; // must be less than the outerRadius since view clips to bounds
@property CGFloat arcThickness;
@property CGPoint trueCenter;
@property UILabel *numberLabel;
@property UIImageView *iconImage;
@property UIImageView *startCircle;
@property int currentNum;
@property double angle;
@property UIView *circle;

@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation JKCircleView


# pragma mark view appearance setup

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        // overall view settings
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        // setting default values
        self.minNum = 0;
        self.maxNum = 100;
        self.currentNum = self.minNum;
        self.units = @"";
        self.iconName = @"";
        
        // determine true center of view for calculating angle and setting up arcs
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        self.trueCenter = CGPointMake(width/2, height/2);
        
        // radii settings
        self.dialRadius = 10;
        self.arcRadius = 80;
        self.outerRadius = MIN(width, height)/2;
        self.arcThickness = 5.0;
        
        // number label tracks progress around the circle
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(width*.1, height/2 - width/6, 85, 25)];
        self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
        self.numberLabel.center = CGPointMake(self.trueCenter.x, self.trueCenter.y+20);
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [UIFont systemFontOfSize:14];
        self.numberLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.numberLabel];
        
        self.iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(width*.1, height/2 - width/6, 40, 40)];
        self.iconImage.center = CGPointMake(self.trueCenter.x, self.trueCenter.y-15);
        self.iconImage.image = [UIImage imageNamed:self.iconName];
        [self addSubview:self.iconImage];
        
        _trackLayer=[CAShapeLayer layer];
        _trackLayer.frame=self.bounds;
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
        _trackLayer.strokeColor = [UIColor whiteColor].CGColor;
        _trackLayer.opacity = 0.25;//背景圆环的背景透明度
        _trackLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_trackLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
        UIBezierPath *path=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                          radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(CATProgressStartAngle) endAngle:DEGREES_TO_RADIANS(CATProgressEndAngle) clockwise:YES];//-210到30的path
        _trackLayer.path = path.CGPath;
        _trackLayer.lineWidth = self.arcThickness;
        
        //2.进度轨道
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [[UIColor clearColor] CGColor];
        _progressLayer.strokeColor = [UIColor colorWithRed:210/255.f green:180/255.f blue:140/255.f alpha:1.0f].CGColor;//!!!不能用clearColor
        _progressLayer.lineCap=kCALineCapRound;
        _progressLayer.strokeEnd=0.0;
        [self.layer addSublayer:_progressLayer];
        
        self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
        CGFloat start = CATProgressStartAngle;
        CGFloat end = CATProgressEndAngle;
        UIBezierPath *path1=[UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:self.arcRadius startAngle:DEGREES_TO_RADIANS(start) endAngle:DEGREES_TO_RADIANS(end) clockwise:YES];//-210到30的path
        
        _progressLayer.path = path1.CGPath;
        _progressLayer.lineWidth = self.arcThickness;
        
        CGPoint newCenter = CGPointMake(width/2, height/2);
        
        newCenter.y += self.arcRadius * sin(M_PI/180 * (0 - 90));
        newCenter.x += self.arcRadius * cos(M_PI/180 * (0 - 90));
         _startCircle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        _startCircle.center = newCenter;
        _startCircle.backgroundColor = [UIColor colorWithRed:210/255.f green:180/255.f blue:140/255.f alpha:1.0f];
        _startCircle.layer.cornerRadius = 7;
        _startCircle.layer.masksToBounds = YES;
        [self addSubview:_startCircle];
        
        self.circle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.dialRadius*2, self.dialRadius*2)];
        self.circle.userInteractionEnabled = YES;
        self.circle.layer.cornerRadius = 10;
        self.circle.backgroundColor = [UIColor whiteColor];
        self.circle.center = newCenter;
        [self addSubview: self.circle];
        
        // pan gesture detects circle dragging
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
    }
    
    return self;
}

- (void) drawRect:(CGRect)rect {

}

- (void) willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    
    self.arcRadius = MIN(self.arcRadius, self.outerRadius - self.dialRadius);
    
    // label
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
    
    self.iconImage.image = [UIImage imageNamed:self.iconName];
    
//    [self moveCircleToAngle:0];
    
}

# pragma mark move circle in response to pan gesture
- (void) moveCircleToAngle: (double)angle{
    self.angle = angle;

    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGPoint newCenter = CGPointMake(width/2, height/2);

    newCenter.y += self.arcRadius * sin(M_PI/180 * (angle - 90));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (angle - 90));
    self.circle.center = newCenter;
    self.currentNum = self.minNum + (self.maxNum - self.minNum)*(angle/360.0);
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
    self.iconImage.image = [UIImage imageNamed:self.iconName];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];

    _progressLayer.strokeEnd = angle/360;
    if (self.progressChange) {
        self.progressChange([NSString stringWithFormat:@"%d",self.currentNum],self.flag);
    }
    [CATransaction commit];
    
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [CATransaction setAnimationDuration:1];
    progress = progress < 0.0 ? 0.0 : progress;
    progress = progress > 1.0 ? 1.0 : progress;
    _progressLayer.strokeEnd=progress;
    
    CGPoint newCenter = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    newCenter.y += self.arcRadius * sin(M_PI/180 * (360*progress - 90));
    newCenter.x += self.arcRadius * cos(M_PI/180 * (360*progress - 90));
    self.circle.center = newCenter;
    
    self.currentNum = self.minNum + (self.maxNum - self.minNum)*progress;
    self.numberLabel.text = [NSString stringWithFormat:@"%d %@", self.currentNum, self.units];
    if (self.progressChange) {
        self.progressChange([NSString stringWithFormat:@"%d",self.currentNum],self.flag);
    }
    [CATransaction commit];
}

-(void)setEnableCustom:(CGFloat)enableCustom{
    _enableCustom = enableCustom;
    if (_enableCustom) {
        self.circle.userInteractionEnabled = YES;
        self.circle.hidden = NO;
        [self addGestureRecognizer:panGesture];
    }else{
        self.circle.userInteractionEnabled = NO;
        self.circle.hidden = YES;
        [self removeGestureRecognizer:panGesture];
    }
}

- (UIBezierPath *)createArcPathWithAngle:(double)angle atPoint: (CGPoint) point withRadius: (float) radius
{
    float endAngle = (float)(((int)angle + 270 + 1)%360);
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:point
                                                         radius:radius
                                                     startAngle:DEGREES_TO_RADIANS(270)
                                                       endAngle:DEGREES_TO_RADIANS(endAngle)
                                                      clockwise:YES];
    return aPath;
}

# pragma mark detect pan and determine angle of pan location vs. center of circular revolution

- (void)handlePan:(UIPanGestureRecognizer *)pv {

    CGPoint translation = [pv locationInView:self];
    CGFloat x_displace = translation.x - self.trueCenter.x;
    CGFloat y_displace = -1.0*(translation.y - self.trueCenter.y);
    double radius = pow(x_displace, 2) + pow(y_displace, 2);
    radius = pow(radius, .5);
    double angle = 180/M_PI*asin(x_displace/radius);
    
    if (x_displace > 0 && y_displace < 0){
        angle = 180 - angle;
    }
    else if (x_displace < 0){
        if(y_displace > 0){
            angle = 360.0 + angle;
        }
        else if(y_displace <= 0){
            angle = 180 + -1.0*angle;
        }
    }
    
//    NSLog(@"angle=====%lf",angle);
    [self moveCircleToAngle:angle];
}


@end
