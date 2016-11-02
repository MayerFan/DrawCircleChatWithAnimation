//
//  MYStockInfoMoneyModel.m
//  HeXun-zixuan
//
//  Created by 范名扬 on 16/8/2.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import "MYStockInfoMoneyModel.h"

@implementation MYStockInfoMoneyModel

+ (instancetype)moneyModelWithColor:(UIColor *)color percent:(CGFloat)percent title:(NSString *)title
{
    return [MYStockInfoMoneyModel initModelWithColor:color percent:percent title:title];
}

+ (instancetype)initModelWithColor:(UIColor *)color percent:(CGFloat)percent title:(NSString *)title
{
    MYStockInfoMoneyModel *model = [[self alloc] init];
    if (model) {
        [model setModelWithColor:color percent:percent title:title];
    }
    
    return model;
}

- (void)setModelWithColor:(UIColor *)color percent:(CGFloat)percent title:(NSString *)title
{
    _pStokeColor = color;
    _nPercent = percent;
    _pTitle = title;
}

@end
