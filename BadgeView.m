//
//  BadgeView.m
//  FQY_BadgeView
//
//  Created by DEVP-IOS-03 on 16/1/22.
//  Copyright © 2016年 DEVP-IOS-03. All rights reserved.
//

#import "BadgeView.h"

@implementation BadgeView 
{
    UILabel                 *numberLabel;           //提醒数字Label
    CGFloat                  numberLabelRadius;     //提醒数字Label的半径
    UIView                  *backView;              //底试图
    UIPanGestureRecognizer  *panGesture;            //拖拽手势


    CGFloat                  validAttachDistance;   //吸附粘度
    CGFloat                  breakRadius;           //小球消失半径(吸附效果结束,然后在这个半径范围内松手,还会回到原点,一般吸附粘度是row 高度的2倍,breakRadius是row一样的高度就行了)
    CGPoint                  originPoint;           //原xy坐标点
    CGPoint                  originCenter;          //原中心点
    CGPoint                  position;              //实际的位置
    BOOL                     isBreak;               //是否已经断开
    BOOL                     isEndDrag;             //是否结束拖拽
    BOOL                     enableDrag;            //是否可以拖拽
    
}

/* 
 出现的问题,只复写set方法不会出现这样的问题, .h文件不用声明_index 和 _badgeNumber,下面是具体例子
 当你复写了get和set方法之后@property默认生成的@synthesize就不会起作用了，这也就意味着你的类不会自动生成出来实例变量了。你如果要复写set、get方法你就必须要自己声明实例变量。一楼手动写上@synthesize也是一种比较暴力的方法。
 
 @interface testClass : NSObject
 {
 NSString *_token;
 }
 
 @property (nonatomic) NSString *token;
 
 @end
*/
-(void)setBadgeNumber:(NSInteger)badgeNumber
{
    numberLabel.text = @(badgeNumber).stringValue;
    _badgeNumber = badgeNumber;
}

-(NSInteger)badgeNumber
{
    return _badgeNumber;
}

-(void)setIndex:(NSInteger)index
{
    _index = index;
}

-(NSInteger)index
{
    return _index;
}

- (instancetype)initWithSuperView:(UIView *)superView position:(CGPoint)position1 radius:(CGFloat)radius1 andValidAttachDistance:(CGFloat)validAttachDistance1
{
    //backView 的作用是 无论self 加到哪里,所有的计算都按照最底层的坐标去计算
        UIView * backView1 = nil;
        UIViewController  * rootVC          = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        backView1                           = rootVC.view;
        NSParameterAssert(backView1);
        CGRect   frame                      = [superView convertRect:backView1.bounds fromView:backView1];
        self                                = [super initWithFrame:frame];
        if (self) {
        self.backgroundColor                = [UIColor clearColor];
        self.userInteractionEnabled         = YES;
        panGesture                          = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drag:)];
        [self addGestureRecognizer:panGesture];
        [superView addSubview:self];

        backView                            = backView1;
        numberLabelRadius                   = radius1;
        position                            = position1;
        originPoint                         = [superView convertPoint:position toView:backView];
        CGRect numbelLabelRect = {originPoint,{radius1 * 2.0 ,radius1 * 2.0}};

        numberLabel                         = [[UILabel alloc]initWithFrame:numbelLabelRect];
        numberLabel.text                    = @"0";
        numberLabel.textAlignment           = NSTextAlignmentCenter;
        numberLabel.textColor               = [UIColor whiteColor];
        numberLabel.userInteractionEnabled  = YES;
        numberLabel.font                    = [UIFont systemFontOfSize:13];
        numberLabel.backgroundColor         = [UIColor redColor];
        numberLabel.layer.cornerRadius      = numberLabelRadius;
        validAttachDistance                 = validAttachDistance1;
        breakRadius                         = numberLabelRadius/3.0;
        isEndDrag                           = YES;
        numberLabel.layer.masksToBounds     = YES;
        [self   insertSubview:numberLabel atIndex:0];

        originCenter                        = numberLabel.center;

    }
    return self;
}

-(CGFloat)distanceOfTwoPoints:(CGPoint)point1 point2:(CGPoint)point2
{
    CGFloat     offsetX     =   fabs(point2.x - point1.x);
    CGFloat     offsetY     =   fabs(point2.y - point1.y);
    return      sqrt(offsetX*offsetX + offsetY*offsetY);
}

- (void)removeSelf{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform      = CGAffineTransformScale(self.transform, 0.01, 0.01);
    } completion:^(BOOL finished){
        if(_delegate &&
           [_delegate respondsToSelector:@selector(badgeViewDidRemoveFromSuperViewWithIndex:)])
        {
            [_delegate badgeViewDidRemoveFromSuperViewWithIndex:self.index];
        }
        [super removeFromSuperview];
    }];
}

