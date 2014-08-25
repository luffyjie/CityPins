//
//  CityPinGuidViewController.h
//  CityPin
//
//  Created by lujie on 14-8-15.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "Park.h"

@interface CityPinGuidViewController : UIViewController <BMKMapViewDelegate, BMKRouteSearchDelegate>
-(void)setPark:(Park *)end_park over:(CLLocationCoordinate2D)star_pt;

@end
