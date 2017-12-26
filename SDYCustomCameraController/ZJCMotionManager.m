//
//  ZJCMotionManager.m
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/13.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import "ZJCMotionManager.h"
#import <CoreMotion/CoreMotion.h>

@interface ZJCMotionManager ()

@property(nonatomic, strong) CMMotionManager * motionManager;

@end

@implementation ZJCMotionManager

-(instancetype)init{
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1/15.0;
        if (!_motionManager.deviceMotionAvailable) {
            _motionManager = nil;
            return self;
        }
        // Use
        // ** 1/15.0 minute interval
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
    return self;
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    // 检测重力矢量 的 坐标系分量
    // ** 屏幕坐标系 手机平放  X正(向右)  Y正(向前)  Z正(向上)
    // ** Y坐标系值 大于 X坐标系值  说明手机头朝下了(其他类似)
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x))
    {
        if (y >= 0){
            _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            _videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        }
        else{
            _deviceOrientation = UIDeviceOrientationPortrait;
            _videoOrientation = AVCaptureVideoOrientationPortrait;
        }
    }
    else{
        if (x >= 0){
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            _videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else{
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            _videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
    }
}

-(void)dealloc{
    [_motionManager stopDeviceMotionUpdates];
}


@end
