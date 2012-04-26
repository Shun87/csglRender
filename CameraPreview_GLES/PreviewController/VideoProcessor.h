//
//  VideoProcessor.h
//  PreviewController
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 Crearo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMBufferQueue.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoProcessorDelegate;
@interface VideoProcessor : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *captureSession;
    AVCaptureConnection *videoConnection;
    
    CMVideoDimensions videoDimensions;
    CMBufferQueueRef previewBufferQueue;
    id<VideoProcessorDelegate> delegate;
}
@property (readwrite, assign) id<VideoProcessorDelegate> delegate;
- (void)setupAndStartCaptureSession;
- (void) showError:(NSError*)error;
@end

@protocol VideoProcessorDelegate <NSObject>
@required
- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
@end
