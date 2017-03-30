//
//  ViewController.m
//  TTScannerDemo
//
//  Created by zhang liangwang on 17/3/25.
//  Copyright © 2017年 zhangliangwang. All rights reserved.
//


#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


#import "ViewController.h"
#import "TTScanViewController.h"
#import "TTScannerView.h"



@interface ViewController () <TTScannerViewDelegate>

@property (nonatomic,strong) TTScannerView *scannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];

    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50 , 100, 80, 40)];
    [btn setTitle:@"Scanner" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn addTarget:self action:@selector(startScanner:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIButton *stop = [[UIButton alloc] initWithFrame:CGRectMake(200 , 100, 80, 40)];
    [stop setTitle:@"Stop" forState:UIControlStateNormal];
    [stop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    stop.backgroundColor = [UIColor lightGrayColor];
    [stop addTarget:self action:@selector(stopScanner:) forControlEvents:UIControlEventTouchUpInside];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:stop];

}

//MARK:-创建，并开始扫描
- (void)startScanner:(UIButton *)sender {
    
    if (!self.scannerView) { //
        CGRect aRect = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.scannerView = [[TTScannerView alloc] initWithFrame:aRect];
        self.scannerView.delegate = self;
        [self.view addSubview:self.scannerView];
    }
}

//MARK:-停止扫描
- (void)stopScanner:(UIButton *)sender {
    
    [self.scannerView stopScanner];
    self.scannerView = nil;
}

//MARK:-扫描成功
- (void)scanSuccess:(TTScannerView *)scanView data:(NSString *)data {
    
    if (data) {
        self.scannerView = nil;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
