//
//  CityPinViewController.m
//  CityPin
//
//  Created by lujie on 14-8-13.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import "CityPinViewController.h"
#import "BMapKit.h"
#import "CityPinFindParkViewController.h"
#import "CLLocation+Sino.h"

@interface CityPinViewController ()
@property (weak, nonatomic) IBOutlet BMKMapView *bmkmapview;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) BMKLocationService* locService;
@property (nonatomic,assign) CLLocationCoordinate2D pt;
@property (nonatomic, strong) UILabel *toolbar;
@property (nonatomic, strong) UIButton *findparkBtn;
@property (nonatomic, strong) UIButton *stickwarBtn;
@property (nonatomic, strong) UIButton *myparkBtn;
@property (nonatomic, strong) UIButton *nav_location_Btn;
@property (nonatomic, strong) UIButton *nav_follow_Btn;
@property (nonatomic, strong) UIButton *nav_followhead_Btn;
@property (nonatomic, assign) BOOL isUp;

@end

@implementation CityPinViewController
{
    BMKAnnotationView *newAnnotation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    //初始化地图设定
    self.locService = [[BMKLocationService alloc]init];
    self.bmkmapview.hidden = YES;
    self.bmkmapview.zoomLevel = 18;//此处定义地图放大程度
    
    //添加工具条
    self.navigationController.navigationBar.translucent = NO;
    self.toolbar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [self.toolbar setTextColor:[UIColor blackColor]];
    self.toolbar.textAlignment = NSTextAlignmentCenter;
    [self.toolbar setText:@"我的停车"];
    self.toolbar.font = [UIFont boldSystemFontOfSize:18];
    self.navigationItem.titleView = self.toolbar;
    
    self.findparkBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height - 120, 100, 39)];
    [self.findparkBtn setBackgroundImage:[UIImage imageNamed:@"findpark_btn"] forState:UIControlStateNormal];
    [self.findparkBtn addTarget:self action:@selector(findparkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.findparkBtn.userInteractionEnabled = YES;
    
    self.stickwarBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.findparkBtn.bounds.size.width + 10,
                                                                       self.view.bounds.size.height - 120, 100, 39)];
    [self.stickwarBtn setBackgroundImage:[UIImage imageNamed:@"stickwar_btn"] forState:UIControlStateNormal];
    [self.stickwarBtn addTarget:self action:@selector(stickwarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.stickwarBtn.userInteractionEnabled = YES;
    
    self.myparkBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.findparkBtn.bounds.size.width + self.stickwarBtn.bounds.size.width + 10,
                                                                     self.view.bounds.size.height - 120, 100, 39)];
    [self.myparkBtn setBackgroundImage:[UIImage imageNamed:@"mypark_btn"] forState:UIControlStateNormal];
    [self.myparkBtn addTarget:self action:@selector(myparkBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.myparkBtn.userInteractionEnabled = YES;
    [self.view addSubview:self.findparkBtn];
//    [self.view addSubview:self.stickwarBtn];
//    [self.view addSubview:self.myparkBtn];
    
    //添加定位导航按钮
    self.nav_location_Btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.bounds.size.height - 170, 32, 32)];
    [self.nav_location_Btn setBackgroundImage:[UIImage imageNamed:@"nav_location_btn"] forState:UIControlStateNormal];
    [self.nav_location_Btn addTarget:self action:@selector(startLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.nav_location_Btn.adjustsImageWhenHighlighted = NO;
    self.nav_location_Btn.userInteractionEnabled = YES;
    self.nav_location_Btn.hidden = YES;
    
    self.nav_follow_Btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.bounds.size.height - 170, 32, 32)];
    [self.nav_follow_Btn setBackgroundImage:[UIImage imageNamed:@"nav_follow_btn"] forState:UIControlStateNormal];
    [self.nav_follow_Btn addTarget:self action:@selector(startFollowing:) forControlEvents:UIControlEventTouchUpInside];
    self.nav_follow_Btn.adjustsImageWhenHighlighted = NO;
    self.nav_follow_Btn.hidden = YES;
    
    self.nav_followhead_Btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.bounds.size.height - 170, 32, 32)];
    [self.nav_followhead_Btn setBackgroundImage:[UIImage imageNamed:@"nav_followhead_btn"] forState:UIControlStateNormal];
    [self.nav_followhead_Btn addTarget:self action:@selector(startFollowHeading:) forControlEvents:UIControlEventTouchUpInside];
    self.nav_followhead_Btn.adjustsImageWhenHighlighted = NO;
    self.nav_followhead_Btn.hidden = YES;
    
    [self.view addSubview:self.nav_location_Btn];
    [self.view addSubview:self.nav_follow_Btn];
    [self.view addSubview:self.nav_followhead_Btn];
    
    
    //使用百度地图实现定位
    NSLog(@"第次一定位");
    [self.locService startUserLocationService];
    self.bmkmapview.showsUserLocation = NO;
    self.bmkmapview.userTrackingMode = BMKUserTrackingModeFollow;
    self.bmkmapview.showsUserLocation = YES;
    self.bmkmapview.showMapScaleBar = true;
    //地图比例尺的位置
    self.bmkmapview.mapScaleBarPosition = CGPointMake(60,self.view.bounds.size.height - 160);
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
    self.locService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.bmkmapview viewWillDisappear];
    self.bmkmapview.delegate = nil;// 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locService.delegate = nil;
}

