//
//  ZJCCameraView.m
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/11.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import "ZJCCameraView.h"
#import "ZJCVideoPreview.h"
#import "ZJCCameraToolsCenter.h"
#import "UIView+ZJCAdditions.h"

@interface ZJCCameraView (){
    NSInteger _flashButtonStatus;
}

/** 预览图层 */
@property (strong, nonatomic) ZJCVideoPreview * previewView;

/** 顶部工具条  */
@property (strong, nonatomic) UIView * topToolBarBackView;
/** 闪光灯按钮 */
@property (strong, nonatomic) UIButton * flashButton;

/** 底部工具条 */
@property (strong, nonatomic) UIView * bottomToolBarBackView;
/** 取消按钮 */
@property (strong, nonatomic) UIButton * cancelButton;
/** 切换摄像头按钮 */
@property (strong, nonatomic) UIButton * swtichCameraButton;
/** 拍照按钮 */
@property (strong, nonatomic) UIButton * catchButton;

/** 对焦动画 */
@property (strong, nonatomic) UIView * focusView;
/** 曝光动画 */
@property(nonatomic, strong) UIView *exposureView;

@end

@implementation ZJCCameraView

- (instancetype)initWithFrame:(CGRect)frame{
    NSAssert(frame.size.height>164 || frame.size.width>374, @"相机视图的高不小于164，宽不小于375");
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self setBase];
        [self setupUI];
    }
    return self;
}

- (void)setBase{
    _flashButtonStatus = 0;
    // 单击/双击  (聚焦/曝光)
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.previewView addGestureRecognizer:tap];
    [self.previewView addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
}

- (void)setupUI{
    // 预览图层
    [self addSubview:self.previewView];
    [self.previewView addSubview:self.focusView];
    [self.previewView addSubview:self.exposureView];
    // 顶部工具条
    [self addSubview:self.topToolBarBackView];
    self.topToolBarBackView.backgroundColor = [UIColor clearColor];
    [self.topToolBarBackView addSubview:self.flashButton];
    // 底部工具条
    [self addSubview:self.bottomToolBarBackView];
    [self.bottomToolBarBackView addSubview:self.cancelButton];
    [self.bottomToolBarBackView addSubview:self.catchButton];
    [self.bottomToolBarBackView addSubview:self.swtichCameraButton];

    /** 约束 */
    self.previewView.frame = CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - SCREEN_HEIGHT*250.0/1334.0);
    
    self.topToolBarBackView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    self.flashButton.frame = CGRectMake(0, 0, 40, 40);
    
    self.bottomToolBarBackView.frame = CGRectMake(0, SCREEN_HEIGHT - SCREEN_HEIGHT*250.0/1334.0, SCREEN_WIDTH, SCREEN_HEIGHT*250.0/1334.0);
    self.cancelButton.frame = CGRectMake(12, self.bottomToolBarBackView.height/2.0 - 25, 50, 50);
    self.catchButton.frame = CGRectMake(self.bottomToolBarBackView.width/2.0 - 31, self.bottomToolBarBackView.height/2.0 - 31, 62, 62);
    self.swtichCameraButton.frame = CGRectMake(self.bottomToolBarBackView.width - 50 - 12, self.bottomToolBarBackView.height/2.0 - 25, 50, 50);
}

