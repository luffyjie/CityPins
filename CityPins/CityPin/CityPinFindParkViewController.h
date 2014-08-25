//
//  CityPinFindParkViewController.h
//  CityPin
//
//  Created by lujie on 14-8-15.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface CityPinFindParkViewController : UIViewController <BMKMapViewDelegate>
@property (nonatomic, strong) NSString *lat0;
@property (nonatomic, strong) NSString *lat1;
@property (nonatomic, strong) NSString *lng0;
@property (nonatomic, strong) NSString *lng1;
-(void) setCoordinate:(CLLocationCoordinate2D) user_coordinate;

@end
