//
//  CityPinAppDelegate.h
//  CityPin
//
//  Created by lujie on 14-8-13.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface CityPinAppDelegate : UIResponder <UIApplicationDelegate>
//add by lujie 14－8-13 百度map权限获取管理类
@property (strong, nonatomic)BMKMapManager *mapManager;
@property (strong, nonatomic) UIWindow *window;

@end

