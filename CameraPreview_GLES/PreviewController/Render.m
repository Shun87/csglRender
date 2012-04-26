//
//  Render.m
//  PreviewController
//
//  Created by  on 12-3-24.
//  Copyright (c) 2012年 Crearo. All rights reserved.
//

#import "Render.h"
#import "ShaderUtilities.h"

@implementation Render

//#ifdef __IPHONE_5_0
#define TextureFastUpload   0
//#endif
//

enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITION,
    NUM_ATTRIBUTES
};

enum {
    UNIFORM_Y,
    UNIFORM_UV,
    NUM_UNIFORMS
};

// attributes
GLint attribLocation[NUM_ATTRIBUTES] = {
    ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITION,  
};

GLint uniformLocation[NUM_UNIFORMS] = {
    UNIFORM_Y, UNIFORM_UV,
};

- (id)initWithLayer:(CAEAGLLayer *)layer
{
    if (self = [super init])
    {
        _layer = layer;
        
        glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!glContext || ![EAGLContext setCurrentContext:glContext]) {
            NSLog(@"Problem with OpenGL context.");
        }
        
        [self initializeBuffers];
    }
    
    return self;
}

- (void)resize
{
    
}

- (const GLchar *)readFile:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:path 
                                                                encoding:NSUTF8StringEncoding 
                                                                   error:nil]UTF8String];
    return source;
}

- (BOOL)initializeBuffers
{
    BOOL success = YES;
    
    glDisable(GL_DEPTH_TEST);
    
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenRenderbuffers(1, &colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [glContext renderbufferStorage:GL_RENDERBUFFER 
                      fromDrawable:_layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderBufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderBufferHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, colorRenderBuffer);
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failure with framebuffer generation");
		success = NO;
	}
    
//#ifdef __IPHONE_5_0
    
    // creat a new CVOpenGLESTexture cache;
    CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, glContext,
                                                  NULL, &videoTextureCache);
    if (error)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", error);
        success = NO;
    }
    
//#else
//#endif
    
    //    // load vertex and shaders
    const GLchar *vertSrc = [self readFile:@"process.vsh"];
    const GLchar *fragSrc = [self readFile:@"process.fsh"];

    // 字符串数组
    GLchar *attribName[NUM_ATTRIBUTES] = {
        "position", "textureCoordinate",  
    };
    
    GLchar *uniformName[NUM_UNIFORMS] = {
        "SamplerY", "SamplerUV",  
    };
    
    glueCreateProgram(vertSrc, fragSrc,
                      NUM_ATTRIBUTES, (const GLchar **)&attribName, attribLocation,
                      NUM_UNIFORMS, (const GLchar **)&uniformName, uniformLocation, &program);
    if (!program)
    {
        success = NO;
    }
    
    return success;
}

