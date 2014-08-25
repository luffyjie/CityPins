//
//  CityPinParkListViewController.m
//  CityPin
//
//  Created by lujie on 14-8-14.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import "CityPinParkListViewController.h"
#import "Park.h"
#import "CityPinParkViewCell.h"
#import "CityPinFindParkViewController.h"
#import "CityPinViewController.h"
#import "CityPinGuidViewController.h"

@interface CityPinParkListViewController ()
@property (nonatomic, strong) UITableView *parkTableView;
@property (nonatomic, strong) NSMutableArray *parklist;
@property (nonatomic, strong) UIButton *dis_allBtn;
@property (nonatomic, strong) UIButton *dis_freeBtn;

@end

@implementation CityPinParkListViewController
{
    NSInteger _count;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _count = self.parkList.count>3 ? 3: self.parkList.count;
    
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
//    [self getDataFormFiles];
    // 对table 进行参数设置
    self.parkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64)
                                                      style:UITableViewStylePlain];
    [self.view addSubview:self.parkTableView];
    self.parkTableView.delegate = self;
    self.parkTableView.dataSource = self;
    //设置表格于导航栏的位置距离 特殊需求
    self.parkTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 25)];
    self.parkTableView.showsVerticalScrollIndicator = NO;
    self.parkTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIColor *tablebgcolor = [[UIColor alloc]initWithRed:201.0/255 green:201.0/255 blue:201.0/255 alpha:1];
   self.parkTableView.backgroundColor = tablebgcolor;
    
    self.dis_allBtn = [[UIButton alloc] initWithFrame:CGRectMake(7, self.view.bounds.size.height - 120, 153, 39)];
    [self.dis_allBtn setBackgroundImage:[UIImage imageNamed:@"display_all_btn"] forState:UIControlStateNormal];
    [self.dis_allBtn addTarget:self action:@selector(disallBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.dis_allBtn.userInteractionEnabled = YES;
    
    self.dis_freeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.dis_allBtn.bounds.size.width + 7,
                                                                       self.view.bounds.size.height - 120, 153, 39)];
    [self.dis_freeBtn setBackgroundImage:[UIImage imageNamed:@"display_free_btn"] forState:UIControlStateNormal];
    [self.dis_freeBtn addTarget:self action:@selector(disfreeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.dis_freeBtn.userInteractionEnabled = YES;
    
    [self.view addSubview:self.dis_allBtn];
    [self.view addSubview:self.dis_freeBtn];
    if (self.parkList.count <= 3) {
        self.dis_allBtn.hidden = YES;
        self.dis_freeBtn.hidden = YES;
    }
    
    //添加自定义的右边导航按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"parklist_right_btn"]
                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(rightBtnAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //之前隐藏了push的返回按钮 这里自定义返回按钮，实现跳转到首页的目的
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_btn"]
                                                                    style:UIBarButtonItemStyleBordered target:self action:@selector(backBtnAction:)];
    //兼容iOS7 左边按钮偏移的went
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backButton];
    }else{
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

#pragma mark 获取属性文件数据
-(void)getDataFormFiles
{
    self.parklist = [[NSMutableArray alloc] init];
	NSArray *parkDictionaries = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ParkList" ofType:@"plist"]];
	NSArray *propertyNames = [[NSArray alloc] initWithObjects:@"parkname", @"parknumb", @"parkprice", @"parktime", @"distance", nil];
	for (NSDictionary *townDictionary in parkDictionaries) {
		Park *park = [[Park alloc] init];
		for (NSString *property in propertyNames) {
            [park setValue:[townDictionary objectForKey:property] forKey:property];
		}
		[self.parklist addObject:park];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // dequeue a RecipeTableViewCell, then set its towm to the towm for the current row
    CityPinParkViewCell *parkCell = (CityPinParkViewCell *)[tableView dequeueReusableCellWithIdentifier:@"sconddentifier"];
    if (parkCell == nil){
        parkCell = [[CityPinParkViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sconddentifier"];
    }
    [parkCell setPark:[self.parkList objectAtIndex:indexPath.row] over:[NSString stringWithFormat: @"%d", indexPath.row + 1]];
    //设置点击cell后背景颜色效果
    parkCell.selectionStyle = UITableViewCellSelectionStyleNone;
   UIButton *trackBtn = [[UIButton alloc] initWithFrame:CGRectMake(parkCell.contentView.bounds.size.width - 65,
                                                                   parkCell.contentView.bounds.size.height - 46, 22, 22)];
    [trackBtn setBackgroundImage:[UIImage imageNamed:@"track_btn"] forState:UIControlStateNormal];
    [trackBtn addTarget:self action:@selector(trackBtnAction:) forControlEvents:UIControlEventTouchDown];
    [parkCell.contentView addSubview: trackBtn];
    trackBtn.tag = indexPath.row;
    return parkCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //设置cell的高度
    return 107.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma 工具栏 点击按钮事件

- (void)disallBtnAction:(id)sender
{
    _count = self.parkList.count;
    [self.parkTableView reloadData];
    self.dis_allBtn.hidden = YES;
    self.dis_freeBtn.hidden = YES;
}

- (void)disfreeBtnAction:(id)sender
{
    NSMutableArray *freeList = [[NSMutableArray alloc] init];
    for (Park *park in self.parkList) {
        NSString *free = [park.parkprice substringToIndex:1];
        if ([free isEqualToString:@"0"]) {
            [freeList addObject:park];
        }
    }
    _count = freeList.count;
    self.parkList = freeList;
    [self.parkTableView reloadData];
    self.dis_allBtn.hidden = YES;
    self.dis_freeBtn.hidden = YES;
}

- (void)trackBtnAction:(id)sender
{
    //跳转到导航视图
    UIButton *xx = (UIButton *)sender;
   CityPinGuidViewController *guidView = [[CityPinGuidViewController alloc] init];
   guidView.navigationItem.title = @"车位导航";
   guidView.navigationItem.hidesBackButton = YES;
   [guidView setPark:[self.parkList objectAtIndex:xx.tag] over:self.start_coordinate];
   [self.navigationController pushViewController:guidView animated:YES];
    
}

#pragma 导航按钮事件

- (void)rightBtnAction:(id)sender {
    //直接返回到navigationController上一层视图
    [self.navigationController popToViewController: [self.navigationController.viewControllers
                                                     objectAtIndex: 1] animated:YES];
}

- (void)backBtnAction:(id)sender {
    //直接返回到navigationController顶层视图
    [self.navigationController popToViewController: [self.navigationController.viewControllers
                                                     objectAtIndex: 0] animated:YES];
}


@end
