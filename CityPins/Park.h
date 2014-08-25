//
//  park.h
//  CityPin
//
//  Created by lujie on 14-8-14.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMapKit.h"
@interface Park : NSObject
@property (nonatomic, copy) NSString *parkname;
@property (nonatomic, copy) NSString *parknumb;
@property (nonatomic, copy) NSString *parkprice;
@property (nonatomic, copy) NSString *parktime;
@property (nonatomic, copy) NSString *parkdistance;
@property (nonatomic, copy) NSString *parktype;
@property (nonatomic, assign) CLLocationCoordinate2D parkcoord;

@end
