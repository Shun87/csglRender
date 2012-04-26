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
#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <QuartzCore/CAEAGLLayer.h>

@interface Render : NSObject
{
    int renderBufferWidth;
    int renderBufferHeight;
    
    CVOpenGLESTextureCacheRef videoTextureCache;
    
    EAGLContext *glContext;
    GLuint frameBuffer;
    GLuint colorRenderBuffer;
    GLuint program;
    
    GLuint yTexture;
    GLuint uvTexture;
    
     CAEAGLLayer *_layer;
    
    CVPixelBufferRef imageBuffer;
}
- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer;
- (id)initWithLayer:(CAEAGLLayer *)layer;
- (void)resize;
- (BOOL)initializeBuffers;
- (const GLchar *)readFile:(NSString *)name;
@end
