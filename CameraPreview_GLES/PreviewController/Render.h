//
//  Render.h
//  PreviewController
//
//  Created by  on 12-3-24.
//  Copyright (c) 2012年 Crearo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/CAEAGLLayer.h>

#define TextureFastUpload   0

#if TextureFastUpload
#import <CoreVideo/CVOpenGLESTextureCache.h>
#endif    

@interface Render : NSObject
{
    int renderBufferWidth;
    int renderBufferHeight;
    
    EAGLContext *glContext;
    GLuint frameBuffer;
    GLuint colorRenderBuffer;
    GLuint program;
    
    GLuint yTexture;
    GLuint uvTexture;
    
    CAEAGLLayer *_layer;
    
    CVPixelBufferRef imageBuffer;
    
#if TextureFastUpload
    CVOpenGLESTextureCache *videoTextureCache
#endif    
    
}
- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer;
- (id)initWithLayer:(CAEAGLLayer *)layer;
- (void)resize;
- (BOOL)initializeBuffers;
- (const GLchar *)readFile:(NSString *)name;
@end