- (void)renderWithSquareVertices:(const GLfloat*)squareVertices textureVertices:(const GLfloat*)textureVertices
{
    // Use shader program.
    glUseProgram(program);
    
    // Update attribute values.
	glVertexAttribPointer(attribLocation[ATTRIB_VERTEX], 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(attribLocation[ATTRIB_VERTEX]);
	glVertexAttribPointer(attribLocation[ATTRIB_TEXTUREPOSITION], 2, GL_FLOAT, 0, 0, textureVertices);
	glEnableVertexAttribArray(attribLocation[ATTRIB_TEXTUREPOSITION]);
    
    // Update uniform values if there are any
    
    // 0 ==> GL_TEXTURE0
    // 1 ==> GL_TEXTURE1
	glUniform1i(uniformLocation[UNIFORM_Y], 0);	
    glUniform1i(uniformLocation[UNIFORM_UV], 1);
    
    // 
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // Present
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    [glContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (CGRect)textureSamplingRectForCroppingTextureWithAspectRatio:(CGSize)textureAspectRatio toAspectRatio:(CGSize)croppingAspectRatio
{
	CGRect normalizedSamplingRect = CGRectZero;	
	CGSize cropScaleAmount = CGSizeMake(croppingAspectRatio.width / textureAspectRatio.width, croppingAspectRatio.height / textureAspectRatio.height);
	CGFloat maxScale = fmax(cropScaleAmount.width, cropScaleAmount.height);
	CGSize scaledTextureSize = CGSizeMake(textureAspectRatio.width * maxScale, textureAspectRatio.height * maxScale);
	
	if ( cropScaleAmount.height > cropScaleAmount.width ) {
		normalizedSamplingRect.size.width = croppingAspectRatio.width / scaledTextureSize.width;
		normalizedSamplingRect.size.height = 1.0;
	}
	else {
		normalizedSamplingRect.size.height = croppingAspectRatio.height / scaledTextureSize.height;
		normalizedSamplingRect.size.width = 1.0;
	}
	// Center crop
	normalizedSamplingRect.origin.x = (1.0 - normalizedSamplingRect.size.width)/2.0;
	normalizedSamplingRect.origin.y = (1.0 - normalizedSamplingRect.size.height)/2.0;
	
	return normalizedSamplingRect;
}

- (CVImageBufferRef)creatPixelBuffer:(CVImageBufferRef)pixelBuffer
{
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    unsigned char *YUV[2] = {0};
    
    // y
    YUV[0] = (unsigned char *)malloc(width * height);
    assert(YUV[0] != NULL);
    memset(YUV[0], 0, width*height);
  
    void *base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t byte = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    memcpy(YUV[0], base, width*height);
    
   
    
    // uv
    int uv_height = height/2;
    int uv_width = width/2;
    size_t byte2 = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    YUV[1] = (unsigned char *)malloc(byte2 * uv_height);
    assert(YUV[1] != NULL);
    memset(YUV[1], 0, byte2*uv_height);
    memcpy(YUV[1], base, byte2*uv_height);
    
    
//    size_t planeWidth[2] = {width, uv_width};
//    size_t planeHeight[2] = {height, uv_height};
//    size_t planeBytesPerRow[2] = {byte2, byte2};

    size_t planeWidth[2] = {CVPixelBufferGetWidthOfPlane(pixelBuffer, 0), CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)};
    size_t planeHeight[2] = {CVPixelBufferGetHeightOfPlane(pixelBuffer, 0), CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)};
    size_t planeBytesPerRow[2] = {CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0), CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1)};
    unsigned char *YUV2[2] = {0};
    YUV2[0] = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    YUV2[1] = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    CVReturn renturn = CVPixelBufferCreateWithPlanarBytes(kCFAllocatorDefault,
                                                          width, 
                                                          height,
                                                          kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, 
                                                          nil,
                                                          0,
                                                          2, 
                                                          (void *)YUV2,
                                                          planeWidth,
                                                          planeHeight, 
                                                          planeBytesPerRow, 
                                                          nil,
                                                          nil, nil, &imageBuffer);
    
    // Periodic texture cache flush every frame
    
    // The Buffer cannot be used with OpenGL as either its size, pixelformat or attributes are not supported by OpenGL
    glActiveTexture(GL_TEXTURE0);
    CVOpenGLESTextureRef texture = NULL;
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
                                                                videoTextureCache,
                                                                imageBuffer,
                                                                NULL,
                                                                GL_TEXTURE_2D,
                                                                GL_LUMINANCE,
                                                                width,
                                                                height,
                                                                GL_LUMINANCE,
                                                                GL_UNSIGNED_BYTE,
                                                                0,
                                                                &texture);
    
    if (!texture || err) {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);  
        return;
    }
    CVOpenGLESTextureCacheFlush(videoTextureCache, 0);
   // free(YUV[0]);
    //free(YUV[1]);
    
    return imageBuffer;
}