#pragma mark btn action 工具栏按钮事件

- (void)findparkBtnAction:(id)sender
{
    if ((self.pt.latitude > 1)) {
        [self performSegueWithIdentifier:@"findparkSegue" sender:self];
    }
}

- (void)stickwarBtnAction:(id)sender
{
//    [self tp0];
//    [self tp1];
//    [self tp2];
//    [self tp3];
//    [self drawQuad1];
//    [self drawQuad2];
    NSLog(@"stickwarBtnAction");
}

-(void)tp0{
    BMKMapPoint mpt0;
    mpt0.x = self.bmkmapview.visibleMapRect.origin.x;
    mpt0.y = self.bmkmapview.visibleMapRect.origin.y;
    CLLocationCoordinate2D jw0 = BMKCoordinateForMapPoint(mpt0);
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = jw0;
    pointAnnotation.title = @"0";
    [self.bmkmapview addAnnotation:pointAnnotation];
}
-(void)tp3{
    BMKMapPoint mpt3;
    mpt3.x = self.bmkmapview.visibleMapRect.origin.x + self.bmkmapview.visibleMapRect.size.width;
    mpt3.y = self.bmkmapview.visibleMapRect.origin.y ;
    CLLocationCoordinate2D jw3 = BMKCoordinateForMapPoint(mpt3);
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = jw3;
    pointAnnotation.title = @"3";
    [self.bmkmapview addAnnotation:pointAnnotation];
}
-(void)tp2{
    BMKMapPoint mpt2;
    mpt2.x = self.bmkmapview.visibleMapRect.origin.x+ self.bmkmapview.visibleMapRect.size.width;
    mpt2.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height;
    CLLocationCoordinate2D jw2 = BMKCoordinateForMapPoint(mpt2);
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = jw2;
    pointAnnotation.title = @"2";
    [self.bmkmapview addAnnotation:pointAnnotation];
}
-(void)tp1{
    BMKMapPoint mpt1;
    mpt1.x = self.bmkmapview.visibleMapRect.origin.x;
    mpt1.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height;
    CLLocationCoordinate2D jw1 = BMKCoordinateForMapPoint(mpt1);
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = jw1;
    pointAnnotation.title = @"1";
    [self.bmkmapview addAnnotation:pointAnnotation];
}