#pragma mark - button selector
// 对焦
-(void)tapAction:(UIGestureRecognizer *)tap{
    if ([_delegate respondsToSelector:@selector(focusAction:point:success:fail:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.focusView point:point];
        [_delegate focusAction:self point:[self.previewView captureDevicePointForPoint:point] success:nil fail:^(NSError *error) {
            // FIXME:candle error
        }];
    }
}

// 曝光
-(void)doubleTapAction:(UIGestureRecognizer *)tap{
    if ([_delegate respondsToSelector:@selector(exposAction:point:success:fail:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self runFocusAnimation:self.exposureView point:point];
        [_delegate exposAction:self point:point success:nil fail:^(NSError *error) {
            // FIXME:show error
        }];
    }
    
}

// 闪光灯
- (void)flashButtonClicked:(UIButton *)button{
    // 自动切换2种状态 (开启/关闭)(自动这个并不怎么需要,所以暂时不做)
    [self changeFlashStatus:button.selected];
}

- (void)changeFlashStatus:(BOOL)flashStatus{
    self.flashStatus = self.flashButton.selected;
    if ([_delegate respondsToSelector:@selector(flashLightAction:success:fail:)]) {
        [_delegate flashLightAction:self success:^(BOOL isFlashOn){
            if (isFlashOn) {
                self.flashButton.selected = !self.flashButton.selected;
            }else{
                
            }
        } fail:^(NSError *error) {
            
        }];
    }
}

// 取消
- (void)cancelButtonClicked:(UIButton *)button{
    if ([_delegate respondsToSelector:@selector(cancelAction:)]) {
        [_delegate cancelAction:self];
    }
}

// 拍照
- (void)catchButtonClicked:(UIButton *)button{
    if ([_delegate respondsToSelector:@selector(catchPhotoAction:)]) {
        [_delegate catchPhotoAction:self];
    }
}

// 切换摄像头
- (void)swtichCameraButtonClicked:(UIButton *)button{
    if ([_delegate respondsToSelector:@selector(swicthCameraAction:success:fail:)]) {
        [_delegate swicthCameraAction:self success:nil fail:^(NSError *error) {
            
        }];
    }
}

#pragma mark - private methond
// 聚焦、曝光动画
-(void)runFocusAnimation:(UIView *)view point:(CGPoint)point{
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    }completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

#pragma mark - lazy
- (ZJCVideoPreview *)previewView{
    if (!_previewView) {
        _previewView = [[ZJCVideoPreview alloc] init];
    }
    return _previewView ;
}

- (UIView *)topToolBarBackView{
    if (!_topToolBarBackView) {
        _topToolBarBackView = [[UIView alloc] init];
        _topToolBarBackView.backgroundColor = [UIColor blackColor];
    }
    return _topToolBarBackView;
}

- (UIButton *)flashButton{
    if (!_flashButton) {
        _flashButton = [[UIButton alloc] init];
        [_flashButton addTarget:self action:@selector(flashButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_flashButton setImage:[UIImage imageNamed:@"CC_light_on"] forState:UIControlStateNormal];
        [_flashButton setImage:[UIImage imageNamed:@"CC_light_off"] forState:UIControlStateSelected];
        
        AVCaptureDevice * currentDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        switch (currentDevice.flashMode) {
            case AVCaptureFlashModeOn:
            case AVCaptureFlashModeAuto:
            {
                _flashButton.selected = NO;
                _flashStatus = YES;
            }
                break;
            case AVCaptureFlashModeOff:
            {
                _flashButton.selected = YES;
                _flashStatus = NO;
            }
                break;
            default:
                break;
        }
    }
    return _flashButton;
}

- (UIView *)bottomToolBarBackView{
    if (!_bottomToolBarBackView) {
        _bottomToolBarBackView = [[UIView alloc] init];
        _bottomToolBarBackView.backgroundColor = [UIColor blackColor];
    }
    return _bottomToolBarBackView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (UIButton *)catchButton{
    if (!_catchButton) {
        _catchButton = [[UIButton alloc] init];
        [_catchButton setImage:[UIImage imageNamed:@"CC_catch"] forState:UIControlStateNormal];
        
        [_catchButton addTarget:self action:@selector(catchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _catchButton;
}

- (UIButton *)swtichCameraButton{
    if (!_swtichCameraButton) {
        _swtichCameraButton = [[UIButton alloc] init];
        [_swtichCameraButton setImage:[UIImage imageNamed:@"CC_change"] forState:UIControlStateNormal];
        
        [_swtichCameraButton addTarget:self action:@selector(swtichCameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swtichCameraButton;
}


-(UIView *)focusView{
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.71 blue:0.42 alpha:1].CGColor;
        _focusView.layer.borderWidth = 1.0f;
        _focusView.hidden = YES;
    }
    return _focusView;
}

-(UIView *)exposureView{
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150, 150.0f)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.71 blue:0.42 alpha:1].CGColor;
        _exposureView.layer.borderWidth = 1.0f;
        _exposureView.hidden = YES;
    }
    return _exposureView;
}

@end