- (void)uploadTexture:(GLuint *)texture pixelBuffer:(CVImageBufferRef)pixelBuffer plane:(NSInteger)index
{
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    GLuint type = GL_LUMINANCE;
    if (index == 1)
    {
        type = GL_LUMINANCE_ALPHA;
        width = width/2;
        height = height/2;
    }
    
    if (*texture == 0)
    {
        glGenTextures(1, texture);
        glBindTexture(GL_TEXTURE_2D, *texture);
        glTexImage2D(GL_TEXTURE_2D, 0, type, width, height, 0, type, GL_UNSIGNED_BYTE, 0);
    }
    
    glBindTexture(GL_TEXTURE_2D, *texture);
    if (index == 0)
    {
        unsigned char *yData = (unsigned char *)malloc(width * height);
        assert(yData != NULL);
        memset(yData, 0, width*height);
        size_t byte = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        void *base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        if (byte == width)
        {
            memcpy(yData, base, width*height);
        }
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, type, GL_UNSIGNED_BYTE, yData);
        free(yData);
    }
    else
    {
        void *base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        size_t byte = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        unsigned char *yData = (unsigned char *)malloc(byte * height);
        assert(yData != NULL);
        memset(yData, 0, byte*height);
        memcpy(yData, base, byte*height);
        
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, type, GL_UNSIGNED_BYTE, yData);
        free(yData);
    }
    
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	// This is necessary for non-power-of-two textures
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)displayPixelBuffer:(CVImageBufferRef)pixelBuffer
{    
    
    if (videoTextureCache == NULL)
    {
        return;
    }
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
#if TextureFastUpload
    
    // Creat a CVOpenGLLESTexture from the CVImageBuffer
    CVOpenGLESTextureRef texture = NULL;
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                videoTextureCache,
                                                                pixelBuffer,
                                                                NULL,
                                                                GL_TEXTURE_2D,
                                                                GL_RGBA,
                                                                width,
                                                                height,
                                                                GL_BGRA,
                                                                GL_UNSIGNED_BYTE,
                                                                0, &texture);
    
    
    if (!texture || err) {
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);  
        return;
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture));
    
    // Set texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
#else
    
    // Retrieving the base address for a PixelBuffer requires that the buffer base address be locked
    // via a successful call to CVPixelBufferLockBaseAddress.
    CVReturn sucess = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if (sucess != kCVReturnSuccess)
    {
        return;
    }
    
    [self uploadTexture:&yTexture pixelBuffer:pixelBuffer plane:0];
    
    [self uploadTexture:&uvTexture pixelBuffer:pixelBuffer plane:1];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, yTexture);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, uvTexture);
//    
#endif
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    // Set the view port to the entire view
    glViewport(0, 0, renderBufferWidth, renderBufferHeight);
	
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    static const GLfloat textureVertices3[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        0.0f,  0.0f,
    };
    
    // The texture vertices are set up such that we flip the texture vertically.
	// This is so that our top left origin buffers match OpenGL's bottom left texture coordinate system.
    //	CGRect textureSamplingRect = [self textureSamplingRectForCroppingTextureWithAspectRatio:CGSizeMake(width, height) toAspectRatio:self.bounds.size];
    //	GLfloat textureVertices[] = {
    //		CGRectGetMinX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
    //		CGRectGetMaxX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
    //		CGRectGetMinX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
    //		CGRectGetMaxX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
    //	};
	
    // Draw the texture on the screen with OpenGL ES 2
    [self renderWithSquareVertices:squareVertices textureVertices:textureVertices3];
    
#if TextureFastUpload
    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), 0);
    
    // Flush the CVOpenGLESTexture cache and release the texture
    CVOpenGLESTextureCacheFlush(videoTextureCache, 0);
    CFRelease(texture);
    
#else
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
#endif
    
}
//Your code doesn't look to0 bad. I can see two mistakes and one potential problem:

//The uvPixelCount is incorrect. The YUV 420 format means that there is color information for each 2 by 2 pixel block.
// So the correct count is:
//
//uvPixelCount = (width / 2) * (height / 2);
//You write something about yPixelCount / 4, but I cannot see that in your code.
//
//The UV information is interleaved, i.e. the second plane alternatingly contains a U and a V value.

// Or put differently: there's a U value on all even byte addresses and a V value on all odd byte addresses.
// If you really need to separate the U and V information, memcpy won't do.
//
//There can be some extra bytes after each pixel row. 
// You should use CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0) to get the number of bytes between two rows. 
//As a consequence, a single memcpy won't do. 
//Instead you need to copy each pixel row separately to get rid of the extra bytes between the rows.
//
//All these things only explain part of the resulting image. 
//The remaining parts are probably due to differences between your code and what the receiving peer expect.
////You did't write anything about that? Does the peer really need separated U and V values? 
//Does it you 4:2:0 compression as well? Does it you video range instead of full range as well?



