//
//  ViewController.m
//  SDYCustomCameraController
//
//  Created by 小川 on 2017/10/11.
//  Copyright © 2017年 sposter.net. All rights reserved.
//

#import "ViewController.h"
#import "ZJCCameraViewController.h"

@interface ViewController () <ZJCCameraViewControllerDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate,NSURLConnectionDownloadDelegate>

/** 图片 */
@property (strong, nonatomic) UIImageView * imageView;
/** 图片 */
@property (strong, nonatomic) UIImageView * imageViewNew;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.5 green:0.3 blue:0 alpha:1];
    [self.navigationController setNavigationBarHidden:YES];
    // 图片
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width)];
    self.imageView.center = CGPointMake(self.view.center.x, self.view.bounds.size.width/2.0);
    self.imageView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
    [self.view addSubview:self.imageView];
    
    // 图片
    self.imageViewNew = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.width, self.view.bounds.size.width, self.view.bounds.size.height - 60 -self.view.bounds.size.width)];
    self.imageViewNew.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
    [self.view addSubview:self.imageViewNew];
    
    // 按钮
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height -60, self.view.bounds.size.width/2.0, 60)];
    [button setTitle:@"拍   照" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor orangeColor]];
    [button addTarget:self action:@selector(buttonclicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton * buttonNew = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height -60, self.view.bounds.size.width/2.0, 60)];
    [buttonNew setTitle:@"下   载" forState:UIControlStateNormal];
    [buttonNew setBackgroundColor:[UIColor greenColor]];
    [buttonNew addTarget:self action:@selector(buttonNewclicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonNew];
}

- (void)buttonclicked:(UIButton *)button{
    ZJCCameraViewController * vc = [[ZJCCameraViewController alloc] init];
    vc.isAllowEditing = NO;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)buttonNewclicked:(UIButton *)button{
    
}

#pragma mark - ZJCCameraViewControllerDelegate
- (void)imagePickerDidCancel:(ZJCCameraViewController *)pickerViewConroller{
    
}

- (void)imagePicker:(ZJCCameraViewController *)pickerViewController didFinishi:(UIImage *)editedImage{
    self.imageView.image = editedImage;
}

#pragma mark - 断续下载
- (void)downloadImageFromUrl{
    NSURL * url = [NSURL URLWithString:@""];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    request.HTTPMethod = @"GET";
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL{
    
}

@end



