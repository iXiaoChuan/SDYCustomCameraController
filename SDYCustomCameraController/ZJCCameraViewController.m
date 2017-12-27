//
//  ZJCCameraViewController.m
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/11.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import "ZJCCameraViewController.h"
#import "ZJCCameraView.h"
#import "ZJCCameraToolsCenter.h"
#import "UIView+ZJCAdditions.h"
#import "ZJCMotionManager.h"
#import "ZJCCameraCropViewController.h"

@interface ZJCCameraViewController () <ZJCCameraCropViewControllerDelegate,ZJCCameraViewDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>{
    // AVCaptureSession
    AVCaptureSession          *_captureSession;
    // Input
    AVCaptureDeviceInput      *_deviceInput;
    // Output
    AVCaptureConnection       *_videoConnection;
    AVCaptureConnection       *_audioConnection;
    AVCaptureVideoDataOutput  *_videoOutput;
    AVCaptureStillImageOutput *_imageOutput;
    AVCaptureFlashMode         _currentflashMode;           // 当前闪光灯的模式
}

/** Camera interface view */
@property (strong, nonatomic) ZJCCameraView * cameraView;
/** Device orientation check manager */
@property (strong, nonatomic) ZJCMotionManager * motionManager;
/** 设备方向 */
@property(nonatomic, assign) AVCaptureVideoOrientation	referenceOrientation;

@end

@implementation ZJCCameraViewController

#pragma mark - Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad];
    [self setZJCCameraViewControllerBase];
    [self setZJCCameraViewControllerUI];
    [self setAVCaptureSession];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc{
    NSLog(@"================ZJCCameraViewController delloc!!!===============");
    self.cameraView = nil;
    self.motionManager = nil;
    _captureSession = nil;
    _deviceInput = nil;
    _videoConnection = nil;
    _audioConnection = nil;
    _videoOutput = nil;
    _imageOutput = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

#pragma mark - Set Base And UI
- (void)setZJCCameraViewControllerBase{
    self.view.backgroundColor = [UIColor blackColor];
    _referenceOrientation = AVCaptureVideoOrientationPortrait;
    _motionManager = [[ZJCMotionManager alloc] init];
}

- (void)setZJCCameraViewControllerUI{
    if ([UIApplication sharedApplication].statusBarHidden == YES) {
        self.cameraView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else{
        self.cameraView.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT-20);
    }
    [self.view addSubview:self.cameraView];
    
}

#pragma mark - ZJCCameraViewDelegate
// 对焦
- (void)focusAction:(ZJCCameraView *)cameraView point:(CGPoint)point success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail{
    id error = [self facousAtPoint:point];
    error ? (!fail?:fail(error)) : (!success?:success());
}
// 曝光
- (void)exposAction:(ZJCCameraView *)cameraView point:(CGPoint)point success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail{
    id error = [self exposeAtPoint:point];
    error ? (!fail?:fail(error)) : (!success?:success());
}
// 摄像头
- (void)swicthCameraAction:(ZJCCameraView *)cameraView success:(ZJCCameraViewSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail{
    id error = [self switchCameras];
    error?!fail?:fail(error):!success?:success();
}
// 闪光灯
- (void)flashLightAction:(ZJCCameraView *)cameraView success:(ZJCCameraViewFlashSuccessBlock)success fail:(ZJCCameraViewFailBlock)fail{
    id error = [self changeFlash:cameraView.flashStatus];
    if (error) {
        error?!fail?:fail(error):!success?:success(NO);
    }else{
        error?!fail?:fail(error):!success?:success(YES);
    }
}
// 取消
- (void)cancelAction:(ZJCCameraView *)cameraView{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(imagePickerDidCancel:)]) {
        [self.delegate imagePickerDidCancel:self];
    }
}
// 拍照
- (void)catchPhotoAction:(ZJCCameraView *)cameraView{
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    id takePictureSuccess = ^(CMSampleBufferRef sampleBuffer,NSError *error){
        if (sampleBuffer == NULL) {
            // TODO:错误处理
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        // FIXME: 跳转图片裁切控制器
        CGRect cropframe = CGRectZero;
        if (self.isAllowEditing) {
            cropframe = CGRectMake(0, (SCREEN_HEIGHT - SCREEN_WIDTH)/2, SCREEN_WIDTH, SCREEN_WIDTH);
        }else{
            cropframe = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }
        ZJCCameraCropViewController *imgCropperVC = [[ZJCCameraCropViewController alloc] initWithImage:image cropFrame:cropframe limitScaleRatio:3.0 isAllowEditing:self.isAllowEditing];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            
        }];
        
    };
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:takePictureSuccess];
}

