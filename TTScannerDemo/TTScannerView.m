//
//  TTScannerTool.m
//  TTScannerDemo
//
//  Created by zhang liangwang on 17/3/25.
//  Copyright © 2017年 zhangliangwang. All rights reserved.
//

#import "TTScannerView.h"
#import <AVFoundation/AVFoundation.h>

#define TTColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define Width_Zoom  ScreenWidth/375.0
#define Height_Zoom ScreenHeight/667.0


@interface TTScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *priviewLayer;

@property (nonatomic,strong) UIImageView *containerView;
@property (nonatomic,strong) UIImageView *moveLine;
@property (nonatomic,strong) UIView *topView;



@end

@implementation TTScannerView

//MARK:-懒加载
- (UIImageView *)containerView {
    if (_containerView == nil) {
        CGRect containRect = CGRectMake((ScreenWidth-240*Width_Zoom)/2, (ScreenHeight-240*Width_Zoom)/2, 240*Width_Zoom, 240*Width_Zoom);
        _containerView = [[UIImageView alloc] initWithFrame:containRect];
        _containerView.image = [UIImage imageNamed:@"code_zone"];
        
    }
    return _containerView;

}

- (UIImageView *)moveLine {
    if (_moveLine == nil) {
        CGRect lineRect = CGRectMake((ScreenWidth-240*Width_Zoom)/2, (ScreenHeight-240*Width_Zoom)/2, 240*Width_Zoom, 6);
        _moveLine = [[UIImageView alloc] initWithFrame:lineRect];
        _moveLine.image = [UIImage imageNamed:@"code_scan_line"];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        animation.fromValue = @(6);
        animation.toValue = @(240*Width_Zoom-12);
        animation.repeatCount = NSUIntegerMax;
        animation.autoreverses = false;//动画是否倒回移动
        animation.duration = 2;
        [_moveLine.layer addAnimation:animation forKey:nil];
    }
    return _moveLine;
}

- (UIView *)topView {
    if (_topView == nil) {
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth-240*Width_Zoom)/2, (ScreenHeight-240*Width_Zoom)/2-46-80, 240*Width_Zoom, 46)];
        _topView.layer.cornerRadius = 5;
        _topView.layer.masksToBounds = true;
        _topView.backgroundColor = [UIColor blackColor];
        
        UIImageView *codeImage = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 25, 24)];
        codeImage.image = [UIImage imageNamed:@"code"];
        [_topView addSubview:codeImage];
        
        CGFloat tip_X = CGRectGetMaxX(codeImage.frame)+14;
        CGFloat tip_W = 240*Width_Zoom - CGRectGetMaxX(codeImage.frame) - 14 - 14;
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tip_X, 10, tip_W, 26)];
        tipLabel.numberOfLines = 0;
        tipLabel.text = @"Hover over code with camare Avoid\nglare and shadows.";
        tipLabel.font = [UIFont systemFontOfSize:10];
        tipLabel.textColor = TTColor(0xffffff);
        [_topView addSubview:tipLabel];
    }
    
    return _topView;
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
    
    // 添加头部
    [self addSubview:self.topView];
    
    // 添加扫描容器
    [self addSubview:self.containerView];
    
    // 添加扫描条
    [self addSubview:self.moveLine];
    
    // session
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];

    // device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
   // input
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) { //设备不支持相机
        NSString *msg = @"Your device does not support camera functionality";
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

    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,  //条形码
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode128Code];
    
    // 设置代理，主线程刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];


    CGRect viewRect = self.frame;
    
    CGRect containRect = self.containerView.frame;
    CGFloat x = containRect.origin.y / viewRect.size.height;
    CGFloat y = containRect.origin.x / viewRect.size.width;
    CGFloat width = containRect.size.height / viewRect.size.height;
    CGFloat height = containRect.size.width / viewRect.size.width;
    // 确定扫描区域
    output.rectOfInterest = CGRectMake(x, y, width, height);
    
    // 创建预览图层
    self.priviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.priviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.priviewLayer.frame = self.frame;
    [self.layer insertSublayer:self.priviewLayer atIndex:0];
    
    // 开始扫描
    [self.session startRunning];

}

//MARK:- 停止扫描
- (void)stopScanner {
    NSLog(@"---stop--");
    [self.session stopRunning];
    [self.layer removeFromSuperlayer];
}


//MARKP-AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    NSString *stringValue;
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        stringValue = object.stringValue;
        
        NSLog(@"--二维码--%@",object.stringValue);
        
        if ([self.delegate respondsToSelector:@selector(scanSuccess:data:)]) {
            [self.delegate scanSuccess:self data:stringValue];
        }
        
        [self stopScanner];
        
    }
    
}


@end



































