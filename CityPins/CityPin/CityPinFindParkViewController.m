//
//  CityPinFindParkViewController.m
//  CityPin
//
//  Created by lujie on 14-8-15.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import "CityPinFindParkViewController.h"
#import "CityPinParkListViewController.h"
#import "CityPinGuidViewController.h"
#import "Park.h"

@interface CityPinFindParkViewController ()
@property (weak, nonatomic) IBOutlet BMKMapView *bmkmapview;
@property (nonatomic, strong) UIView *findparkbar;
@property (nonatomic, strong) UILabel *parkname;
@property (nonatomic, strong) UILabel *parktype;
@property (nonatomic, strong) UILabel *parknumb;
@property (nonatomic, strong) UILabel *parkprice;
@property (nonatomic, strong) UIButton *trackBtn;
@property (nonatomic, strong)UIButton *nav_location_Btn;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSArray *parkList;

@end

@implementation CityPinFindParkViewController
{
    CLLocationCoordinate2D start_coordinate;
    CLLocationCoordinate2D end_coordinate;
    UIImage *pinImage;
    UIActivityIndicatorView *activityView;
    Boolean isFinsh;
    NSString *_cachetString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.receivedData=[[NSMutableData alloc]init];
    self.parkList = [[NSMutableArray alloc] init];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
//    self.bmkmapview.zoomEnabled = NO;
//    self.bmkmapview.ZoomEnabledWithTap = NO;
    //请求过程中的加载动画
    activityView=[[UIActivityIndicatorView alloc]initWithFrame:self.view.frame];
    activityView.alpha = 0.5;
    [activityView setBackgroundColor:[UIColor lightGrayColor]];
//    [self.view addSubview:activityView];
    
    //初始化百度地图
    //设定经纬度
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(start_coordinate, BMKCoordinateSpanMake(0.02f,0.02f));
    BMKCoordinateRegion adjustedRegion = [self.bmkmapview regionThatFits:viewRegion];
    [self.bmkmapview setRegion:adjustedRegion animated:YES];
    self.bmkmapview.zoomLevel = 18;
    //添加工具条
    self.findparkbar = [[UIView alloc] initWithFrame:CGRectMake(12, self.view.bounds.size.height - 120, 293, 44)];
    UIColor *findbarColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"findpark_bar_bg"]];
    self.findparkbar.backgroundColor = findbarColor;
    [self.view addSubview:self.findparkbar];
    self.parkname = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 22)];
    self.parkname.text = @"抱歉，未找到！";
    self.parkname.font = [UIFont boldSystemFontOfSize:11.f];
    [self.findparkbar addSubview:self.parkname];
    
    self.parktype = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 75, 22)];
    self.parktype.text = @"场地类型";
    [self.findparkbar addSubview:self.parktype];
    self.parktype.font = [UIFont boldSystemFontOfSize:11.f];
    
    self.parknumb = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 80, 22)];
    self.parknumb.text = @"共有0个车位";
    self.parknumb.font = [UIFont boldSystemFontOfSize:11.f];
    [self.findparkbar addSubview:self.parknumb];
    
    self.parkprice = [[UILabel alloc] initWithFrame:CGRectMake(90, 20, 125, 22)];
    self.parkprice.text = @"收费";
    self.parkprice.font = [UIFont boldSystemFontOfSize:11.f];
    [self.findparkbar addSubview:self.parkprice];
    
    self.trackBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 10, 22, 22)];
    [self.trackBtn setBackgroundImage:[UIImage imageNamed:@"track_btn"] forState:UIControlStateNormal];
    [self.trackBtn addTarget:self action:@selector(trackBtnAction:) forControlEvents:UIControlEventTouchDown];
    [self.findparkbar addSubview:self.trackBtn];
    
    //添加定位导航按钮
    self.nav_location_Btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.bounds.size.height - 170, 32, 32)];
    [self.nav_location_Btn setBackgroundImage:[UIImage imageNamed:@"nav_location_btn"] forState:UIControlStateNormal];
    [self.nav_location_Btn addTarget:self action:@selector(startLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.nav_location_Btn.adjustsImageWhenHighlighted = NO;
    self.nav_location_Btn.userInteractionEnabled = YES;
    [self.view addSubview:self.nav_location_Btn];
    
    //添加自定义的右边跳转到车位列表视图的按钮
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"findpark_right_btn"]
                                                                  style:UIBarButtonItemStyleBordered target:self action:@selector(parklistBtnAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
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
    [self performSelector:@selector(myLocation) withObject:nil afterDelay:0.2f];
    //请求网络数据
    [self postConn:self.lat0 over:self.lat1 over:self.lng0 over:self.lng1];
    
    _cachetString = [NSString stringWithFormat:@"lng0=%@&lng1=%@&lat0=%@&lat1=%@",self.lat0, self.lat1, self.lng0, self.lng1];;

    
    //add by lujie for debug
//    self.parkname.backgroundColor = [UIColor blueColor];
//    self.parktype.backgroundColor = [UIColor redColor];
//    self.parknumb.backgroundColor = [UIColor greenColor];
//    self.parkprice.backgroundColor = [UIColor yellowColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{

    [self.bmkmapview viewWillAppear];
    self.bmkmapview.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.bmkmapview viewWillDisappear];
    self.bmkmapview.delegate = nil;// 此处记得不用的时候需要置nil，否则影响内存的释放
}


