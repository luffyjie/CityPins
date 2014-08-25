//
//  CityPinAppDelegate.m
//  CityPin
//
//  Created by lujie on 14-8-13.
//  Copyright (c) 2014年 CityPin. All rights reserved.
//

#import "CityPinAppDelegate.h"
#import "MobClick.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation CityPinAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //友盟统计sdk
    [MobClick startWithAppkey:@"53f6d2d2fd98c57c6e004127" reportPolicy:BATCH channelId:@"appStore"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    //add by lujie 14-8-13 设置全局导航栏的样式和风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x2ecc71)];
    //设置导航栏自定义的按钮的颜色
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    // 设置文本的属性
    NSDictionary *barAttributes = @{ NSFontAttributeName:[UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName:[UIColor blackColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:barAttributes];
    
    //统一设置导航返回按钮图片
//    UIImage *img = [UIImage imageNamed:@"back_btn"];
//    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:img
//                                                      forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];
    //初始化地图管理器
    self.mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数 该处输入注册的权限key，复杂请求不到百度的地图数据
    BOOL ret = [self.mapManager start:@"rqDggxQdnFM4ch9KDbsCeLb3"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
