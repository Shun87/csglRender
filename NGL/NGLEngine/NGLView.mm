//
//  NGLView.m
//  
//
//  Created by chenshun on 12-5-18.
//  Copyright 2012年 chenshun. All rights reserved.
//


#import "NGLView.h"
@implementation NGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        CAEAGLLayer *eagllayer = (CAEAGLLayer *)self.layer;
        eagllayer.opaque = YES;
        eagllayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        
        glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!glContext || ![EAGLContext setCurrentContext:glContext])
        {
            NSLog(@"opengl context init failed");
        }
        [self setFramebuffer];
    }
    return self;
}

- (void)creatFramebuffer
{
    if (glContext && !frameBuffer)
    {
        [EAGLContext setCurrentContext:glContext];
        glGenFramebuffers(1, &frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        
        glGenRenderbuffers(1, &colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
        [glContext renderbufferStorage:GL_RENDERBUFFER 
                          fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderBufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderBufferHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                  GL_RENDERBUFFER, colorRenderBuffer);
    
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, renderBufferWidth, renderBufferHeight);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) 
        {
            NSLog(@"Failure with framebuffer generation");
        }
    }
}

- (void)setFramebuffer
{
    if ( glContext )
    {
        [EAGLContext setCurrentContext:glContext];
        
        if ( !frameBuffer )
        {
            [self creatFramebuffer];
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (glContext)
    {
        [EAGLContext setCurrentContext:glContext];
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
        success = [glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

@end
