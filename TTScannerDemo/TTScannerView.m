//
//  TTScannerTool.m
//  TTScannerDemo
//
//  Created by zhang liangwang on 17/3/25.
//  Copyright © 2017年 zhangliangwang. All rights reserved.
//

#import "TTScannerView.h"
#import <AVFoundation/AVFoundation.h>


#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface TTScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *priviewLayer;

@property (nonatomic,strong) CALayer *containerLayer;
@property (nonatomic,strong) UIView *containerView;


@end

@implementation TTScannerView

//MARK:-懒加载
- (CALayer *)containerLayer {
    if (_containerLayer == nil) {
        _containerLayer = [[CALayer alloc] init];
    }
    return _containerLayer;
}

- (UIView *)containerView {
    if (_containerView == nil) {
        CGRect outRect = CGRectMake((ScreenWidth-240)/2, (ScreenHeight-240)/2, 240, 240);
        _containerView = [[UIView alloc] initWithFrame:outRect];
        _containerView.layer.borderWidth = 0.5;
        _containerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return _containerView;

}



//MARK:-初始化
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self startScanner];
    }
    
    return self;
}

//MARK:- 开始扫描
- (void)startScanner {
    
    // 添加扫描容器
    [self addSubview:self.containerView];
    
    // session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];

    // device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
   // input
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSString *msg = [NSString stringWithFormat:@"请在手机【设置】-【隐私】-【相机】选项中，允许【%@】访问您的相机",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒"
                                                           message:msg
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    // output
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }

    // 设置扫描类型 availableMetadataObjectTypes
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,  //条形码
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode128Code];
    
    // 设置代理，主线程刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    
    // 获取屏幕的frame
    CGRect viewRect = self.frame;
    // 获取扫描容器的frame
    CGRect containRect = self.containerView.frame;
    CGFloat x = containRect.origin.y / viewRect.size.height;
    CGFloat y = containRect.origin.x / viewRect.size.width;
    CGFloat width = containRect.size.height / viewRect.size.height;
    CGFloat height = containRect.size.width / viewRect.size.width;
    // 设置扫描的有效区域
    output.rectOfInterest = CGRectMake(x, y, width, height);

    // 创建预览区域
    self.priviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.priviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.priviewLayer.frame = self.frame;
    [self.layer insertSublayer:self.priviewLayer atIndex:0];
    
    // 添加容器涂层
    self.containerLayer.frame = self.frame;
    [self.layer addSublayer:self.containerLayer];
    
    // 开始扫描
    [self.session startRunning];

}

//MARK:- 停止扫描
- (void)stopScanner {
    
    NSLog(@"---stop--");
    [self.session stopRunning];
    self.session = nil;
    [self.layer removeFromSuperlayer];
}


//MARKP-AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSString *stringValue;
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        stringValue = object.stringValue;
        
        NSLog(@"--二维码--%@",object.stringValue);
        
        
        AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[self.priviewLayer transformedMetadataObjectForMetadataObject:object];
 
        // 清除之前的描边
        [self clearLayers];
        // 对扫描到的二维码进行描边
        [self drawLine:obj];
        
//        [self stopScanner];
        
    }
    
}

//MARK:-利用贝塞尔曲线绘制描边
- (void)drawLine:(AVMetadataMachineReadableCodeObject *)objc
{
    NSArray *array = objc.corners;
    
    // 1.创建形状图层, 用于保存绘制的矩形
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    // 设置线宽
    layer.lineWidth = 2;
    // 设置描边颜色
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    // 2.创建UIBezierPath, 绘制矩形
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint point = CGPointZero;
    int index = 0;
    
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把点转换为不可变字典
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    
    // 设置起点
    [path moveToPoint:point];
    
    // 2.2连接其它线段
    for (int i = 1; i<array.count; i++) {
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[i], &point);
        [path addLineToPoint:point];
    }
    // 2.3关闭路径
    [path closePath];
    
    layer.path = path.CGPath;
    // 3.将用于保存矩形的图层添加到界面上
    [self.containerLayer addSublayer:layer];
}

//MARK:-清除描边
- (void)clearLayers {
    if (self.containerLayer.sublayers)
    {
        for (CALayer *subLayer in self.containerLayer.sublayers)
        {
            [subLayer removeFromSuperlayer];
        }
    }
}


@end



































