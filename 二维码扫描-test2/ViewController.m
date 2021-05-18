//
//  ViewController.m
//  二维码扫描-test2
//
//  Created by game-netease on 2021/5/17.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initVC];

}

-(void)initVC{
    self.title = @"首页";

    //设置按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    //self.view.bounds.size.width / 2.0 - 40, self.view.bounds.size.height / 2.0
    //先确定frame，定长度和宽度
    btn.frame = CGRectMake(0,0, 80, 40);
    //确定中心，即坐标
    btn.center = self.view.center;
    [btn setTitle:@"扫描二维码" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    //点击按钮时调用jumpToScanVC方法
    [btn addTarget:self action:@selector(jumpToScanVC) forControlEvents:UIControlEventTouchUpInside];
}

-(void)jumpToScanVC{
    ScanViewController *vc = [[ScanViewController alloc]init];
    vc.resultBlock = ^(NSString * _Nonnull value) {
        UIAlertController *alert =  [UIAlertController alertControllerWithTitle:value message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击了确认");
        }];
        [alert addAction:conform];
        [self presentViewController:alert animated:YES completion:nil];
        
    
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:value message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
//        [alertView show];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
@end
