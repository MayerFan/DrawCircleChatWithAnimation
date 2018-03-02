//
//  TestViewController.m
//  MYCircleChartView
//
//  Created by 范名扬 on 16/8/19.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import "TestViewController.h"

#import "MYCircelChartView.h"
#import "MYCircelChartViewTwo.h"
#import "MYCircelChartBaseView.h"
#import "Masonry.h"

#import "MYBarChartView.h"
#import "MYBarChartModel.h"

@interface TestViewController()
@property (nonatomic, strong)MYCircelChartView                         *pCircleView;
@property (nonatomic, strong)MYCircelChartViewTwo                      *pCircleViewTwo;

@property (nonatomic, strong)MYBarChartView                            *pBarView;
@end

@implementation TestViewController

- (MYCircelChartView *)pCircleView
{
    if (!_pCircleView) {
        _pCircleView = [[MYCircelChartView alloc] initWithFrame:self.view.bounds];
    }
    return _pCircleView;
}
- (MYCircelChartViewTwo *)pCircleViewTwo
{
    if (!_pCircleViewTwo) {
        _pCircleViewTwo = [[MYCircelChartViewTwo alloc] initWithFrame:self.view.bounds];
        _pCircleViewTwo.nCircleWidth = 30;
    }
    return _pCircleViewTwo;
}
- (MYBarChartView *)pBarView
{
    if (!_pBarView) {
        _pBarView = [[MYBarChartView alloc] initWithFrame:self.view.bounds];
    }
    return _pBarView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if ([_pCellText containsString:@"Demo1"]) {
        [self.view addSubview:self.pCircleView];
    }else if ([_pCellText containsString:@"Demo2"]) {
        [self.view addSubview:self.pCircleViewTwo];
    }else if ([_pCellText containsString:@"Demo3"]) {
        [self.view addSubview:self.pBarView];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self p_showViewType];
}

//显示哪种视图类型
- (void)p_showViewType
{
    if ([_pCellText containsString:@"Demo1"]) {
        [self p_showDemoView:_pCircleView];
    }else if ([_pCellText containsString:@"Demo2"]) {
        [self p_showDemoView:_pCircleViewTwo];
    }else if ([_pCellText containsString:@"Demo3"]) {
        [self p_showBarView];
    }
}

- (void)p_showBarView
{
    // test声明
    ///
    // ....
    ////
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:5];
        MYBarChartModel *model1 = [MYBarChartModel new];
        model1.money = -1538.9;
        model1.date = @"06-09";
        [tempArray addObject:model1];
        MYBarChartModel *model2 = [MYBarChartModel new];
        model2.money = -16.4;
        model2.date = @"06-10";
        [tempArray addObject:model2];
        MYBarChartModel *model3 = [MYBarChartModel new];
        model3.money = -147.2;
        model3.date = @"06-11";
        [tempArray addObject:model3];
        MYBarChartModel *model4 = [MYBarChartModel new];
        model4.money = -1293.8;
        model4.date = @"06-12";
        [tempArray addObject:model4];
        MYBarChartModel *model5 = [MYBarChartModel new];
        model5.money = 628.8;
        model5.date = @"06-13";
        [tempArray addObject:model5];
    _pBarView.pDaysArrayM = tempArray;
    
}

- (void)p_showDemoView:(MYCircelChartBaseView *)demoView
{
    MYStockInfoMoneyModel *model1 = [MYStockInfoMoneyModel moneyModelWithColor:[UIColor redColor] percent:0.447 title:@"44.7%\n大单买入"];
    MYStockInfoMoneyModel *model2 = [MYStockInfoMoneyModel moneyModelWithColor:[UIColor greenColor] percent:0.472 title:@"47.2%\n大单卖出"];
    MYStockInfoMoneyModel *model3 = [MYStockInfoMoneyModel moneyModelWithColor:[UIColor orangeColor] percent:0.023 title:@"2.3%\n小单买入"];
    MYStockInfoMoneyModel *model4 = [MYStockInfoMoneyModel moneyModelWithColor:[UIColor blueColor] percent:0.027 title:@"2.7%\n小单卖出"];
    MYStockInfoMoneyModel *model5 = [MYStockInfoMoneyModel moneyModelWithColor:[UIColor purpleColor] percent:0.031 title:@"3.1%\n其他成交"];
    demoView.pCircleArrayM = @[model1, model3, model2, model4, model5];
}

@end
