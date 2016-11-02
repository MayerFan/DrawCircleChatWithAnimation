//
//  MYCircelChartViewTwo.m
//  MYCircleChartView
//
//  Created by 范名扬 on 16/8/19.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import "MYCircelChartViewTwo.h"

#define KMaxWidth(obj) MAX(obj.frame.size.width, obj.frame.size.height)
//十六进制转grb
#define KMYHexToRGB(i,a) [UIColor colorWithRed:(i>>16&0xFF)/255.0 green:(i>>8&0xFF)/255.0 blue:(i&0xFF)/255.0 alpha:a]

@interface MYCircelChartViewTwo()
/* 环形layer */
@property (nonatomic, strong)CAShapeLayer        *pCircleLayer;
/* 环形背景layer */
@property (nonatomic, strong)CAShapeLayer        *pCircleBgLayer;
/* 环形蒙层layer */
@property (nonatomic, strong)CAShapeLayer        *pCircleMaskLayer;
/* 环内文字layer */
@property (nonatomic, strong)CATextLayer         *pTextLayer;
@property (nonatomic, strong)NSMutableArray      *pTempArrayM;
@property (nonatomic, assign)CGFloat              nTempStart;

/* 上一个折点（为经过逻辑规则修改过的点） */
@property (nonatomic, assign)CGPoint              nLastDot;
/* 上一个折点（未经过逻辑规则修改过的点） */
@property (nonatomic, assign)CGPoint              nOriginLastDot;
/* 部分和部分的空白分隔比率 */
@property (nonatomic, assign)CGFloat              nSpaceRate;
@end

@implementation MYCircelChartViewTwo

static inline CGPoint centerPoint(UIView *obj){
    return CGPointMake(obj.frame.size.width/2, obj.frame.size.height/2);
}

- (CAShapeLayer *)pCircleLayer
{
    if (!_pCircleLayer) {
        _pCircleLayer = [CAShapeLayer layer];
    }
    return _pCircleLayer;
}
- (CAShapeLayer *)pCircleMaskLayer
{
    if (!_pCircleMaskLayer) {
        _pCircleMaskLayer = [CAShapeLayer layer];
    }
    return _pCircleMaskLayer;
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
- (CAShapeLayer *)pCircleBgLayer
{
    if (!_pCircleBgLayer) {
        _pCircleBgLayer = [CAShapeLayer layer];
    }
    return _pCircleBgLayer;
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
    [self updataCircleData:pCircleArrayM];
}

- (void)p_defaultState
{
    _nSpaceRate = 0.001;
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
    
    //添加环形layer层
    [self p_addCircelLayer];
    
    //添加环形layer层中的背景layer层
    [self p_addCircleBgLayer];
    
    _nTempStart = 0;
    for (MYStockInfoMoneyModel *model in datalist) {
        [self drawCircleWithMoneyModel:model];
    }
    
    //添加内环空白处文字
    [self p_addCircleText];
    
    //添加动画
    [self p_layerAnimation];
}

- (void)p_addCircleBgLayer
{
    CGFloat pathRadius = self.nRadius + self.nCircleWidth + 5; //真实半径
    UIBezierPath *pBigPath = [UIBezierPath bezierPathWithArcCenter:centerPoint(self) radius: pathRadius startAngle:M_PI_4 endAngle:M_PI_4 * 9 clockwise:YES];
    self.pCircleBgLayer.path = pBigPath.CGPath;
    self.pCircleBgLayer.fillColor = KMYHexToRGB(0xe8e8e8, 1).CGColor;   // 闭环填充的颜色
    
    [_pCircleLayer addSublayer:self.pCircleBgLayer];
}

- (void)p_addCircelLayer
{
    //添加蒙层
    [self p_addMaskLayer];
    
    [self.layer addSublayer:_pCircleLayer];
}

- (void)p_addMaskLayer
{
    //1.蒙层frame设置最大,否则蒙层外的都不显示。 注意：蒙层不显示
    //2.构造一个半径为self.frame.size.width/2，strokePath为self.frame.size.width的蒙层。
    CGFloat nWidth = KMaxWidth(self);
    //    nWidth = 80;
    
    // 1.成为蒙层的layer层只显示非透明的部分。2.拥有蒙层的layer层处于蒙层layer层frame外的不再显示
    self.pCircleLayer.mask = self.pCircleMaskLayer;
    
    UIBezierPath *pBgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint(self) radius:nWidth/2 startAngle:M_PI_4 endAngle:M_PI_4 * 9 clockwise:YES];
    _pCircleMaskLayer.fillColor   = [UIColor clearColor].CGColor; //注意：fillColor和lineWidth变化
    _pCircleMaskLayer.strokeColor = [UIColor grayColor].CGColor;
    _pCircleMaskLayer.strokeStart = 0.0f;// 表示绘制路径的哪一部分（包括全部0-1），如果没有此属性，表示绘制指定的路径。
    _pCircleMaskLayer.strokeEnd   = 1.0f;
    _pCircleMaskLayer.lineWidth   = nWidth;
    _pCircleMaskLayer.path        = pBgPath.CGPath;
}

