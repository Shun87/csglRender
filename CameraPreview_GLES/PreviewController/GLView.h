//
//  GLView.h
//  PreviewController
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 Crearo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>

#import "Render.h"

@interface GLView : UIView
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
    
    Render *_render;
}

- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer;

@end
