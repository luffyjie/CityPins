//
//  CityPinParkViewCell.m
//  CityPin
//
//  Created by lujie on 14-8-14.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import "CityPinParkViewCell.h"
#import "CityPinGuidViewController.h"
#define LEFT_IMAGE_HEIGHT_SIZE  94.0
#define LEFT_IMAGE_WIDTH_SIZE   25.0
#define RIGHT_IMAGE_HEIGHT_SIZE   90.0
#define RIGHT_IMAGE_WIDTH_SIZE    88.0
#define TEXT_LEFT_MARGIN    10.0
#define TEXT_RIGHT_MARGIN    5.0

@implementation CityPinParkViewCell
{
    UIImageView *bgimageView;
    UILabel *rowlabel;
    UILabel *parkname;
    UILabel *distance;
    UILabel *parknumb;
    UILabel *parktype;
    UILabel *parkprice;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {

        //设置cell的背景颜色及contentview高度参数进行设置
        self.contentView.frame = [self _contentViewFrame];
        UIColor *tablebgcolor = [[UIColor alloc]initWithRed:201.0/255 green:201.0/255 blue:201.0/255 alpha:1];
        self.backgroundColor = tablebgcolor;
        bgimageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgimageView];
        
        parkname = [[UILabel alloc] initWithFrame:CGRectMake(25, 18, 200, 22)];
        parkname.font = [UIFont boldSystemFontOfSize:13.f];
        [self.contentView addSubview:parkname];
        
        distance = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 70, 18, 50, 22)];
        distance.font = [UIFont boldSystemFontOfSize:13.f];
        [self.contentView addSubview:distance];
        
        parknumb = [[UILabel alloc] initWithFrame:CGRectMake(30, 50, 80, 22)];
        parknumb.font = [UIFont boldSystemFontOfSize:12.f];
        [self.contentView addSubview:parknumb];
        
        parktype = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 120, 22)];
        parktype.font = [UIFont boldSystemFontOfSize:12.f];
        parktype.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:parktype];
        
        parkprice = [[UILabel alloc] initWithFrame:CGRectMake(32, self.contentView.bounds.size.height - 30, 190, 22)];
        parkprice.font = [UIFont boldSystemFontOfSize:12.f];
        parkprice.numberOfLines = 0;//表示label可以多行显示
        [self.contentView addSubview:parkprice];
        
        
        
        //add by lujie for debug
//        rowlabel.backgroundColor = [UIColor lightGrayColor];
//        parkname.backgroundColor = [UIColor blueColor];
//        parktime.backgroundColor = [UIColor blueColor];
//        parktype.backgroundColor = [UIColor redColor];
//        parknumb.backgroundColor = [UIColor greenColor];
//        parkprice.backgroundColor = [UIColor yellowColor];
//        distance.backgroundColor = [UIColor orangeColor];
        
	}
	return self;
}

- (CGRect)_contentViewFrame {
    return CGRectMake(0, 0, 320.0, 107.0);
}

- (CGRect)_bgimageViewFrame {
    return CGRectMake(9.0, 10.0, 302, 97);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [bgimageView setFrame:[self _bgimageViewFrame]];
}

-(void)setPark:(Park *) newPark over: (NSString *)newRow
{
        bgimageView.image = [UIImage imageNamed:@"parklist_cell_bg"];
        parkname.text = [NSString stringWithFormat:@"%@ %@",newRow, newPark.parkname];
        parktype.text = newPark.parktype;
        distance.text = [[NSString alloc] initWithFormat:@"%@m", newPark.parkdistance];
        parkprice.text = [[NSString alloc] initWithFormat:@"%@元/天", newPark.parkprice];
        parknumb.text = [[NSString alloc] initWithFormat:@"共%@个车位", newPark.parknumb];
}

@end