#pragma 实现百度地图deleget

/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view;
{
    NSLog(@"didSelectAnnotationView");
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}

/**
 *拖动地图时会回调此接口
 *@param mapview 地图View
 *@param coordinate 返回拖动事件坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    NSString* showmeg = [NSString stringWithFormat:@"地图区域发生了变化(x=%d,y=%d,\r\nwidth=%d,height=%d).\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d",(int)self.visibleMapRect.origin.x,(int)_mapView.visibleMapRect.origin.y,(int)_mapView.visibleMapRect.size.width,(int)_mapView.visibleMapRect.size.height,(int)_mapView.zoomLevel,_mapView.rotation,_mapView.overlooking];
    
    //请求网络数据
    NSInteger zoom = (int)self.bmkmapview.zoomLevel;
//    NSLog(@"%d %d",zoom,self.parkList.count > 9 && self.bmkmapview.zoomLevel <= 16);
    if (self.parkList.count > 100 && zoom <= 16) {
//        NSLog(@"!!!--- %d %d",zoom,self.parkList.count > 9 && self.bmkmapview.zoomLevel <= 16);
        return;
    }
    if (isFinsh) {
        isFinsh = NO;
        BMKMapPoint mpt0;
        mpt0.x = self.bmkmapview.visibleMapRect.origin.x;
        mpt0.y = self.bmkmapview.visibleMapRect.origin.y;
        CLLocationCoordinate2D jw0 = BMKCoordinateForMapPoint(mpt0);
        BMKMapPoint mpt2;
        mpt2.x = self.bmkmapview.visibleMapRect.origin.x+ self.bmkmapview.visibleMapRect.size.width;
        mpt2.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height;
        CLLocationCoordinate2D jw2 = BMKCoordinateForMapPoint(mpt2);
        
        NSString *lat0 = [NSString stringWithFormat:@"%f", jw2.latitude];
        NSString *lat1 = [NSString stringWithFormat:@"%f", jw0.latitude];
        NSString *lng0 = [NSString stringWithFormat:@"%f", jw0.longitude];
        NSString *lng1 = [NSString stringWithFormat:@"%f", jw2.longitude];
        [self postConn:lat0 over:lat1 over:lng0 over:lng1];
    }
}

#pragma 地图标注

//生成用户当前的标注
- (void)myLocation
{
    pinImage = [UIImage imageNamed:@"pin_user_point"];
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = start_coordinate;
    pointAnnotation.title = @"当前我的位置";
    [self.bmkmapview addAnnotation:pointAnnotation];
}

//生成最优停车的标注
- (void)bestPart
{
    pinImage = [UIImage imageNamed:@"pin_blue_point"];
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = [[self.parkList objectAtIndex:0] parkcoord];
    pointAnnotation.title = [[self.parkList objectAtIndex:0] parkname];
    pointAnnotation.subtitle = [NSString stringWithFormat:@"距离：%@m",[[self.parkList objectAtIndex:0] parkdistance] ];
    [self.bmkmapview addAnnotation:pointAnnotation];
    
}

//生成其他停车位的标注
- (void)manyPart
{
    //生成多个地理位置标记
    pinImage = [UIImage imageNamed:@"pin_red_point"];
    for (NSInteger ptcount = 1; ptcount < [self.parkList count]; ptcount++) {
        BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
        pointAnnotation.coordinate = [[self.parkList objectAtIndex:ptcount] parkcoord];
        pointAnnotation.title = [[self.parkList objectAtIndex:ptcount] parkname];
        pointAnnotation.subtitle = [NSString stringWithFormat:@"距离：%@m",[[self.parkList objectAtIndex:0] parkdistance] ];
        [self.bmkmapview addAnnotation:pointAnnotation];
        if (ptcount == 10) {
            return;
        }
    }
}

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//		((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorGreen;
		// 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
    // 设置位置
	annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
	annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    annotationView.image = pinImage;
    return annotationView;
}

#pragma mark 按钮事件处理 btn action

- (void)trackBtnAction:(id)sender
{
    //跳转到导航视图
    CityPinGuidViewController *guidView = [[CityPinGuidViewController alloc] init];
    guidView.navigationItem.title = @"车位导航";
    guidView.navigationItem.hidesBackButton = YES;
    [guidView setPark:[self.parkList objectAtIndex:0] over:start_coordinate];
    [self.navigationController pushViewController:guidView animated:YES];
}

- (void)parklistBtnAction:(id)sender
{
    //跳转到车位列表视图
    CityPinParkListViewController *parlistView = [[CityPinParkListViewController alloc] init];
    parlistView.parkList = self.parkList;
    parlistView.start_coordinate = start_coordinate;
    parlistView.navigationItem.title = @"车位列表";
    parlistView.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:parlistView animated:YES];
}

- (void)backBtnAction:(id)sender {
    //直接返回到navigationController顶层视图
    [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex: 0] animated:YES];
}

- (void)setCoordinate:(CLLocationCoordinate2D) user_coordinate
{
    NSLog(@"findpark收到地理位置%f,%f",user_coordinate.latitude,user_coordinate.longitude);
    start_coordinate = user_coordinate;
}

- (void)startLocation:(id)sender
{
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(start_coordinate, BMKCoordinateSpanMake(0.01f,0.01f));
    BMKCoordinateRegion adjustedRegion = [self.bmkmapview regionThatFits:viewRegion];
    [self.bmkmapview setRegion:adjustedRegion animated:YES];
//    [self postConn:self.lat0 over:self.lat1 over:self.lng0 over:self.lng1];    
//    self.bmkmapview.zoomLevel = 18;

}


#pragma network 网络请求
- (void)postConn:(NSString *)lat0 over:(NSString *)lat1 over:(NSString *) lng0 over:(NSString *)lng1
{
    [activityView startAnimating];
    
    //post请求的传参
    NSString *bodyString = [NSString stringWithFormat:@"lng0=%@&lng1=%@&lat0=%@&lat1=%@",lng0,lng1,lat0,lat1];
    //取得重复请求
    if ([bodyString isEqualToString:_cachetString]) {
        return ;
    }
    _cachetString = bodyString;
    //把bodyString转换为NSData数据
    NSData *bodyData = [[bodyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
    //获取url地址http://114.215.187.69/citypin/rs/park/search/round/area
    NSURL *Url = [NSURL URLWithString:@"http://114.215.187.69/citypin/rs/park/search/round/area"];
    //请求这个地址， timeoutInterval:10 设置为10s超时：请求时间超过10s会被认为连接不上，连接超时
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];//请求头
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request  delegate:self];
    if (connection == nil) {
        
        NSLog(@"创建失败");
        return;
    }
}

#pragma connection deleget

// 收到回应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isFinsh = YES;
    NSDictionary *parkdic = [NSJSONSerialization JSONObjectWithData:self.receivedData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *park_array = [parkdic objectForKey:@"data"];
    [activityView stopAnimating];
    if (park_array.count > 0) {
        NSMutableArray *parkarry = [[NSMutableArray alloc] init];
        CLLocationCoordinate2D park_coord;
        BMKMapPoint start;
        BMKMapPoint end;
        start = BMKMapPointForCoordinate(start_coordinate);
        for (NSDictionary *pindic in park_array) {
            Park *park = [[Park alloc] init];
            [park setValue:[pindic objectForKey:@"area"] forKey:@"parkname"];
            [park setValue:[pindic objectForKey:@"atype"] forKey:@"parktype"];
            [park setValue:[pindic objectForKey:@"pnum"] forKey:@"parknumb"];
            [park setValue:[pindic objectForKey:@"priceday"] forKey:@"parkprice"];
            park_coord.latitude = [[pindic objectForKey:@"lat"] floatValue];
            park_coord.longitude = [[pindic objectForKey:@"lng"] floatValue];
            park.parkcoord = park_coord;
            end = BMKMapPointForCoordinate(park_coord);
            [park setValue: [NSString stringWithFormat:@"%0.0f",BMKMetersBetweenMapPoints(start,end)] forKey:@"parkdistance"];
            [parkarry addObject:park];
        }
        
        //对停车场按照距离进行排序
        NSArray *newList = [[NSArray alloc] initWithArray:[parkarry sortedArrayUsingComparator:^NSComparisonResult(Park *obj1, Park *obj2) {
            if ([obj1.parkdistance intValue] > [obj2.parkdistance intValue]){
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }}]];

        if (self.parkList.count > 0 && [self dataEquals:newList]) {
            
            return ;
        }
        
        self.parkList = [[NSArray alloc] initWithArray:[parkarry sortedArrayUsingComparator:^NSComparisonResult(Park *obj1, Park *obj2) {
            if ([obj1.parkdistance intValue] > [obj2.parkdistance intValue]){
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }}]];
 /*
        self.parkList = [parkarry sortedArrayUsingComparator:^NSComparisonResult(Park *obj1, Park *obj2) {
                if ([obj1.parkdistance intValue] > [obj2.parkdistance intValue]){
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
            }}];
        

        //第二种排序方法
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"
                                                                       ascending:YES];
        //其中，price为数组中的对象的属性，这个针对数组中存放对象比较更简洁方便
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        [parkarry sortUsingDescriptors:sortDescriptors];
*/
        self.parkname.text = [[parkarry objectAtIndex:0] parkname];
        self.parkprice.text = [[NSString alloc] initWithFormat:@"%@元/天", [[parkarry objectAtIndex:0] parkprice]];
        self.parknumb.text = [[NSString alloc] initWithFormat:@"共%@个车位",[[parkarry objectAtIndex:0] parknumb]];
        self.parktype.text = [[parkarry objectAtIndex:0] parktype];
        //清空所有的标记
        NSMutableArray *annotationMArray = [[NSArray arrayWithArray: self.bmkmapview.annotations] mutableCopy];
        for (NSInteger i = 1; i < annotationMArray.count; i++) {
            [self.bmkmapview removeAnnotation:[annotationMArray objectAtIndex:i]];
        }
        [self performSelector:@selector(bestPart) withObject:nil afterDelay:0.3f];
        [self performSelector:@selector(manyPart) withObject:nil afterDelay:0.4f];
    }
    
}

-(Boolean)dataEquals:(NSArray *)newList {
    NSInteger minnum = (self.parkList.count > newList.count)? newList.count: self.parkList.count;
    for(NSInteger i=0; i < minnum; i++) {
        if (i < 10) {
            return NO;
        }
        NSString *newname = [[newList objectAtIndex:i] parkname];
        NSString *oldname = [[self.parkList objectAtIndex:i] parkname];
        if(![newname isEqualToString:oldname]) {
            return NO;
        }
    }
    return YES;
}

// 返回错误
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{   
    NSLog(@"Connection failed: %@", error);
    [activityView stopAnimating];
    isFinsh = YES;
}

@end
