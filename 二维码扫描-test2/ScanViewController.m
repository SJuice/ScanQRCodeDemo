//
//  ScanViewController.m
//  二维码扫描-test2
//
//  Created by game-netease on 2021/5/17.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>

//遵守代理协议
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIView *viewPreview;
//创建扫描框
@property (nonatomic, strong) UIView *boxView;
//创建一个AVCaptureSession对象
@property (nonatomic, strong) AVCaptureSession *captureSession;
//创建一个AVCaptureVideoPreviewLayer对象
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;//展示layer
//扫描线
@property (nonatomic, strong) CALayer *scanLayer;
//定时器
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isReading;

@end

@implementation ScanViewController

- (void)dealloc {
    self.captureSession = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initScanVC];
    [self initScanPreview];
    [self judgeAuthority];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopRunning];
}

-(void)initScanVC{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"扫一扫";
}

-(void)initScanPreview{
    self.viewPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    [self.view addSubview:self.viewPreview];
}

#pragma mark --判断权限
-(void)judgeAuthority{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        //要放到主线程中刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            // 若已授权
            if (granted) {
                [self loadScanView]; //调用扫描二维码的方法
            } else {
                //提示弹窗
                NSString *title = @"请在iPhone的“设置-隐私-相机“选项中，允许App访问你的相机";
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
                //添加按钮
                UIAlertAction *conform = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"点击了确认按钮");
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"点击了取消按钮");
                }];
                [alert addAction:conform];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark --扫描二维码核心
-(void)loadScanView{
    //1. 初始化session对象
    _captureSession = [[AVCaptureSession alloc]init];

    //2. 为AVCaptureSession对象添加输入输出
    //2.1 初始化设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.2 创建输入，基于device的输入
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //2.3 创建输出
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //2.4 添加输入输出
    [_captureSession addInput:deviceInput];
    [_captureSession addOutput:metadataOutput];

    //3. 配置AVCaptureMetaDataOutput对象
    //3.1 设置代理
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //3.2 设置元数据类型
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];

    //4. 创建并设置AVCaptureVideoPreviewLayer对象来显示捕获到的视频
    //4.1 实例化预览涂层图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    //4.2 设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //4.3 设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    //4.4 将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];

    //5. 设置扫描范围
    metadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);

    //6. 设置扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(_viewPreview.bounds.size.width * 0.2, _viewPreview.bounds.size.height * 0.2, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f)];
    _boxView.layer.borderColor = [UIColor whiteColor].CGColor;
    _boxView.layer.borderWidth = 1.0;
    [_viewPreview addSubview:_boxView];

    //7. 设置扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor greenColor].CGColor;
    [_boxView.layer addSublayer:_scanLayer];

    //8. 开始
    [self startRunning];
}

#pragma mark --开始
-(void)startRunning{
    if (self.captureSession) {
        self.isReading = YES;
        //开始运行
        [self.captureSession startRunning];
        //开启定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
    }
}

#pragma mark --结束
-(void)stopRunning{
    //判断定时器是否正在工作，若还在工作另起暂停并置空
    if ([_timer isValid]) {
        //正在工作就使其失效
        [_timer invalidate];
        //并给定时器赋值nil
        _timer = nil;
    }
    [self.captureSession stopRunning];
    [_scanLayer removeFromSuperlayer]; // 移除扫描layer
    [_videoPreviewLayer removeFromSuperlayer]; //移除video的layer
}

#pragma mark --移动扫描线
-(void)moveLine{
    CGRect frame = self.scanLayer.frame;
    //判断是否在boxView内
    if (_boxView.frame.size.height < self.scanLayer.frame.origin.y) {
        //超出，设为0，回到最高处，继续向下扫描
        frame.origin.y = 0;
        self.scanLayer.frame = frame;
    } else {
        //向下扫描
        frame.origin.y += 5;
        [UIView animateWithDuration:0.2 animations:^{
            self.scanLayer.frame = frame;
        }];
    }
}

#pragma mark --AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //判断是否正在读取数据
    if (!_isReading) {
        //没有读取，返回
        return;
    }
    //若metadataObjects.count > 0，代表扫描到二维码
    if (metadataObjects.count > 0) {
        _isReading = NO;
        //获取数据
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        //将结果转为字符串
        NSString *result = metadataObject.stringValue;
        if (self.resultBlock) {
            //block传值
            self.resultBlock(result);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
