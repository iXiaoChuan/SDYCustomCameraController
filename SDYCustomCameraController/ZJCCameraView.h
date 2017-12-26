//
//  ZJCCameraView.h
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/11.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJCVideoPreview.h"
@class ZJCCameraView;

typedef void(^ZJCCameraViewSuccessBlock)(void);
typedef void(^ZJCCameraViewFlashSuccessBlock)(BOOL isFlashOn);
typedef void(^ZJCCameraViewFailBlock)(NSError *error);

@protocol ZJCCameraViewDelegate <NSObject>
@optional;
/** 对焦 */
-(void)focusAction:(ZJCCameraView *)cameraView point:(CGPoint)point success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail;
/** 曝光 */
-(void)exposAction:(ZJCCameraView *)cameraView point:(CGPoint)point success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail;
/** 切换闪光灯 */
-(void)flashLightAction:(ZJCCameraView *)cameraView success:(ZJCCameraViewFlashSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail;
/** 切换摄像头 */
-(void)swicthCameraAction:(ZJCCameraView *)cameraView success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail;

/** 取消 */
-(void)cancelAction:(ZJCCameraView *)cameraView;
/** 拍照 */
-(void)catchPhotoAction:(ZJCCameraView *)cameraView;

///// 自动聚焦曝光
//-(void)autoFocusAndExposureAction:(ZJCCameraView *)cameraView success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail;
///// 补光按钮
//-(void)torchLightAction:(ZJCCameraView *)cameraView success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail;
///// 停止录制视频
//-(void)stopRecordVideoAction:(ZJCCameraView *)cameraView;
///// 开始录制视频
//-(void)startRecordVideoAction:(ZJCCameraView *)cameraView;
///// 改变拍摄类型
//-(void)didChangeTypeAction:(ZJCCameraView *)cameraView type:(NSInteger)type;

@end

@interface ZJCCameraView : UIView

/** 代理 */
@property (weak, nonatomic) id<ZJCCameraViewDelegate> delegate;
/** 提供真正预览图层的类 (该类返回AVCaptureVideoPreviewLayer图层,并将系统坐标系转换成预览图层坐标系的操作) */
@property(nonatomic, strong, readonly) ZJCVideoPreview *previewView;
/** flashStatus */
@property (assign, nonatomic) BOOL flashStatus;

/** 改变闪光灯 */
- (void)changeFlashStatus:(BOOL)flashStatus;

@end