#pragma mark ZJCCameraCropViewControllerDelegate
- (void)imageCropper:(ZJCCameraCropViewController *)cropViewController didFinishi:(UIImage *)editedImage{
    if ([self.delegate respondsToSelector:@selector(imagePicker:didFinishi:)]) {
        [self.delegate imagePicker:self didFinishi:editedImage];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imageCropperDidCancel:(ZJCCameraCropViewController *)cropViewConroller{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureSession
/** Creat AVCapture Session */
- (void)setAVCaptureSession{
    NSError * error;
    _captureSession = [[AVCaptureSession alloc]init];
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [self setupSessionInputs:&error];
    [self setupSessionOutputs:&error];
    if (!error) {
        [self.cameraView.previewView setCaptureSessionsion:_captureSession];
        [self startCaptureSession];
    }
}

/** Add input */
- (void)setupSessionInputs:(NSError **)error
{
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_captureSession canAddInput:videoInput]){
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
    }
    
//    // 音频输入
//    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
//    if ([_captureSession canAddInput:audioIn]){
//        [_captureSession addInput:audioIn];
//    }
}

// 添加输出
- (void)setupSessionOutputs:(NSError **)error
{
    dispatch_queue_t captureQueue = dispatch_queue_create("com.cc.MovieCaptureQueue", DISPATCH_QUEUE_SERIAL);
    
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_captureSession canAddOutput:videoOut]){
        [_captureSession addOutput:videoOut];
        _videoOutput = videoOut;
    }
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    // 音频输出
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_captureSession canAddOutput:audioOut]){
        [_captureSession addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_captureSession canAddOutput:imageOutput]) {
        [_captureSession addOutput:imageOutput];
        _imageOutput = imageOutput;
    }
}

// 开启捕捉
- (void)startCaptureSession{
    if (!_captureSession.isRunning){
        [_captureSession startRunning];
    }
}

// 停止捕捉
- (void)stopCaptureSession{
    if (_captureSession.isRunning){
        [_captureSession stopRunning];
    }
}

#pragma mark 输入设备
// 调整摄像头,需要开启后置摄像头
- (AVCaptureDevice *)inactiveCamera{
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else{
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera{
    return _deviceInput.device;
}


#pragma mark 聚焦
- (id)facousAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToFocus] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        return error;
    }
    return nil;
}

- (BOOL)cameraSupportsTapToFocus{
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

#pragma mark 曝光
static const NSString *CameraAdjustingExposureContext;
- (id)exposeAtPoint:(CGPoint)point{
    AVCaptureDevice *device = [self activeCamera];
    if ([self cameraSupportsTapToExpose] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        return error;
    }
    return nil;
}

- (BOOL)cameraSupportsTapToExpose{
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == &CameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            // 锁定曝光完成了
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CameraAdjustingExposureContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }
                else{
                    // FIXEME:show error
                }
            });
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark 摄像头
- (BOOL)canSwitchCameras{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1;
}

- (id)switchCameras
{
    if (![self canSwitchCameras]) return nil;
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        [_captureSession beginConfiguration];
        [_captureSession removeInput:_deviceInput];
        if ([_captureSession canAddInput:videoInput]) {
            [_captureSession addInput:videoInput];
            _deviceInput = videoInput;
        }
        [_captureSession commitConfiguration];
        
        // 如果从后置转前置，会关闭手电筒，如果之前打开的，需要通知camera更新UI
        if (videoDevice.position == AVCaptureDevicePositionFront) {
            [self.cameraView changeFlashStatus:NO];
        }
        // 闪关灯，前后摄像头的闪光灯是不一样的，所以在转换摄像头后需要重新设置闪光灯
        [self changeFlash:_currentflashMode];
        
        // 由于前置摄像头不支持视频，所以当你转换到前置摄像头时，视频输出就无效了，所以在转换回来时，需要把原来的删除了，在重新加一个新的进去
        [_captureSession beginConfiguration];
        [_captureSession removeOutput:_videoOutput];
        
        AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
        [videoOut setAlwaysDiscardsLateVideoFrames:YES];
        [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
        dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
        [videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
        
        if ([_captureSession canAddOutput:videoOut]) {
            [_captureSession addOutput:videoOut];
            _videoOutput = videoOut;
        }
        _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
        _videoConnection.videoOrientation = self.referenceOrientation;
        [_captureSession commitConfiguration];
        
        return nil;
    }
    return error;
}

#pragma mark 闪光灯
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash];
}

- (AVCaptureFlashMode)flashMode{
    return [[self activeCamera] flashMode];
}

- (id)changeFlash:(AVCaptureFlashMode)flashMode{
    if (![self cameraHasFlash]) {
        NSDictionary *desc = @{NSLocalizedDescriptionKey:@"不支持闪光灯"};
        NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:401 userInfo:desc];
        return error;
    }
    // 如果手电筒打开，先关闭手电筒
    if ([self torchMode] == AVCaptureTorchModeOn) {
        [self setTorchMode:AVCaptureTorchModeOff];
    }
    return [self setFlashMode:flashMode];
}

- (id)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
            _currentflashMode = flashMode;
        }
        return error;
    }
    return nil;
}

#pragma mark 手电筒
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (id)changeTorch:(AVCaptureTorchMode)torchMode{
    if (![self cameraHasTorch]) {
        NSDictionary *desc = @{NSLocalizedDescriptionKey:@"不支持手电筒"};
        NSError *error = [NSError errorWithDomain:@"com.cc.camera" code:403 userInfo:desc];
        return error;
    }
    // 如果闪光灯打开，先关闭闪光灯
    if ([self flashMode] == AVCaptureFlashModeOn) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    return [self setTorchMode:torchMode];
}

- (id)setTorchMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        return error;
    }
    return nil;
}

#pragma mark - Set Private
// 调整设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation{
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

#pragma mark - Set Lazyload
- (ZJCCameraView *)cameraView{
    if (!_cameraView) {
        _cameraView = [[ZJCCameraView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _cameraView.delegate = self;
    }
    return _cameraView;
}

@end
