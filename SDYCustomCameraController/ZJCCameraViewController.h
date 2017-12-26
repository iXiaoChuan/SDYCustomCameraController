//
//  ZJCCameraViewController.h
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/11.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJCCameraViewController;

@protocol ZJCCameraViewControllerDelegate <NSObject>

/** clip finish */
- (void)imagePicker:(ZJCCameraViewController *)pickerViewController didFinishi:(UIImage *)editedImage;
/** clip cancel */
- (void)imagePickerDidCancel:(ZJCCameraViewController *)pickerViewConroller;

@end

@interface ZJCCameraViewController : UIViewController

/** allow editing */
@property (assign, nonatomic) BOOL isAllowEditing;

/** delegate */
@property (weak, nonatomic) id<ZJCCameraViewControllerDelegate> delegate;

@end
