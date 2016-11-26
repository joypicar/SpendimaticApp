//
//  ScannerViewController.m
//  spendimatic
//
//  Created by LF-Mac-Air on 26/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "ScannerViewController.h"

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIScrollViewDelegate>

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

@property (nonatomic, strong) NSUserDefaults *prefs;

@property (nonatomic, strong) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) UIView *cameraContainerView;
@property (nonatomic, strong) UIView *successFlashView;
@property (nonatomic, strong) UIView *failedFlashView;
@property (strong, nonatomic) UILabel *scanningStatusLabel;

@property (nonatomic, strong) UIScrollView *dataLogsScrollView;

@property (nonatomic) BOOL isReading;
@property (nonatomic) BOOL pauseInterval;
@property (nonatomic, strong) NSTimer *pauseTimer;

@property (nonatomic, strong) NSMutableArray *dataLogsMutableArray;

@property (nonatomic, strong) NSString *qrCodeId;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    [self initScannerLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth = self.view.frame.size.width;
    _screenHeight = self.view.frame.size.height;
    
    _prefs = [NSUserDefaults standardUserDefaults];
    
    _isReading = NO;
    
    _captureSession = nil;
    
    _qrCodeId = @"";
}

-(void)initScannerLayout{
    
    _cameraContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    _cameraContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_cameraContainerView];
    
    // To be remove
    /*
    UIView *scanTopBarView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenYOffSet, _screenWidth, _screenYOffSet - 20)];
    scanTopBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:scanTopBarView];
    
    UILabel *minusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 18, 10)];
    //minusLabel.backgroundColor = [UIColor greenColor];
    minusLabel.text = @"-";
    minusLabel.textAlignment = NSTextAlignmentCenter;
    minusLabel.font = [UIFont systemFontOfSize:30];
    minusLabel.textColor = [UIColor whiteColor];
    [minusLabel sizeToFit];
    [scanTopBarView addSubview:minusLabel];
    
    CGRect frame = CGRectMake(minusLabel.frame.origin.x + minusLabel.frame.size.width + 5, minusLabel.frame.origin.y + (minusLabel.frame.size.height / 2), scanTopBarView.frame.size.width - 140, 10.0);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    //[slider setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.5]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    slider.continuous = YES;
    slider.value = 0.0;
    [slider setThumbImage:[UIImage imageNamed:@"slider-thumb"] forState:UIControlStateNormal];
    [scanTopBarView addSubview:slider];
    
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *plusLabel = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.origin.x + slider.frame.size.width + 5, 0, 18, 10)];
    //plusLabel.backgroundColor = [UIColor greenColor];
    plusLabel.text = @"+";
    plusLabel.font = [UIFont systemFontOfSize:30];
    plusLabel.textColor = [UIColor whiteColor];
    [plusLabel sizeToFit];
    [scanTopBarView addSubview:plusLabel];
    */
    
    _dataLogsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _screenHeight - (_screenHeight / 4), _cameraContainerView.frame.size.width, _screenHeight / 4)];
    _dataLogsScrollView.delegate = self;
    _dataLogsScrollView.layer.cornerRadius = _cameraContainerView.layer.cornerRadius;
    _dataLogsScrollView.contentSize = CGSizeMake(_dataLogsScrollView.frame.size.width, _dataLogsScrollView.frame.size.height * 2);
    _dataLogsScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_dataLogsScrollView];
    
    _dataLogsMutableArray = [_prefs mutableArrayValueForKey:@"datalogs"];
    
    if(_dataLogsMutableArray.count == 0){
        
        _dataLogsMutableArray = [[NSMutableArray alloc] init];
    }else{
        
        for (int i = 0; i < _dataLogsMutableArray.count; i++) {
            
            [self scanningLogs:[NSString stringWithFormat:@"%@",[_dataLogsMutableArray objectAtIndex:i]] row:i];
        }
    }
    
    NSLog(@"Load logs : -> %@", _dataLogsMutableArray);
    
    _scanningStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _cameraContainerView.frame.size.width, 20)];
    //_scanningStatusLabel.backgroundColor = [UIColor blackColor];
    _scanningStatusLabel.textColor = [UIColor greenColor];
    _scanningStatusLabel.font = [UIFont systemFontOfSize:12];
    
    [self startStopReading];
}


- (void)startStopReading{
    NSLog(@"start/stop");
    
    if (!_isReading) {
        
        if ([self startReading]) {
            
            [_scanningStatusLabel setText:@"Scanning QR code..."];
            
            NSLog(@"Start scanning");
        }
    }else{
        
        [self stopReading];
        [_scanningStatusLabel setText:@"SCAN OFF"];
        
        NSLog(@"Stop scanning");
    }
    
    _isReading = !_isReading;
}

