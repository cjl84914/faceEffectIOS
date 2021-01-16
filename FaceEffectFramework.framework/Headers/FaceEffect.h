#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

@class FaceEffect;

@protocol AIVideoDelegate <NSObject>
- (void) streamCallback: (FaceEffect*)faceEffect didOutputPixelBuffer: (CVPixelBufferRef)pixelBuffer;
@end

@interface FaceEffect : NSObject
    - (instancetype)init:(NSString*) kGraphName;
    - (void)startGraph;
    - (void)processVideoFrame:(CVPixelBufferRef)imageBuffer :(CMTime)timestamp;  // Must be invoked on _videoQueue.
    - (void)close;
@property (weak, nonatomic) id <AIVideoDelegate> delegate;
@end