- (void)p_addCircleText
{
    [self.layer addSublayer:self.pTextLayer];
    [self p_defaultState];
    
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:self.nCircleTextSize]};
    CGSize textsize = [self.pCircleText boundingRectWithSize:CGSizeMake(self.nRadius*2, self.nRadius*2) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    _pTextLayer.wrapped = YES;
    _pTextLayer.alignmentMode = kCAAlignmentCenter;
    _pTextLayer.truncationMode = kCATruncationEnd;
    _pTextLayer.contentsScale = [UIScreen mainScreen].scale;
    _pTextLayer.foregroundColor = self.pCircleTextColor.CGColor;
    _pTextLayer.string = self.pCircleText;
    _pTextLayer.fontSize = self.nCircleTextSize;
    _pTextLayer.bounds = CGRectMake(0, 0, textsize.width, textsize.height);
    _pTextLayer.position = centerPoint(self);
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"hidden"];
    animation.duration  = 1;
    animation.fromValue = @1;
    animation.toValue   = @0;
    [_pTextLayer addAnimation:animation forKey:@"circleAnimation"];
}

- (void)p_layerAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = 0.5;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [_pCircleMaskLayer addAnimation:animation forKey:@"circleAnimation"];
}


- (void)drawCircleWithMoneyModel:(MYStockInfoMoneyModel *)moneyModel
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    //注意 lineWidth边框路径宽度，其由半径处向两侧对称满足lineWidth宽度
    CGFloat pathRadius = self.nRadius + self.nCircleWidth/2; //真实半径
    UIBezierPath *pBigPath = [UIBezierPath bezierPathWithArcCenter:centerPoint(self) radius: pathRadius startAngle:M_PI_4 endAngle:M_PI_4 * 9 clockwise:YES];
    shapeLayer.path = pBigPath.CGPath;
    shapeLayer.strokeColor = moneyModel.pStokeColor.CGColor;   // 边缘线的颜色
    shapeLayer.fillColor = [UIColor clearColor].CGColor;   // 闭环填充的颜色
    shapeLayer.lineWidth = self.nCircleWidth;
    shapeLayer.strokeStart = _nTempStart + _nSpaceRate; //0.001为中间空白间距
    shapeLayer.strokeEnd   = _nTempStart + moneyModel.nPercent;
    
    //块标题字符串
    CGFloat nLimitedWidth = CGRectGetWidth(self.frame) - self.nRadius - self.nCircleWidth - 5;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
    CGSize size = [moneyModel.pTitle boundingRectWithSize:CGSizeMake(nLimitedWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    //绘制线
    //每块区域中心弧边距离圆心X轴的角度（注意：角度区域为 -M_PI_2 -- M_PI_2*3）
    float jiaodu = 2*M_PI * (_nTempStart + moneyModel.nPercent/2) + M_PI_4;
    CGFloat stokeRadius = self.nRadius + self.nCircleWidth; //最外环半径
    CGPoint point1 = [self positionWithCenter:centerPoint(self) radius:stokeRadius cirAngle:jiaodu distance:5];
    CGPoint point2 = [self positionWithCenter:centerPoint(self) radius:stokeRadius + 20 cirAngle:jiaodu distance:0 isLastDot:YES];
    
    
    //折线
    CGFloat line_x = 0;
    CGFloat label_x = 0;
    CGFloat label_y = 0;
    if ((jiaodu > M_PI_4 && jiaodu <= M_PI_2) || (jiaodu > M_PI_4 * 6 && jiaodu <= M_PI_4 * 9)) {//折线再右侧
        line_x = CGRectGetWidth(self.frame)  - 20;
        label_x = line_x - size.width;
        label_y = point2.y - size.height;
        
    }else {//折线再左侧
        line_x = 20;
        label_x = line_x;
        label_y = point2.y - size.height;
        
        if (label_y < 0) {//条件容错
            label_y = 0;
            point2 = CGPointMake(point2.x, size.height);
        }
    }
    // 判断文本的位置 逻辑规则是：处于上半部分的文本位置位于折线下方；处于下半部分的文本位置处于折线上方
    
    
    //绘制起始圆点
    CAShapeLayer *startDotLayer = [CAShapeLayer layer];
    startDotLayer.fillColor = moneyModel.pStokeColor.CGColor;
    UIBezierPath *startDotPath = [UIBezierPath bezierPathWithArcCenter:point1 radius:1 startAngle:0 endAngle:2*M_PI clockwise:YES];
    startDotLayer.path = startDotPath.CGPath;
    //绘制结束圆点
    CAShapeLayer *endDotLayer = [CAShapeLayer layer];
    endDotLayer.fillColor = moneyModel.pStokeColor.CGColor;
    UIBezierPath *endDotPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(line_x, point2.y) radius:1 startAngle:0 endAngle:2*M_PI clockwise:YES];
    endDotLayer.path = endDotPath.CGPath;
    
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
    [lineLayer addSublayer:startDotLayer]; //把圆点加到线上 这样linelayer销毁 点layer也销毁
    [lineLayer addSublayer:endDotLayer];
    
    
    //添加块标题label
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:moneyModel.pTitle];
    if ([moneyModel.pTitle containsString:@"\n"]) {
        NSRange range = [moneyModel.pTitle rangeOfString:@"\n"];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:moneyModel.pStokeColor range:NSMakeRange(0, range.location)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, range.location)];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:KMYHexToRGB(0x6e6e6e, 1) range:NSMakeRange(range.location + 1, moneyModel.pTitle.length - range.location - 1)];
        [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(range.location + 1, moneyModel.pTitle.length - range.location - 1)];
    }
    UILabel *label = [UILabel new];
    label.attributedText = attributeStr;
    label.numberOfLines = 0;
    label.frame = CGRectMake(label_x, label_y, size.width, size.height);
    [self addSubview:label];
    
    
    [_pCircleLayer addSublayer:shapeLayer];
    [self.layer addSublayer:lineLayer];
    [_pTempArrayM addObject:shapeLayer];
    [_pTempArrayM addObject:lineLayer];
    
    _nTempStart = shapeLayer.strokeEnd;
    
    //提示错误信息
    if (_nTempStart > 1) {
        NSLog(@"总百分比大于100%%，请检查！");
    }
    
    //给折线添加动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"hidden"];
    animation.duration  = 1;
    animation.fromValue = @1;
    animation.toValue   = @0;
    [lineLayer addAnimation:animation forKey:@"circleAnimation"];
    [label.layer addAnimation:animation forKey:@"circleAnimation"];
}

