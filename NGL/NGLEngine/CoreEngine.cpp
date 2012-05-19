//
//  CoreEngine.cpp
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#include "CoreEngine.h"
#include <stdio.h>
#include <assert.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

static CoreEngine *pEngine = NULL;

CoreEngine::CoreEngine(int nWidth, int nHeight)
{

}

CoreEngine::~CoreEngine()
{
    
}

CoreEngine *CoreEngine::Creat(int nWidth, int nHeight)
{
    if (pEngine == NULL)
    {
        pEngine = new CoreEngine(nWidth, nHeight);
        assert(pEngine != NULL);
    }
    
    return pEngine;
}

void CoreEngine::Draw()
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
}

