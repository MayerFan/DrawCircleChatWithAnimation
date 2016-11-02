//
//  MYStockInfoMoneyModel.h
//  HeXun-zixuan
//
//  Created by 范名扬 on 16/8/2.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MYStockInfoMoneyModel : NSObject
@property (nonatomic, readonly, copy)NSString           *pTitle;
@property (nonatomic, readonly, copy)UIColor            *pStokeColor;
@property (nonatomic, readonly, assign)CGFloat           nPercent;

+ (instancetype)moneyModelWithColor:(UIColor *)color percent:(CGFloat)percent title:(NSString *)title;

@end