-(void)drawQuad1
{
    BMKPolygon* polygon;
    CLLocationCoordinate2D coords[4] = {0};
    BMKMapPoint mpt2;
    mpt2.x = self.bmkmapview.visibleMapRect.origin.x+ self.bmkmapview.visibleMapRect.size.width;
    mpt2.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height/2;
    CLLocationCoordinate2D jw2 = BMKCoordinateForMapPoint(mpt2);
    
    BMKMapPoint mpt0;
    mpt0.x = self.bmkmapview.visibleMapRect.origin.x;
    mpt0.y = self.bmkmapview.visibleMapRect.origin.y;
    CLLocationCoordinate2D jw0 = BMKCoordinateForMapPoint(mpt0);
    
    BMKMapPoint mpt1;
    mpt1.x = self.bmkmapview.visibleMapRect.origin.x;
    mpt1.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height/2;
    CLLocationCoordinate2D jw1 = BMKCoordinateForMapPoint(mpt1);
    
    BMKMapPoint mpt3;
    mpt3.x = self.bmkmapview.visibleMapRect.origin.x + self.bmkmapview.visibleMapRect.size.width;
    mpt3.y = self.bmkmapview.visibleMapRect.origin.y ;
    CLLocationCoordinate2D jw3 = BMKCoordinateForMapPoint(mpt3);
    
    coords[0].latitude = jw0.latitude;
    coords[0].longitude = jw0.longitude;
    coords[1].latitude = jw1.latitude;;
    coords[1].longitude = jw1.longitude;;
    coords[2].latitude = jw2.latitude;;
    coords[2].longitude = jw2.longitude;;
    coords[3].latitude = jw3.latitude;;
    coords[3].longitude = jw3.longitude;;
    polygon = [BMKPolygon polygonWithCoordinates:coords count:4];
    [self.bmkmapview addOverlay:polygon];
}

-(void)drawQuad2
{
    BMKPolygon* polygon;
    CLLocationCoordinate2D coords[4] = {0};
    BMKMapPoint mpt2;
    mpt2.x = self.bmkmapview.visibleMapRect.origin.x+ self.bmkmapview.visibleMapRect.size.width;
    mpt2.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height;
    CLLocationCoordinate2D jw2 = BMKCoordinateForMapPoint(mpt2);
    
    BMKMapPoint mpt0;
    mpt0.x = self.bmkmapview.visibleMapRect.origin.x;
    mpt0.y = self.bmkmapview.visibleMapRect.origin.y + self.bmkmapview.visibleMapRect.size.height/2;
    CLLocationCoordinate2D jw0 = BMKCoordinateForMapPoint(mpt0);
    
    BMKMapPoint mpt1;
    mpt1.x = self.bmkmapview.visibleMapRect.origin.x;
    mpt1.y = self.bmkmapview.visibleMapRect.origin.y+ self.bmkmapview.visibleMapRect.size.height;
    CLLocationCoordinate2D jw1 = BMKCoordinateForMapPoint(mpt1);
    
    BMKMapPoint mpt3;
    mpt3.x = self.bmkmapview.visibleMapRect.origin.x + self.bmkmapview.visibleMapRect.size.width;
    mpt3.y = self.bmkmapview.visibleMapRect.origin.y + self.bmkmapview.visibleMapRect.size.height/2;
    CLLocationCoordinate2D jw3 = BMKCoordinateForMapPoint(mpt3);
    
    coords[0].latitude = jw0.latitude;
    coords[0].longitude = jw0.longitude;
    coords[1].latitude = jw1.latitude;;
    coords[1].longitude = jw1.longitude;;
    coords[2].latitude = jw2.latitude;;
    coords[2].longitude = jw2.longitude;;
    coords[3].latitude = jw3.latitude;;
    coords[3].longitude = jw3.longitude;;
    polygon = [BMKPolygon polygonWithCoordinates:coords count:4];
    [self.bmkmapview addOverlay:polygon];
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        circleView.lineWidth = 5.0;
		return circleView;
    }
    
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 3.0;
		return polylineView;
    }
	
	if ([overlay isKindOfClass:[BMKPolygon class]])
    {
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth =2.0;
		return polygonView;
    }
    if ([overlay isKindOfClass:[BMKGroundOverlay class]])
    {
        BMKGroundOverlayView* groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
		return groundView;
    }
	return nil;
}


- (void)myparkBtnAction:(id)sender
{

    NSLog(@"myparkBtnAction");
}

#pragma 地图定位按钮 事件

- (void)startLocation:(id)sender
{
    NSLog(@"进入普通定位态");
    [self.locService startUserLocationService];
    self.bmkmapview.showsUserLocation = NO;
    self.bmkmapview.userTrackingMode = BMKUserTrackingModeFollow;
    self.bmkmapview.showsUserLocation = YES;
    self.nav_location_Btn.hidden = YES;
    self.nav_follow_Btn.hidden = NO;
    self.nav_followhead_Btn.hidden = YES;
}

