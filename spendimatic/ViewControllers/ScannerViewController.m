//
//  ScannerViewController.m
//  spendimatic
//
//  Created by LF-Mac-Air on 26/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "ScannerViewController.h"
#import "OrderNoViewController.h"

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

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

@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIView *tabMenuView;
@property (nonatomic, strong) UIView *lowerPanelView;

//@property (nonatomic, strong) UIScrollView *dataLogsScrollView;
@property (nonatomic, strong) UIScrollView *orderLogsScrollView;

@property (nonatomic) BOOL isReading;
@property (nonatomic) BOOL pauseInterval;
@property (nonatomic, strong) NSTimer *pauseTimer;

@property (nonatomic, strong) NSString *qrCodeId;

@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic) NSInteger orderNo;

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
    
    _qrCodeId = @"Unionbank";
}

-(void)initScannerLayout{
    
    _cameraContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    _cameraContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_cameraContainerView];
    
    NSLog(@"Load logs : -> %@", _orderLogsMutableArray);
    
    _scanningStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _cameraContainerView.frame.size.width, 20)];
    //_scanningStatusLabel.backgroundColor = [UIColor blackColor];
    _scanningStatusLabel.textColor = [UIColor greenColor];
    _scanningStatusLabel.font = [UIFont systemFontOfSize:12];
    
    _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight / 8)];
    _bannerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_bannerView];
    
    _tabMenuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _bannerView.frame.origin.y + _bannerView.frame.size.height, _screenWidth, 50)];
    _tabMenuView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_tabMenuView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_McDo"]];
    //logoImageView.backgroundColor = [UIColor lightGrayColor];
    logoImageView.frame = CGRectMake((_bannerView.frame.size.width / 2) - ((_bannerView.frame.size.height - 30) / 2), 20, _bannerView.frame.size.height - 30, _bannerView.frame.size.height - 30);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.clipsToBounds = YES;
    [_bannerView addSubview:logoImageView];
    
    UIImageView *spendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_spendimatic"]];
    //logoImageView.backgroundColor = [UIColor lightGrayColor];
    spendImageView.frame = CGRectMake((_tabMenuView.frame.size.width / 2) - 100, 0, 200, _tabMenuView.frame.size.height);
    spendImageView.contentMode = UIViewContentModeScaleAspectFit;
    spendImageView.clipsToBounds = YES;
    [_tabMenuView addSubview:spendImageView];
    
    [self initLowerPanel];
    
    [self startStopReading];
}

-(void)initLowerPanel{
    
    _lowerPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight - 150, _screenWidth, 150)];
    _lowerPanelView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_lowerPanelView];
    
    UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    //quantityLabel.backgroundColor = [UIColor greenColor];
    quantityLabel.text = @"QTY";
    quantityLabel.textColor = [UIColor whiteColor];
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:quantityLabel];
    
    UILabel *yourOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(quantityLabel.frame.size.width, 0, _screenWidth - (_screenWidth / 3), 40)];
    //yourOrderLabel.backgroundColor = [UIColor orangeColor];
    yourOrderLabel.text = @"Your Order";
    yourOrderLabel.textColor = [UIColor whiteColor];
    yourOrderLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:yourOrderLabel];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(yourOrderLabel.frame.origin.x + yourOrderLabel.frame.size.width, 0, 60, 40)];
    //priceLabel.backgroundColor = [UIColor blueColor];
    priceLabel.text = @"Price";
    priceLabel.textColor = [UIColor whiteColor];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:priceLabel];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabel.frame.origin.x + priceLabel.frame.size.width, 0, _lowerPanelView.frame.size.width - (priceLabel.frame.origin.x + priceLabel.frame.size.width), _lowerPanelView.frame.size.height / 2)];
    //totalLabel.backgroundColor = [UIColor lightGrayColor];
    _totalLabel.text = [NSString stringWithFormat:@"Total Price\nP %li",(long)_totalPrice];
    _totalLabel.numberOfLines = 0;
    _totalLabel.textColor = [UIColor whiteColor];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:_totalLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(_totalLabel.frame.origin.x + 10, _totalLabel.frame.size.height, _totalLabel.frame.size.width - 20, _totalLabel.frame.size.height / 2);
    cancelButton.backgroundColor = [UIColor yellowColor];
    cancelButton.layer.cornerRadius = 5;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_lowerPanelView addSubview:cancelButton];
    
    [cancelButton addTarget:self action:@selector(cancelEvent) forControlEvents:UIControlEventTouchUpInside];
    
    _orderLogsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, quantityLabel.frame.size.height, _lowerPanelView.frame.size.width - _totalLabel.frame.size.width, _lowerPanelView.frame.size.height - quantityLabel.frame.size.height - 5)];
    _orderLogsScrollView.delegate = self;
    //_orderLogsScrollView.layer.cornerRadius = _cameraContainerView.layer.cornerRadius;
    _orderLogsScrollView.contentSize = CGSizeMake(_orderLogsScrollView.frame.size.width, _orderLogsScrollView.frame.size.height);
    //_orderLogsScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [_lowerPanelView addSubview:_orderLogsScrollView];
    
    for (int i = 0; i < _orderLogsMutableArray.count; i++) {
        
        [self orderLogs:[NSString stringWithFormat:@"%@",[_orderLogsMutableArray objectAtIndex:i]] row:i];
    }
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
            
            [_orderLogsMutableArray addObject:[[qrCodeDataArray valueForKey:@"description"] componentsJoinedByString:@"|"] ];
            
            //NSLog(@"all data logs : %@",_orderLogsMutableArray);
            
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
                             
                             [self transaction:@"101124427073" targetAccount:@"101035020184" amount:[NSString stringWithFormat:@"%ld",(long)_totalPrice]];
                             
                             //[self scanningLogs:[[qrCodeData valueForKey:@"description"] componentsJoinedByString:@"|"] row:(int)_orderLogsMutableArray.count - 1];
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
                             
                             //[self scanningLogs:[[qrCodeData valueForKey:@"description"] componentsJoinedByString:@"|"] row:(int)_orderLogsMutableArray.count - 1];
                         }
                     }];
}

