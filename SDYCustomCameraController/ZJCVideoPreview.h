//
//  CCVideoPreview.h
//  CCCamera
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ZJCVideoPreview : UIView

@property (strong, nonatomic) AVCaptureSession *captureSessionsion;

- (CGPoint)captureDevicePointForPoint:(CGPoint)point;

@end
