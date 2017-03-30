//
//  TTScannerTool.h
//  TTScannerDemo
//
//  Created by zhang liangwang on 17/3/25.
//  Copyright © 2017年 zhangliangwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTScannerView;

@protocol TTScannerViewDelegate <NSObject>
- (void)scanSuccess:(TTScannerView *)scanView data:(NSString *)data;
@end

@interface TTScannerView : UIView

@property (nonatomic,weak) id<TTScannerViewDelegate>delegate;
//停止扫描
- (void)stopScanner;




@end
