//
//  MYCircelChartBaseView.h
//  MYCircleChartView
//
//  Created by 范名扬 on 16/8/19.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYCircelChartBaseView : UIView
@property (nonatomic, strong)NSArray                *pCircleArrayM;
/* 内环空白处半径 */
@property (nonatomic, assign)CGFloat                 nRadius;
/* 环形宽度 */
@property (nonatomic, assign)CGFloat                 nCircleWidth;
/* 内环空白处文字 */
@property (nonatomic, copy)NSString                 *pCircleText;
/* 内环空白处文字颜色 */
@property (nonatomic, strong)UIColor                *pCircleTextColor;
/* 内环空白处文字大小 */
@property (nonatomic, assign)CGFloat                 nCircleTextSize;

/* 每部分文本大小 */
@property (nonatomic, assign)CGFloat                 nStrokeTextSize;
@end