#pragma mark 最关键的方法 drawRect:,重写此方法,并用setNeedsDisPlay 强制调用
-(void)drawRect:(CGRect)rect
{
    if (isBreak) {
        return;
    }
    UIBezierPath *bezierPath      = [UIBezierPath bezierPath];
    CGPoint       centerPoint     = numberLabel.center;
    CGFloat       radius1          = 0.0;
    CGFloat       circleDistance  = [self distanceOfTwoPoints:originCenter point2:centerPoint];
    radius1                        = numberLabelRadius - (circleDistance/10/validAttachDistance)*numberLabelRadius;
    if (radius1 < 0)
    {
        radius1                    = 0.0;
    }
    //计算4个点坐标以及2个贝塞尔曲线控制点
    CGPoint  aPoint         = CGPointZero,
             bPoint         = CGPointZero,
             cPoint         = CGPointZero,
             dPoint         = CGPointZero,
             ctl1Point      = CGPointZero,
             ctl2Point      = CGPointZero;
    
    CGFloat sinAngle        = (centerPoint.x - originCenter.x)/circleDistance;
    CGFloat cosAngle        = (centerPoint.y - originCenter.y)/circleDistance;
    if (circleDistance == 0.0)
    {
        sinAngle            = 0.0;
        cosAngle            = 1.0;
    }
    
    if (breakRadius < radius1)
    {
        aPoint    = CGPointMake(originCenter.x - radius1 * cosAngle, originCenter.y + radius1 * sinAngle);
        bPoint    = CGPointMake(originCenter.x + radius1 * cosAngle, originCenter.y - radius1 * sinAngle);
        cPoint    = CGPointMake(centerPoint.x + numberLabelRadius * cosAngle, centerPoint.y - numberLabelRadius * sinAngle);
        dPoint    = CGPointMake(centerPoint.x - numberLabelRadius * cosAngle, centerPoint.y + numberLabelRadius * sinAngle);
        ctl1Point = CGPointMake(aPoint.x + (circleDistance / 2.0) * sinAngle, aPoint.y + (circleDistance / 2.0) * cosAngle);
        ctl2Point = CGPointMake(bPoint.x + (circleDistance / 2.0) * sinAngle, bPoint.y + (circleDistance / 2.0) * cosAngle);
    }
    
    else
    {   isBreak   = YES;
        radius1    = 0.0;
    }
    
    if (isEndDrag)
    {
        radius1    =0.0;
        aPoint   = CGPointZero,
        bPoint   = CGPointZero,
        cPoint   = CGPointZero,
        dPoint   = CGPointZero,
        ctl1Point  = CGPointZero,
        ctl2Point  = CGPointZero;
    }
    
    [bezierPath moveToPoint:aPoint];
    [bezierPath addQuadCurveToPoint:dPoint controlPoint:ctl1Point];
    [bezierPath addLineToPoint:cPoint];
    [bezierPath addQuadCurveToPoint:bPoint controlPoint:ctl2Point];
    [bezierPath moveToPoint:aPoint];
    [bezierPath closePath];
    
    CGContextRef    context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 0.1);
    CGContextAddArc(context, originCenter.x, originCenter.y, radius1, 0, M_PI * 2.0, NO);

    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextDrawPath(context, kCGPathFillStroke);
    UIGraphicsEndImageContext();
}

- (void)handleEndDragAnimation:(CGFloat)circleDistance{
    //可重新被吸附震动动画效果
    if([UIDevice currentDevice].systemVersion.floatValue >= 7.0){
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setNeedsDisplay];
            numberLabel.center = originCenter;
        } completion:nil];
        return;
    }
}

#pragma mark 手势的响应方法:drag
-(void)drag:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            isEndDrag = NO;
            CGPoint point = [pan locationInView:self.superview];
            NSLog(@"手势点击点x:%f,手势点击点y:%f,圆球x:%f,圆球y:%f,圆球高度:%f,圆球宽度:%f",point.x,point.y,numberLabel.frame.origin.x,numberLabel.frame.origin.y,numberLabel.frame.size.height,numberLabel.frame.size.width);
            enableDrag =  CGRectContainsPoint(numberLabel.frame, point);
            if(enableDrag){
                isBreak = NO;
                if(_delegate && [_delegate respondsToSelector:@selector(badgeViewWillStartDrag)])
                {
                    [_delegate badgeViewWillStartDrag];
                }
            }
        }

            break;
        case UIGestureRecognizerStateChanged:{
            if(enableDrag){
                numberLabel.center = [pan locationInView:self.superview];
                [self setNeedsDisplay];
            }
        }

            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            isEndDrag = YES;
            if(enableDrag){
                CGFloat  circleDistance = [self distanceOfTwoPoints:originCenter point2:numberLabel.center];
                if(isBreak){
                    if(validAttachDistance >= circleDistance){
                        [self handleEndDragAnimation:circleDistance];
                    }else{
                        //销毁标签
                        [self removeSelf];
                    }
                }else{
                    [self handleEndDragAnimation:circleDistance];
                }
                if(_delegate && [_delegate respondsToSelector:@selector(badgeViewDidEndDrag)]){
                    [_delegate badgeViewDidEndDrag];
                }
            }
        }
            break;
        default:
            break;
    }

}

#pragma mark BadgeViewDelegate
-(void)badgeViewDidRemoveFromSuperViewWithIndex:(NSInteger)index
{
    NSLog(@"%s",__func__);
    NSLog(@"已经移除BadgeIndex = %lu",index);
}

-(void)badgeViewDidEndDrag
{
    NSLog(@"%s",__func__);
}

-(void)badgeViewWillStartDrag
{
    NSLog(@"%s",__func__);
}

@end
