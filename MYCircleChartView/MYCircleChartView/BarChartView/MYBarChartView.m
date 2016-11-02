//
//  MYBarChartView.m
//  MYCircleChartView
//
//  Created by 范名扬 on 16/9/7.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import "MYBarChartView.h"

#import "MYBarChartModel.h"

@interface MYBarChartView()
@property (nonatomic, strong)UILabel        *pTitleLabel;
@property (nonatomic, strong)UIButton       *pMoneyInBtn;
@property (nonatomic, strong)UIButton       *pMoneyOutBtn;
@property (nonatomic, strong)UILabel        *pDanWeiLabel;
@property (nonatomic, strong)NSMutableArray *pTempArray;
@end

@implementation MYBarChartView

- (UILabel *)pTitleLabel
{
    if (!_pTitleLabel) {
        _pTitleLabel = [UILabel new];
    }
    return _pTitleLabel;
}
- (UIButton *)pMoneyInBtn
{
    if (!_pMoneyInBtn) {
        _pMoneyInBtn = [UIButton new];
    }
    return _pMoneyInBtn;
}
- (UIButton *)pMoneyOutBtn
{
    if (!_pMoneyOutBtn) {
        _pMoneyOutBtn = [UIButton new];
    }
    return _pMoneyOutBtn;
}
- (UILabel *)pDanWeiLabel
{
    if (!_pDanWeiLabel) {
        _pDanWeiLabel = [UILabel new];
    }
    return _pDanWeiLabel;
}
- (NSMutableArray *)pTempArray
{
    if (!_pTempArray) {
        _pTempArray = [NSMutableArray array];
    }
    return _pTempArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.pTitleLabel.text = @"最近5日增减仓";
        self.pDanWeiLabel.text = @"单位（万）";
        [self.pMoneyInBtn setTitle:@"资金流入" forState:UIControlStateNormal];
        [self.pMoneyOutBtn setTitle:@"资金流出" forState:UIControlStateNormal];
        [self.pMoneyInBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.pMoneyOutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        
        [self addSubview:self.pTitleLabel];
        [self addSubview:self.pMoneyInBtn];
        [self addSubview:self.pMoneyOutBtn];
        [self addSubview:self.pDanWeiLabel];
    }
    return self;
}


- (void)setPDaysArrayM:(NSArray *)pDaysArrayM
{
    [self p_updateData:pDaysArrayM];
}

- (void)p_updateData:(NSArray *)listData
{
    for (UIView *view in self.pTempArray) {
        [view removeFromSuperview];
    }
    
    _pTitleLabel.frame = CGRectMake(0, 100, self.frame.size.width, 20);
    
    NSInteger nCounts = listData.count;
    CGFloat nMargin = 20;
    CGFloat nColorViewH = 100;
    CGFloat nBarWidth = (self.frame.size.width - nMargin*(nCounts+1))/nCounts;
    
    CGFloat nMaxMoney = 0;
    for (MYBarChartModel *model in listData) {
        nMaxMoney = MAX(nMaxMoney, fabs(model.money));
    }
    
    CGRect nDateRect = CGRectZero;
    
    [self.pTempArray removeAllObjects];
    for (int i = 0; i < nCounts; i++) {
        MYBarChartModel *model = listData[i];
        CGFloat nOriginX = nMargin + i*(nBarWidth + nMargin);
        CGRect rect = CGRectMake(nOriginX, CGRectGetMaxY(_pTitleLabel.frame) + 10 + nColorViewH, nBarWidth, 0);
        
        UIColor *pColor = [UIColor blackColor];
        if (model.money < 0) {
            pColor = [UIColor greenColor];
        }else if (model.money > 0 ) {
            pColor = [UIColor redColor];
        }
        
        //添加颜色柱图
        UIView *colorView = [[UIView alloc] initWithFrame:rect];
        colorView.backgroundColor = pColor;
        
        //添加成交量
        UILabel *pNum = [[UILabel alloc] initWithFrame:CGRectMake(nOriginX, CGRectGetMaxY(rect) + 5, nBarWidth, 20)];
        pNum.text = [NSString stringWithFormat:@"%.1f",model.money];
        //添加日期
        UILabel *pDate = [[UILabel alloc] initWithFrame:CGRectMake(nOriginX, CGRectGetMaxY(pNum.frame) + 5, nBarWidth, 20)];
        pDate.text = model.date;
        
        [self addSubview:colorView];
        [self addSubview:pNum];
        [self addSubview:pDate];
        
        //添加动画
        CGFloat nCaculatorH = (fabs(model.money)/nMaxMoney) * nColorViewH;
        CGRect oldFrame = CGRectMake(nOriginX, pNum.frame.origin.y - 5 - nCaculatorH, nBarWidth, nCaculatorH);
        [UIView animateWithDuration:0.5 animations:^{
            colorView.frame = oldFrame;
        }];
        
        [_pTempArray addObject:colorView];
        [_pTempArray addObject:pNum];
        [_pTempArray addObject:pDate];
        
        nDateRect = pDate.frame;
    }
    
    CGFloat nMoneyWidth = (self.frame.size.width - nMargin*(3+1))/3;
    _pMoneyInBtn.frame = CGRectMake(nMargin, CGRectGetMaxY(nDateRect) + 10, nMoneyWidth, 30);
    _pMoneyOutBtn.frame = CGRectMake(CGRectGetMaxX(_pMoneyInBtn.frame) + nMargin, _pMoneyInBtn.frame.origin.y, nMoneyWidth, 30);
    _pDanWeiLabel.frame = CGRectMake(CGRectGetMaxX(_pMoneyOutBtn.frame) + nMargin, _pMoneyInBtn.frame.origin.y, nMoneyWidth, 30);
}


@end
