//
//  AppDelegate.m
//  二维码扫描-test2
//
//  Created by game-netease on 2021/5/17.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    ViewController *vc = [[ViewController alloc] init];
    //初始化导航控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    //设置根控制器为导航控制器
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
