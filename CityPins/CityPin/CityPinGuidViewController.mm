//
//  CityPinGuidViewController.m
//  CityPin
//
//  Created by lujie on 14-8-15.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import "CityPinGuidViewController.h"

#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface RouteAnnotation : BMKPointAnnotation
{
	int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
	int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end

@interface UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end

@implementation UIImage(InternalMethod)

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
	CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end

@interface CityPinGuidViewController ()
@property (nonatomic, strong) BMKMapView *bmkmapview;
@property (nonatomic, strong) UIView *guidbar;
@property (nonatomic, strong) UILabel *guidcontent;
@property (nonatomic, strong) UIButton *guid_before_Btn;
@property (nonatomic, strong) UIButton *guid_next_Btn;
@property (nonatomic, strong) UIImageView *guid_image;
@property (nonatomic, strong) NSArray *plan_arry;
@property (nonatomic, strong) UIButton *nav_location_Btn;

@end

@implementation CityPinGuidViewController
{
    CLLocationCoordinate2D start_coordinate;
    BMKAnnotationView* _annotation;
    BMKRouteSearch* _routesearch;
    NSInteger _tipnumb;
    Park *_park;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    //初始化百度地图位置搜索
    _routesearch = [[BMKRouteSearch alloc]init];
    //初始化百度地图
    self.bmkmapview = [[BMKMapView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.bmkmapview];
    //设定经纬度
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(start_coordinate, BMKCoordinateSpanMake(0.01f,0.01f));
    BMKCoordinateRegion adjustedRegion = [self.bmkmapview regionThatFits:viewRegion];
    [self.bmkmapview setRegion:adjustedRegion animated:YES];
//    self.bmkmapview.zoomLevel = 19;
    
    //之前隐藏了push的返回按钮 这里自定义返回按钮，实现跳转到首页的目的
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_btn"]
                                                                   style:UIBarButtonItemStyleBordered target:self action:@selector(backBtnAction:)];
    //兼容iOS7 左边按钮偏移的问题
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backButton];
    }else{
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    //地图导航分段提示
    self.guidbar = [[UILabel alloc] initWithFrame:CGRectMake(7, self.view.bounds.size.height - 120, 306, 39)];
    UIColor *guidbarColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"guid_bar_bg"]];
    self.guidbar.backgroundColor = guidbarColor;
    self.guidbar.userInteractionEnabled = YES;
    [self.view addSubview:self.guidbar];

    self.guid_before_Btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 39)];
    [self.guid_before_Btn setBackgroundImage:[UIImage imageNamed:@"guid_before_btn"] forState:UIControlStateNormal];
    [self.guid_before_Btn addTarget:self action:@selector(guidBeforeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.guid_before_Btn.userInteractionEnabled = YES;
    
    self.guid_next_Btn = [[UIButton alloc] initWithFrame:CGRectMake(self.guidbar.bounds.size.width -39, 0, 39, 39)];
    [self.guid_next_Btn setBackgroundImage:[UIImage imageNamed:@"guid_next_btn"] forState:UIControlStateNormal];
    [self.guid_next_Btn addTarget:self action:@selector(guidNextBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.guid_next_Btn.userInteractionEnabled = YES;
    
    self.guid_image = [[UIImageView alloc]initWithFrame:CGRectMake(self.guid_before_Btn.bounds.size.width, 0, 39, 39)];
    self.guid_image.image = [UIImage imageNamed:@"guid_left"];
    
    self.guidcontent = [[UILabel alloc] initWithFrame:CGRectMake(self.guid_before_Btn.bounds.size.width +
                                                                 self.guid_image.bounds.size.width, 0, 180, 39)];
    self.guidcontent.font = [UIFont boldSystemFontOfSize:13];
    self.guidcontent.text = @"提示信息";
    
    [self.guidbar addSubview:self.guid_before_Btn];
    [self.guidbar addSubview:self.guid_next_Btn];
    [self.guidbar addSubview:self.guid_image];
    [self.guidbar addSubview:self.guidcontent];
    
    //添加定位导航按钮
    self.nav_location_Btn = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.bounds.size.height - 170, 32, 32)];
    [self.nav_location_Btn setBackgroundImage:[UIImage imageNamed:@"nav_location_btn"] forState:UIControlStateNormal];
    [self.nav_location_Btn addTarget:self action:@selector(startLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.nav_location_Btn.adjustsImageWhenHighlighted = NO;
    self.nav_location_Btn.userInteractionEnabled = YES;
    [self.view addSubview:self.nav_location_Btn];
    
    //请求导航数据
    [self guidWay];
    
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
    _routesearch.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.bmkmapview viewWillDisappear];
    self.bmkmapview.delegate = nil;// 此处记得不用的时候需要置nil，否则影响内存的释放
    _routesearch.delegate = nil;
}

#pragma 实现百度地图委托

- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation
{
	BMKAnnotationView* view = nil;
	switch (routeAnnotation.type) {
		case 0:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1: @"images/icon_nav_start.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 1:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
				view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 2:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1: @"images/icon_nav_bus.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 3:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
				view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1: @"images/icon_nav_rail.png"]];
				view.canShowCallout = TRUE;
			}
			view.annotation = routeAnnotation;
		}
			break;
		case 4:
		{
			view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1: @"images/icon_direction.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
			
		}
			break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"waypoint_node"];
			if (view == nil) {
				view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"waypoint_node"];
				view.canShowCallout = TRUE;
			} else {
				[view setNeedsDisplay];
			}
			
			UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1: @"images/icon_nav_waypoint.png"]];
			view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
			view.annotation = routeAnnotation;
        }
            break;
		default:
			break;
	}
	
	return view;
}

- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[RouteAnnotation class]]) {
		return [self getRouteAnnotationView:view viewForAnnotation:(RouteAnnotation*)annotation];
	}
	return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
	return nil;
}

- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    NSArray* array = [NSArray arrayWithArray:self.bmkmapview.annotations];
	[self.bmkmapview removeAnnotations:array];
	array = [NSArray arrayWithArray:self.bmkmapview.overlays];
	[self.bmkmapview removeOverlays:array];
	if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        self.plan_arry = [[NSArray alloc] initWithArray:plan.steps];
        // 计算路线方案中的路段数目
		int size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点（我的位置）";
                item.type = 0;
                [self.bmkmapview addAnnotation:item]; // 添加起点标注self.bmkmapview
                //添加第一个地点的提示信息
                self.guidcontent.text = transitStep.entraceInstruction;
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title =_park.parkname;
                item.type = 1;
                [self.bmkmapview addAnnotation:item]; // 添加起点标注self.bmkmapview
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [self.bmkmapview addAnnotation:item];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [self.bmkmapview addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[self.bmkmapview addOverlay:polyLine]; // 添加路线overlay
		delete []temppoints;
        
		
	}
}


//添加当前位置标注
- (void)addPointAnnotation:(CLLocationCoordinate2D)coor
{
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc]init];
    pointAnnotation.coordinate = coor;
    pointAnnotation.title = @"车位";
    pointAnnotation.subtitle = @"么么达";
    [self.bmkmapview addAnnotation:pointAnnotation];
}

#pragma 导航按钮事件

- (void)backBtnAction:(id)sender {
    //直接返回到navigationController顶层视图
    [self.navigationController popToViewController: [self.navigationController.viewControllers
                                                     objectAtIndex: 0] animated:YES];
}


- (void)setPark:(Park *)end_park over:(CLLocationCoordinate2D)star_pt
{
    _park = end_park;
    start_coordinate = star_pt;
}

- (void)guidWay
{
	BMKPlanNode* start = [[BMKPlanNode alloc]init];
//	start.name = @"天安门";
//    start.cityName = @"北京市";
    [start setPt:start_coordinate];
	BMKPlanNode* end = [[BMKPlanNode alloc]init];
//	end.name = @"百度大厦";
//    end.cityName = @"北京市";
    [end setPt:_park.parkcoord];
    BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
    drivingRouteSearchOption.from = start;
    drivingRouteSearchOption.to = end;
    BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    if(flag)
    {
        NSLog(@"car检索发送成功");
    }
    else
    {
        NSLog(@"car检索发送失败");
    }
}

- (NSString*)getMyBundlePath1:(NSString *)filename
{
                    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}

#pragma 工具栏事件
- (void)guidBeforeBtnAction:(id)sender
{
    if (_tipnumb > 0) {
        _tipnumb--;
        BMKDrivingStep* transitStep = [self.plan_arry objectAtIndex:_tipnumb];
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(transitStep.entrace.location, BMKCoordinateSpanMake(0.001f,0.001f));
        BMKCoordinateRegion adjustedRegion = [self.bmkmapview regionThatFits:viewRegion];
        [self.bmkmapview setRegion:adjustedRegion animated:YES];
        self.guidcontent.text = [transitStep entraceInstruction];
    }
}

- (void)guidNextBtnAction:(id)sender
{
    if (_tipnumb < (self.plan_arry.count)-1) {
        _tipnumb++;
        BMKDrivingStep* transitStep = [self.plan_arry objectAtIndex:_tipnumb];
        BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(transitStep.entrace.location, BMKCoordinateSpanMake(0.001f,0.001f));
        BMKCoordinateRegion adjustedRegion = [self.bmkmapview regionThatFits:viewRegion];
        [self.bmkmapview setRegion:adjustedRegion animated:YES];
        self.guidcontent.text = [transitStep entraceInstruction];
    }
}

- (void)startLocation:(id)sender
{
    _tipnumb = 0;
    self.guidcontent.text = [[self.plan_arry objectAtIndex:_tipnumb] entraceInstruction];
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(start_coordinate, BMKCoordinateSpanMake(0.01f,0.01f));
    BMKCoordinateRegion adjustedRegion = [self.bmkmapview regionThatFits:viewRegion];
    [self.bmkmapview setRegion:adjustedRegion animated:YES];
}

@end
