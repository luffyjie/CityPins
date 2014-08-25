//
//  CityPinParkViewCell.h
//  CityPin
//
//  Created by lujie on 14-8-14.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Park.h"

@interface CityPinParkViewCell : UITableViewCell
-(void)setPark:(Park *) newPark over: (NSString *)newRow;

@end
