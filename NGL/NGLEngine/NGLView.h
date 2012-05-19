//
//  NGLView.h
//  
//
//  Created by chenshun on 12-5-18.
//  Copyright 2012年 chenshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
@interface NGLView : UIView
{
    EAGLContext *glContext;
    GLuint frameBuffer;
    GLuint colorRenderBuffer;
    GLuint depthRenderbuffer;
    
    int renderBufferWidth;
    int renderBufferHeight;
}

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;
@end
