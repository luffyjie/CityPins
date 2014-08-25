//
//  CityPinParkListViewController.h
//  CityPin
//
//  Created by lujie on 14-8-14.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface CityPinParkListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property(nonatomic, strong) NSArray *parkList;
@property(nonatomic, assign) CLLocationCoordinate2D start_coordinate;

@end
