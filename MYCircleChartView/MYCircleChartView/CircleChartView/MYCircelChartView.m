//
//  MYCircelChartView.m
//  HeXun-zixuan
//
//  Created by 范名扬 on 16/8/8.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import "MYCircelChartView.h"

#define KMaxWidth(obj) MAX(obj.frame.size.width, obj.frame.size.height)

@interface MYCircelChartView ()
/* 蒙层layer */
@property (nonatomic, strong)CAShapeLayer        *pBgLayer;
/* 环内文字layer */
@property (nonatomic, strong)CATextLayer         *pTextLayer;
@property (nonatomic, strong)NSMutableArray      *pTempArrayM;
@property (nonatomic, assign)CGFloat              nTempStart;
@end

@implementation MYCircelChartView

static inline CGPoint centerPoint(UIView *obj){
    return CGPointMake(obj.frame.size.width/2, obj.frame.size.height/2);
}

- (CAShapeLayer *)pBgLayer
{
    if (!_pBgLayer) {
        _pBgLayer = [CAShapeLayer layer];
    }
    return _pBgLayer;
}
- (CATextLayer *)pTextLayer
{
    if (!_pTextLayer) {
        _pTextLayer = [CATextLayer layer];
    }
    return _pTextLayer;
}
- (NSMutableArray *)pTempArrayM
{
    if (!_pTempArrayM) {
        _pTempArrayM = [NSMutableArray arrayWithCapacity:10];
    }
    return _pTempArrayM;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //test
        self.pCircleText = @"今日资金";
        [self p_defaultState];
    }
    return self;
}

- (void)setPCircleArrayM:(NSArray *)pCircleArrayM
{
//    _pCircleArrayM = pCircleArrayM;
    
    [self updataCircleData:pCircleArrayM];
}

- (void)p_defaultState
{
    if (self.nCircleTextSize < 5) {//默认12
        self.nCircleTextSize = 12.f;
    }
    if (!self.pCircleTextColor) {// 默认黑色
        self.pCircleTextColor = [UIColor blackColor];
    }
    if (self.nCircleWidth < 1) {
        self.nCircleWidth = 20;
    }
    if (self.nRadius < 1) {
        self.nRadius = 50;
    }
}

- (void)updataCircleData:(NSArray *)datalist
{
    if (datalist.count < 1) {
        return;
    }
    
    for (UILabel *label in self.subviews) {
        [label removeFromSuperview];
    }
    for (CALayer *layer in self.pTempArrayM) {
        [layer removeFromSuperlayer];
    }
    [_pTempArrayM removeAllObjects];
    
    //添加蒙层
    [self p_addMaskLayer];
    
    _nTempStart = 0;
    for (MYStockInfoMoneyModel *model in datalist) {
        [self drawCircleWithMoneyModel:model];
    }
    
    //添加内环空白处文字
    [self p_addCircleText];
    
    //添加动画
    [self p_layerAnimation];
}

- (void)p_addMaskLayer
{
    //1.蒙层frame设置最大,否则蒙层外的都不显示。 注意：如果蒙层颜色为clearColor(即透明)，那么拥有蒙层的layer层都无法显示
    //2.构造一个半径为self.frame.size.width/2，strokePath为self.frame.size.width的蒙层。
    CGFloat nWidth = KMaxWidth(self);
    
    // 1.成为蒙层的layer层只显示非透明的部分。2.拥有蒙层的layer层处于蒙层layer层frame外的不再显示
    self.layer.mask = self.pBgLayer;
    
    UIBezierPath *pBgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint(self) radius:nWidth/2 startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    _pBgLayer.fillColor   = [UIColor clearColor].CGColor; //注意：fillColor和lineWidth变化
    _pBgLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _pBgLayer.strokeStart = 0.0f;// 表示绘制路径的哪一部分（包括全部0-1），如果没有此属性，表示绘制指定的路径。
    _pBgLayer.strokeEnd   = 1.0f;
    _pBgLayer.lineWidth   = nWidth;
    _pBgLayer.path        = pBgPath.CGPath;
}

- (void)p_addCircleText
{
    [self.layer addSublayer:self.pTextLayer];
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:self.nCircleTextSize]};
    CGSize size = [self.pCircleText boundingRectWithSize:CGSizeMake(self.nRadius, self.nRadius) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    [self p_defaultState];
    _pTextLayer.wrapped = YES;
    _pTextLayer.alignmentMode = kCAAlignmentCenter;
    _pTextLayer.truncationMode = kCATruncationEnd;
    _pTextLayer.contentsScale = [UIScreen mainScreen].scale;
    _pTextLayer.foregroundColor = self.pCircleTextColor.CGColor;
    _pTextLayer.string = self.pCircleText;
    _pTextLayer.fontSize = self.nCircleTextSize;
    _pTextLayer.frame = CGRectMake(0, 0, self.nRadius, size.height);
    _pTextLayer.position = centerPoint(self);
}

- (void)p_layerAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = 0.5;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [_pBgLayer addAnimation:animation forKey:@"circleAnimation"];
}