- (BOOL)startReading {
    
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //NSLog(@"All formats: %@", captureDevice.formats);
    //NSLog(@"active format: :%@", captureDevice.activeFormat);
    
    // Zoom config
    /*
    if ([captureDevice lockForConfiguration:&error]) {
        captureDevice.activeFormat = [captureDevice.formats lastObject];
        [captureDevice setVideoZoomFactor:1.0];
        [captureDevice unlockForConfiguration];
        NSLog(@"ZoomFactor = %f",captureDevice.videoZoomFactor);
        NSLog(@"active format: :%@", captureDevice.activeFormat);
        NSLog(@"fov : %f",captureDevice.activeFormat.videoFieldOfView);
    } else {
        NSLog(@"error: %@", error);
    }
    */
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"AVCaptureDeviceInput : %@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setFrame:_cameraContainerView.layer.bounds];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_cameraContainerView.layer addSublayer:_videoPreviewLayer];
    
    [_videoPreviewLayer addSublayer:_scanningStatusLabel.layer];
    
    _successFlashView = [[UIView alloc] initWithFrame:_videoPreviewLayer.frame];
    _successFlashView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    _successFlashView.layer.cornerRadius = _videoPreviewLayer.cornerRadius;
    _successFlashView.userInteractionEnabled = NO;
    _successFlashView.hidden = YES;
    [_cameraContainerView.layer addSublayer:_successFlashView.layer];
    
    _failedFlashView = [[UIView alloc] initWithFrame:_successFlashView.frame];
    _failedFlashView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    _failedFlashView.layer.cornerRadius = _successFlashView.layer.cornerRadius;
    _failedFlashView.userInteractionEnabled = NO;
    _failedFlashView.hidden = YES;
    [_cameraContainerView.layer addSublayer:_failedFlashView.layer];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] && !_pauseInterval) {
            
            [_scanningStatusLabel performSelectorOnMainThread:@selector(setText:) withObject:@"Processing QR code..." waitUntilDone:NO];
            
            //[_scanningStatusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSMutableArray *qrCodeDataArray = [[NSMutableArray alloc] init];
            [qrCodeDataArray addObject:[dateFormatter stringFromDate:[NSDate date]]];
            [qrCodeDataArray addObject:[metadataObj stringValue]];
            
            NSLog(@"QR code object : %@", [metadataObj stringValue]);
            
            if([[metadataObj stringValue] isEqualToString:_qrCodeId]){
                
                [qrCodeDataArray addObject:@"verify"];
                [self performSelectorOnMainThread:@selector(successVerify:) withObject:qrCodeDataArray waitUntilDone:NO];
            }else{
                [qrCodeDataArray addObject:@"decline"];
                [self performSelectorOnMainThread:@selector(failedVerify:) withObject:qrCodeDataArray waitUntilDone:NO];
            }
            
            [_dataLogsMutableArray addObject:[[qrCodeDataArray valueForKey:@"description"] componentsJoinedByString:@"|"] ];
            
            //NSLog(@"all data logs : %@",_dataLogsMutableArray);
            
            [self performSelectorOnMainThread:@selector(pauseReading) withObject:nil waitUntilDone:NO];
        }
    }
}

-(void)stopReading{
    
    [_captureSession stopRunning];
    
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
    
    [_pauseTimer invalidate];
    
    _pauseTimer = nil;
}

-(void)pauseReading{
    
    _pauseInterval = YES;
    
    _pauseTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                   target:self
                                                 selector:@selector(resumeReading)
                                                 userInfo:nil
                                                  repeats:YES];
}

-(void)resumeReading{
    
    _scanningStatusLabel.text = @"Scanning QR code...";
    
    _pauseInterval = NO;
    
    [_pauseTimer invalidate];
    
    _pauseTimer = nil;
}

-(void)successVerify:(NSMutableArray*)qrCodeData{
    
    _successFlashView.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         _successFlashView.backgroundColor = [_successFlashView.backgroundColor colorWithAlphaComponent:0.0];
                         
                     }completion:^(BOOL finished){
                         
                         if(finished){
                             
                             _successFlashView.hidden = YES;
                             _successFlashView.backgroundColor = [_successFlashView.backgroundColor colorWithAlphaComponent:0.5];
                             
                             [self scanningLogs:[[qrCodeData valueForKey:@"description"] componentsJoinedByString:@"|"] row:(int)_dataLogsMutableArray.count - 1];
                         }
                     }];
}

-(void)failedVerify:(NSMutableArray*)qrCodeData{
    
    _failedFlashView.hidden = NO;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         _failedFlashView.backgroundColor = [_failedFlashView.backgroundColor colorWithAlphaComponent:0.0];
                         
                     }completion:^(BOOL finished){
                         
                         if(finished){
                             
                             _failedFlashView.hidden = YES;
                             _failedFlashView.backgroundColor = [_failedFlashView.backgroundColor colorWithAlphaComponent:0.5];
                             
                             [self scanningLogs:[[qrCodeData valueForKey:@"description"] componentsJoinedByString:@"|"] row:(int)_dataLogsMutableArray.count - 1];
                         }
                     }];
}

-(void)scanningLogs:(NSString*)param row:(int)row{
    
    NSLog(@"scanning log param = %@", param);
    
    _dataLogsScrollView.contentSize = CGSizeMake(_dataLogsScrollView.frame.size.width, 15 * (row + 1));
    
    if(_dataLogsScrollView.contentSize.height > _dataLogsScrollView.frame.size.height){
        
        CGPoint scrollDownPoint = CGPointMake(0, _dataLogsScrollView.contentSize.height - _dataLogsScrollView.bounds.size.height);
        
        [_dataLogsScrollView setContentOffset:scrollDownPoint animated:YES];
    }

    UILabel *logLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, row * 15, _dataLogsScrollView.frame.size.width, 15)];
    //logLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    logLabel.textColor = [UIColor whiteColor];
    logLabel.font = [UIFont systemFontOfSize:10];
    logLabel.text = param;
    
    // If we want customize text format/color for verify and decline
    /*
     if([stats isEqualToString:@"verify"]){
     logLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
     }else{
     logLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
     }
     */
    [_dataLogsScrollView addSubview:logLabel];
}

@end
