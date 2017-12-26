//
//  ZJCCameraCropViewController.h
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/11/13.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJCCameraCropViewController;

@protocol ZJCCameraCropViewControllerDelegate <NSObject>

/** clip finish */
- (void)imageCropper:(ZJCCameraCropViewController *)cropViewController didFinishi:(UIImage *)editedImage;
/** clip cancel */
- (void)imageCropperDidCancel:(ZJCCameraCropViewController *)cropViewConroller;

@end

@interface ZJCCameraCropViewController : UIViewController

/** delegate */
@property (weak, nonatomic) id<ZJCCameraCropViewControllerDelegate> delegate;
/** clip rect */
@property (assign, nonatomic) CGRect cropFrame;

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)linmitRatio;

@end