- (void)startFollowing:(id)sender
{
    NSLog(@"进入跟随态");
    [self.locService startUserLocationService];
    self.bmkmapview.showsUserLocation = NO;
    self.bmkmapview.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    self.bmkmapview.showsUserLocation = YES;
    self.nav_location_Btn.hidden = YES;
    self.nav_follow_Btn.hidden = YES;
    self.nav_followhead_Btn.hidden = NO;
}

- (void)startFollowHeading:(id)sender
{
    NSLog(@"进入罗盘态");
    [self.locService startUserLocationService];
    self.bmkmapview.showsUserLocation = NO;
    self.bmkmapview.userTrackingMode = BMKUserTrackingModeFollow;
    self.bmkmapview.showsUserLocation = YES;
    self.nav_location_Btn.hidden = YES;
    self.nav_follow_Btn.hidden = NO;
    self.nav_followhead_Btn.hidden = YES;
}

#pragma mark 处理segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"findparkSegue"]) {
        CityPinFindParkViewController *findParkView = (CityPinFindParkViewController *) segue.destinationViewController;
        [findParkView setCoordinate: self.pt];
        findParkView.lat0 = [NSString stringWithFormat:@"%f", self.pt.latitude - 0.009128/3];
        findParkView.lat1 = [NSString stringWithFormat:@"%f", self.pt.latitude + 0.009128/3];
        findParkView.lng0 = [NSString stringWithFormat:@"%f", self.pt.longitude - 0.005929/2];
        findParkView.lng1 = [NSString stringWithFormat:@"%f", self.pt.longitude + 0.005929/2];
        findParkView.navigationItem.title = @"找车位";
        findParkView.navigationItem.hidesBackButton = YES;
        // 设置返回按钮的文本
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@""
                                       style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backButton];
    }
    
}

#pragma mark 百度地图

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
	NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self.bmkmapview updateLocationData:userLocation];
     self.bmkmapview.hidden = NO;
    //NSLog(@"heading is %@",userLocation.heading);
}

/**
 *点中底图标注后会回调此接口
 *@param mapview 地图View
 *@param mapPoi 标注点信息
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi*)mapPoi
{
//    NSLog(@"onClickedMapPoi-%@",mapPoi.text);
    self.nav_location_Btn.hidden = NO;
    self.nav_follow_Btn.hidden = YES;
    self.nav_followhead_Btn.hidden = YES;
}
/**
 *点中底图空白处会回调此接口
 *@param mapview 地图View
 *@param coordinate 空白处坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate
{
//    NSLog(@"onClickedMapBlank-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    self.nav_location_Btn.hidden = NO;
    self.nav_follow_Btn.hidden = YES;
    self.nav_followhead_Btn.hidden = YES;
}

/**
 *双击地图时会回调此接口
 *@param mapview 地图View
 *@param coordinate 返回双击处坐标点的经纬度
 */
- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate
{
//    NSLog(@"onDoubleClick-latitude==%f,longitude==%f",coordinate.latitude,coordinate.longitude);
    self.nav_location_Btn.hidden = NO;
    self.nav_follow_Btn.hidden = YES;
    self.nav_followhead_Btn.hidden = YES;
}

/**
 *拖动地图时会回调此接口
 *@param mapview 地图View
 *@param coordinate 返回拖动事件坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    NSString* showmeg = [NSString stringWithFormat:@"地图区域发生了变化(x=%d,y=%d,\r\nwidth=%d,height=%d).\r\nZoomLevel=%d;RotateAngle=%d;OverlookAngle=%d",(int)self.bmkmapview.visibleMapRect.origin.x,(int)self.bmkmapview.visibleMapRect.origin.y,(int)self.bmkmapview.visibleMapRect.size.width,(int)self.bmkmapview.visibleMapRect.size.height,(int)self.bmkmapview.zoomLevel,self.bmkmapview.rotation,self.bmkmapview.overlooking];
//    NSLog(@"regionDidChangeAnimated+%@",showmeg);
    self.nav_location_Btn.hidden = NO;
    self.nav_follow_Btn.hidden = YES;
    self.nav_followhead_Btn.hidden = YES;
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.bmkmapview updateLocationData:userLocation];
     self.pt = userLocation.location.coordinate;
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}


@end
