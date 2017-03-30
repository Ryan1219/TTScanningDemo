//
//  TTScanViewController.m
//  TTScannerDemo
//
//  Created by zhang liangwang on 17/3/25.
//  Copyright © 2017年 zhangliangwang. All rights reserved.
//

#import "TTScanViewController.h"
#import "TTScannerView.h"


#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


@interface TTScanViewController ()

@property (nonatomic,strong) TTScannerView *scannerTool;

@end

@implementation TTScanViewController


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.scannerTool stopScanner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.scannerTool == nil) {
        CGRect aRect = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.scannerTool = [[TTScannerView alloc] initWithFrame:aRect];
        [self.view addSubview:self.scannerTool];
//        [self.scannerTool startScanner];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
