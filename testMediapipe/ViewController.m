//
//  ViewController.m
//  testMediapipe
//
//  Created by alexcai on 2020/12/21.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "FaceEffect.h"
#import "testMediapipe-Swift.h"

static const char* kVideoQueueLabel = "com.google.mediapipe.example.videoQueue";
@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AIVideoDelegate>
@property (nonatomic) FaceEffect* faceEffect;
@property (nonatomic, strong) AVCaptureSession *session;
@end

@implementation ViewController {
    /// Inform the user when camera is unavailable.
    IBOutlet UILabel *_noCameraLabel;
    /// Inform the user about how to switch between effects.
    UILabel* _effectSwitchingHintLabel;
    /// Display the camera preview frames.
    IBOutlet UIView *liveView;
    dispatch_queue_t _videoQueue;
    AVSampleBufferDisplayLayer* _previewLayer;
}

#pragma mark - Cleanup methods
- (void)dealloc {
    [self.faceEffect close];
}

#pragma mark - UIViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.videoSettings = [NSDictionary dictionaryWithObject:
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                       forKey:(id)kCVPixelBufferPixelFormatTypeKey];
   
    [self.session addInput:input];
    [self.session addOutput:output];
    [output.connections[0] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [output.connections[0] setVideoMirrored:YES];
    
    self.faceEffect = [[FaceEffect alloc] init:@"fighter_face_effect_gpu"];
    [self.faceEffect startGraph];
    self.faceEffect.delegate = self;
    
    dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(
                                                                                 DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, /*relative_priority=*/0);
    _videoQueue = dispatch_queue_create(kVideoQueueLabel, qosAttribute);
    [output setSampleBufferDelegate:self queue:_videoQueue];
    
    _previewLayer = [AVSampleBufferDisplayLayer new];
    _previewLayer.frame = CGRectMake( 0,  0,  480,  640);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [liveView.layer addSublayer :_previewLayer];
    
    dispatch_async(_videoQueue, ^{
        [self.session startRunning];
    });
    
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection{

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    CVPixelBufferRetain(pixelBuffer);
    __weak FaceEffect *weakSelf = self.faceEffect;
    dispatch_async(_videoQueue, ^{
        [weakSelf processVideoFrame:pixelBuffer:timestamp];
        CVPixelBufferRelease(pixelBuffer);
    });
}

- (void)streamCallback:(FaceEffect *)faceEffect didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer{

    CMSampleBufferRef buffer = [PixelBufferUtil changeSampleBufferWithPixelBuffer: pixelBuffer];
    [_previewLayer enqueueSampleBuffer: buffer];
}

@end
