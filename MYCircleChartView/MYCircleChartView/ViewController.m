//
//  ViewController.m
//  MYCircleChartView
//
//  Created by 范名扬 on 16/8/18.
//  Copyright © 2016年 com.hztc. All rights reserved.
//

#import "ViewController.h"

#import "MYCircelChartView.h"
#import "TestViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic, strong)NSMutableArray      *pListData;
@end

@implementation ViewController

- (NSMutableArray *)pListData
{
    if (!_pListData) {
        _pListData = [NSMutableArray array];
    }
    return _pListData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _listTableView.dataSource = self;
    _listTableView.delegate = self;
    
    
    [self.pListData removeAllObjects];
    [_pListData addObject:@"Demo1--整个显示的视图都动画显示"];
    [_pListData addObject:@"Demo2--环形部分和其他部分不同动画显示"];
    [_pListData addObject:@"Demo3--整个显示的视图都动画显示"];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _pListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = _pListData[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    TestViewController *testVC = segue.destinationViewController;
    UITableViewCell *cell = sender;
    testVC.pCellText = cell.textLabel.text;
}

@end