// 求某个弧度（角度）的点坐标
- (CGPoint)positionWithCenter:(CGPoint)center radius:(CGFloat)radius cirAngle:(CGFloat)cirAngle
{
    return [self positionWithCenter:center radius:radius cirAngle:cirAngle distance:0];
}
// 求某个弧度（角度）的点坐标
//distance : 距离边点的距离
- (CGPoint)positionWithCenter:(CGPoint)center
                       radius:(CGFloat)radius
                     cirAngle:(CGFloat)cirAngle
                     distance:(CGFloat)distance
{
    return [self positionWithCenter:center radius:radius cirAngle:cirAngle distance:distance isLastDot:NO];
}
// 求某个弧度（角度）的点坐标
//distance : 距离边点的距离
//isLastDot : 是否考虑折点
- (CGPoint)positionWithCenter:(CGPoint)center
                       radius:(CGFloat)radius
                     cirAngle:(CGFloat)cirAngle
                     distance:(CGFloat)distance
                    isLastDot:(BOOL)isLastDot
{
    CGPoint point;
    CGPoint tempPoint;
    CGPoint tempOriginPoint;
    CGFloat pointX = 0.0;
    CGFloat pointY = 0.0;
    //注意： 数学上0-360度是从右上角区域开始，OC中0-360度从右下角区域开始
    //    NSLog(@"cos==%f--sin==%f",cos(cirAngle),sin(cirAngle));
    if (cirAngle > M_PI_4*6 && cirAngle < M_PI_4*8) {//处于圆的右上部分
        pointX = center.x + cos(cirAngle) * (radius + distance);
        pointY = center.y + sin(cirAngle) * (radius + distance);
    }else if (cirAngle == M_PI_4*8) {
        pointX = center.x + (radius + distance);
        pointY = center.y;
    }else if ((cirAngle > M_PI_4*8 && cirAngle < M_PI_4*9) || (cirAngle > M_PI_4 && cirAngle < M_PI_4*2)) {//处于圆的右下部分
        pointX = center.x + cos(cirAngle) * (radius + distance);
        pointY = center.y + sin(cirAngle) * (radius + distance);
    }else if (cirAngle == M_PI_4*2) {
        pointX = center.x;
        pointY = center.y + (radius + distance);
    }else if (cirAngle > M_PI_4*2 && cirAngle < M_PI_4*4) {//处于圆的左下部分
        pointX = center.x + cos(cirAngle) * (radius + distance);
        pointY = center.y + sin(cirAngle) * (radius + distance);
    }else if (cirAngle == M_PI) {
        pointX = center.x - (radius + distance);
        pointY = center.y;
    }else if (cirAngle > M_PI && cirAngle < M_PI_4*6) {//处于圆的左上部分
        pointX = center.x + cos(cirAngle) * (radius + distance);
        pointY = center.y + sin(cirAngle) * (radius + distance);
    }
    
    tempOriginPoint.x = pointX;
    tempOriginPoint.y = pointY;
    
    //如果考虑折点 判断折点逻辑规则
    // 同侧指同在右侧或同在左侧
    CGFloat fCenterX = centerPoint(self).x;
    if (isLastDot && ((_nLastDot.x < fCenterX && pointX < fCenterX) || (_nLastDot.x > fCenterX && pointX > fCenterX))) {//同侧
        if (pointY < _nOriginLastDot.y && fabs(_nLastDot.y - pointY) > 50) {
            pointY += 10;
        }else if (pointY > _nOriginLastDot.y && fabs(_nLastDot.y - pointY) > 50) {
            pointY -= 10;
        }else if (pointY < _nOriginLastDot.y && fabs(_nLastDot.y - pointY) < 50) {
            pointY = _nLastDot.y - 40;
        }else if (pointY > _nOriginLastDot.y && fabs(_nLastDot.y - pointY) < 50) {
            pointY = _nLastDot.y + 40;
        }
    }else if (isLastDot && (_nLastDot.x < fCenterX && pointX > fCenterX)) {//两侧
        if (pointY < _nLastDot.y && fabs(_nLastDot.y - pointY) > 50) {
            pointY -= 10;
        }else if (pointY > _nLastDot.y && fabs(_nLastDot.y - pointY) > 50) {
            pointY -= 10;
        }
    }
    tempPoint.x = pointX;
    tempPoint.y = pointY;
    
    point.x = pointX;
    point.y = pointY;
    
    if (isLastDot) {
        _nLastDot = tempPoint;
        _nOriginLastDot = tempOriginPoint;
    }
    
    return point;
}


#pragma mark -- CAAnimationDelegate
// 基类已经遵守了动画代理方法
- (void)animationDidStart:(CAAnimation *)anim{
    //    NSLog(@"animationDidStart");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    //    NSLog(@"animationDidStop%d",flag);
}

@end
