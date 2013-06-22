#import <opencv2/highgui/cap_ios.h>

@protocol CvVideoCameraDelegateMod <CvVideoCameraDelegate>
@end

@interface CvVideoCameraMod : CvVideoCamera

- (void)updateOrientation;
- (void)layoutPreviewLayer;

@property (nonatomic, retain) CALayer *customPreviewLayer;

@end