//Turning the biplanar image format into a planar is simply: just copy the two planes into a single memory block. 
//The planar format is just the concatenation of the luma and the chroma plane. 
//But I'm still not sure what target format you need: YUV420 is simply not a precise description. 
//And while I've given you a lot of information about image formats, I've the impression you in fact need a video format. Please post as much details about the target format as possible
// "420v" (fourcc: NV12) is a bi-planar format while 420p is planar
// The VideoRange or FullRange suffix simply indicates whether the bytes are returned between 16 - 235 for Y 
//and 16 - 240 for UV or full 0 - 255 for each component.


//I believe the default colorspace used by an AVCaptureVideoDataOutput instance is the YUV 4:2:0 planar colorspace
//(except on the iPhone 3G, where it's YUV 4:2:2 interleaved). 
//This means that there are two planes of image data contained within the video frame, 
//with the Y plane coming first. For every pixel in your resulting image, there is one byte for the Y value at that pixel.


//A row in the image might be longer than the width of the image (due to rounding). 
//That's why there are separate functions for getting the width and the number of bytes per row. 
//You don't have this problem at the moment. But that might change with the next version of iOS. So your code should be:
//#pragma mark -
//#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate Methods
//#if !(TARGET_IPHONE_SIMULATOR)
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
//{
//    // get image buffer reference
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    
//    // extract needed informations from image buffer
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
//    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//    CGSize resolution = CGSizeMake(CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer));
//    
//    // variables for grayscaleBuffer 
//    void *grayscaleBuffer = 0;
//    size_t grayscaleBufferSize = 0;
//    
//    // the pixelFormat differs between iPhone 3G and later models
//    OSType pixelFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
//    
//    if (pixelFormat == '2vuy') { // iPhone 3G
//        // kCVPixelFormatType_422YpCbCr8     = '2vuy',    
//        /* Component Y'CbCr 8-bit 4:2:2, ordered Cb Y'0 Cr Y'1 */
//        
//        // copy every second byte (luminance bytes form Y-channel) to new buffer
//        grayscaleBufferSize = bufferSize/2;
//        grayscaleBuffer = malloc(grayscaleBufferSize);
//        if (grayscaleBuffer == NULL) {
//            NSLog(@"ERROR in %@:%@:%d: couldn't allocate memory for grayscaleBuffer!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
//            return nil; }
//        memset(grayscaleBuffer, 0, grayscaleBufferSize);
//        void *sourceMemPos = baseAddress + 1;
//        void *destinationMemPos = grayscaleBuffer;
//        void *destinationEnd = grayscaleBuffer + grayscaleBufferSize;
//        while (destinationMemPos <= destinationEnd) {
//            memcpy(destinationMemPos, sourceMemPos, 1);
//            destinationMemPos += 1;
//            sourceMemPos += 2;
//        }       
//    }
//    
//    if (pixelFormat == '420v' || pixelFormat == '420f') {
//        // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange = '420v', 
//        // kCVPixelFormatType_420YpCbCr8BiPlanarFullRange  = '420f',
//        // Bi-Planar Component Y'CbCr 8-bit 4:2:0, video-range (luma=[16,235] chroma=[16,240]).  
//        // Bi-Planar Component Y'CbCr 8-bit 4:2:0, full-range (luma=[0,255] chroma=[1,255]).
//        // baseAddress points to a big-endian CVPlanarPixelBufferInfo_YCbCrBiPlanar struct
//        // i.e.: Y-channel in this format is in the first third of the buffer!
//        int bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
//        grayscaleBufferSize = resolution.height * bytesPerRow ;
//        grayscaleBuffer = malloc(grayscaleBufferSize);
//        if (grayscaleBuffer == NULL) {
//            NSLog(@"ERROR in %@:%@:%d: couldn't allocate memory for grayscaleBuffer!", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
//            return nil; }
//        memset(grayscaleBuffer, 0, grayscaleBufferSize);
//        memcpy (grayscaleBuffer, baseAddress, grayscaleBufferSize); 
//    }
//    
//    // do whatever you want with the grayscale buffer
//    ...
//    
//    // clean-up
//    free(grayscaleBuffer);
//}
//#endif
@end
