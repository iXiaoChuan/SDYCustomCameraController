//
//  ZJCMotionManager.h
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/13.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ZJCCameraToolsCenter.h"

@interface ZJCMotionManager : NSObject

@property(nonatomic, assign)UIDeviceOrientation deviceOrientation;
@property(nonatomic, assign)AVCaptureVideoOrientation videoOrientation;

@end