-(void)orderLogs:(NSString*)param row:(int)row{
    
    NSLog(@"order log param = %@", param);
    
    _orderLogsScrollView.contentSize = CGSizeMake(_orderLogsScrollView.frame.size.width, 15 * (row + 1));
    
    if(_orderLogsScrollView.contentSize.height > _orderLogsScrollView.frame.size.height){
        
        CGPoint scrollDownPoint = CGPointMake(0, _orderLogsScrollView.contentSize.height - _orderLogsScrollView.bounds.size.height);
        
        [_orderLogsScrollView setContentOffset:scrollDownPoint animated:YES];
    }
    
    UILabel *logLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, row * 15, _orderLogsScrollView.frame.size.width, 15)];
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
    [_orderLogsScrollView addSubview:logLabel];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(void)transaction:(NSString*)sourceAccount targetAccount:(NSString*)targetAccount amount:(NSString*)amount{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSDictionary *headers = @{ @"accept": @"application/json",
                                   @"content-type": @"application/json",
                                   @"x-ibm-client-id": @"7c695a6c-43e0-409d-ad4e-3f73633db3e2",
                                   @"x-ibm-client-secret": @"rH2rN7sX4yW1eA0rX6mX5wY2gM6gY5tI8iR3lP0jU3vE4bW8aE",
                                   @"cache-control": @"no-cache",
                                   @"postman-token": @"4fba81bb-c709-5a33-e24d-2ee36f2a706c" };
        
        NSString *transactionId = [NSString stringWithFormat:@"%d", [self getRandomNumberBetween:100000 to:999999]];
        
        NSDictionary *parameters = @{ @"channel_id": @"BLUEMIX",
                                      @"transaction_id": transactionId,
                                      @"source_account": sourceAccount,
                                      @"source_currency": @"php",
                                      @"target_account": targetAccount,
                                      @"target_currency": @"php",
                                      @"amount": amount };
        
        NSLog(@"parameters : %@",parameters);
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.us.apiconnect.ibmcloud.com/ubpapi-dev/sb/api/RESTs/transfer"]
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:10.0];
        
        
        [request setHTTPMethod:@"POST"];
        [request setAllHTTPHeaderFields:headers];
        [request setHTTPBody:postData];
        
        __block NSString *message = @"";
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^(void){
                                                            if (error) {
                                                                NSLog(@"%@", error);
                                                                
                                                                message = @"Transaction failed.";
                                                                
                                                            } else {
                                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                NSLog(@"%@", httpResponse);
                                                                
                                                                _orderNo = [self getRandomNumberBetween:1000 to:9999];
                                                                
                                                                message = [NSString stringWithFormat:@"Transaction complete.\nYour order No.%li",(long)_orderNo];
                                                            }
                                                            
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                                                            [alert show];
                                                        });
                                                    }];
        [dataTask resume];
        
    });
}

-(void)cancelEvent{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"alertview");
    
    if(buttonIndex == 0){
        
        UIView *orderNumberView = [[UIView alloc] initWithFrame:_videoPreviewLayer.frame];
        orderNumberView.backgroundColor = [UIColor whiteColor];
        [_cameraContainerView addSubview:orderNumberView];
        
        UILabel *orderNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, orderNumberView.frame.size.width - 80, orderNumberView.frame.size.height - 80)];
        //orderNumberLabel.backgroundColor = [UIColor greenColor];
        orderNumberLabel.text = [NSString stringWithFormat:@"Your order\nNo.%ld",(long)_orderNo];
        orderNumberLabel.font = [UIFont boldSystemFontOfSize:50];
        orderNumberLabel.numberOfLines = 0;
        orderNumberLabel.lineBreakMode = NSLineBreakByWordWrapping;
        orderNumberLabel.textAlignment = NSTextAlignmentCenter;
        [orderNumberView addSubview:orderNumberLabel];
    }
}

@end