- (void)drawCircleWithMoneyModel:(MYStockInfoMoneyModel *)moneyModel
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    //注意 lineWidth边框路径宽度，其由半径处向两侧对称满足lineWidth宽度
    CGFloat pathRadius = self.nRadius+ self.nCircleWidth/2; //真实半径
    UIBezierPath *pBigPath = [UIBezierPath bezierPathWithArcCenter:centerPoint(self) radius: pathRadius startAngle:-M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    shapeLayer.path = pBigPath.CGPath;
    shapeLayer.strokeColor = moneyModel.pStokeColor.CGColor;   // 边缘线的颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;   // 闭环填充的颜色
    shapeLayer.lineWidth = self.nCircleWidth;
    shapeLayer.strokeStart = _nTempStart + 0.005; //加0.005各部分之间留白
    shapeLayer.strokeEnd   = _nTempStart + moneyModel.nPercent;
    
    //标题字符串
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:12.0]};
    CGSize size = [moneyModel.pTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    if (size.width > CGRectGetWidth(self.frame) / 2 - pathRadius) {
        size.width = CGRectGetWidth(self.frame) / 2 - pathRadius - 10;
    }
    
    //绘制线
    //每块区域中心弧边距离圆心X轴的角度（注意：角度区域为 -M_PI_2 -- M_PI_2*3）
    float jiaodu = 2*M_PI * (_nTempStart + moneyModel.nPercent/2) - M_PI_2;
    CGFloat stokeRadius = self.nRadius + self.nCircleWidth; //最外环半径
    CGPoint point1 = [self positionWithCenter:centerPoint(self) radius:stokeRadius cirAngle:jiaodu];
    CGPoint point2 = [self positionWithCenter:centerPoint(self) radius:stokeRadius + 10 cirAngle:jiaodu];
    
    
    //折线
    CGFloat line_x = 0;
    CGFloat label_x = 0;
    CGFloat downLineW = 0;
    CGFloat downLineX = 0;
    if (jiaodu > -M_PI_2 && jiaodu <= M_PI_2) {//折线再右侧
        line_x = CGRectGetWidth(self.frame)  - size.width;
        label_x  = line_x + size.width / 2;
        if (point2.x + size.width > CGRectGetWidth(self.frame)) {
            point2.x = CGRectGetWidth(self.frame) - size.width;
        }
        downLineW = line_x - point2.x;
        downLineX = point2.x;
    }else {//折线再左侧
        line_x = size.width;
        label_x = size.width - size.width / 2;
        if (point2.x < size.width) {
            point2.x = size.width;
        }
        downLineW = point2.x - line_x;
        downLineX = line_x;
    }
    
    // 绘制线
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    lineLayer.strokeColor = moneyModel.pStokeColor.CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = 0.5f;
    [linePath moveToPoint:point1];
    [linePath addLineToPoint:point2];
    [linePath addLineToPoint:CGPointMake(line_x, point2.y)];
    lineLayer.path = linePath.CGPath;
    
    
    //添加标题label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 20)];
    label.text = moneyModel.pTitle;
    label.backgroundColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor blackColor];
    label.center = CGPointMake(label_x, point2.y);
    [self addSubview:label];
    
    
    [self.layer addSublayer:shapeLayer];
    [self.layer addSublayer:lineLayer];
    [_pTempArrayM addObject:shapeLayer];
    [_pTempArrayM addObject:lineLayer];
    
    _nTempStart = shapeLayer.strokeEnd;
    
    //提示错误信息
    if (_nTempStart > 1) {
        NSLog(@"总百分比大于100%%，请检查！");
    }
}

// 求某个弧度（角度）的点坐标
- (CGPoint)positionWithCenter:(CGPoint)center radius:(CGFloat)radius cirAngle:(CGFloat)cirAngle
{
    CGPoint point;
    CGFloat pointX = 0.0;
    CGFloat pointY = 0.0;
    //注意： 数学上0-360度是从右上角区域开始，OC中0-360度从右下角区域开始
    //    NSLog(@"cos==%f--sin==%f",cos(cirAngle),sin(cirAngle));
    if (cirAngle > - M_PI_2 && cirAngle < 0) {//处于-M_PI_2到0度之间
        pointX = center.x + cos(cirAngle) * radius;
        pointY = center.y + sin(cirAngle) * radius;
    }else if (cirAngle == 0) {
        pointX = center.x + radius;
        pointY = center.y;
    }else if (cirAngle > 0 && cirAngle < M_PI_2) {//处于0 到 M_PI_2
        pointX = center.x + cos(cirAngle) * radius;
        pointY = center.y + sin(cirAngle) * radius;
    }else if (cirAngle == M_PI_2) {
        pointX = center.x;
        pointY = center.y + radius;
    }else if (cirAngle > M_PI_2 && cirAngle < M_PI) {//M_PI_2 - M_PI
        pointX = center.x + cos(cirAngle) * radius;
        pointY = center.y + sin(cirAngle) * radius;
    }else if (cirAngle == M_PI) {
        pointX = center.x - radius;
        pointY = center.y;
    }else if (cirAngle > M_PI && cirAngle < M_PI_2*3) {//M_PI_2 - M_PI_2*3
        pointX = center.x + cos(cirAngle) * radius;
        pointY = center.y + sin(cirAngle) * radius;
    }
    
    point.x = pointX;
    point.y = pointY;
    return point;
}


@end
