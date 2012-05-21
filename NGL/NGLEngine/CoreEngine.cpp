//
//  CoreEngine.cpp
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#include "NGL.h"
char fragment[] = 
"varying lowp vec4 color;\n"

"void main( void ) {\n"

"gl_FragColor = color;}\n";

char vertext[] = 
"uniform mediump mat4 MODELVIEWPROJECTIONMATRIX;\n"

"attribute mediump vec4 POSITION;\n"

"attribute lowp vec4 COLOR;\n"

"varying lowp vec4 color;\n"

"void main( void ) {\n"

"	gl_Position =  POSITION;\n"

"	color = COLOR;\n}";
static CoreEngine *pEngine = NULL;
NGLProgram *program;
CoreEngine::CoreEngine(int nWidth, int nHeight)
{
    glViewport( 0.0f, 0.0f, nWidth, nHeight );
    
    Start();
}

CoreEngine::~CoreEngine()
{
    
}


void CoreEngine::Start()
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    program = new NGLProgram(vertext, fragment);
    program->CreatProgram();
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
    static const float POSITION[ 8 ] = {
        -1.0f, -1.0f, // Down left (pivot point)
        1.0f, -1.0f, // Up left
        -1.0f, 1.0f, // Down right
        1.0f, 1.0f  // Up right 
	};
	
	static const float COLOR[ 16 ] = {
        1.0f, 0.0f, 0.0f, 1.0f, // Red
        0.0f, 1.0f, 0.0f, 1.0f, // Green
        0.0f, 0.0f, 1.0f, 1.0f, // Blue
        1.0f, 1.0f, 0.0f, 1.0f  // Yellow
	};	
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(program->GetProgramID());
    
    char attribute = 0;
    char uniform = 0;
    attribute = program->GetVertexAttribLocation(( char * )"POSITION" );
    
    glEnableVertexAttribArray( attribute );
    
    glVertexAttribPointer( attribute, 2, GL_FLOAT, GL_FALSE, 0, POSITION );
    
    attribute = program->GetVertexAttribLocation(( char * )"COLOR" );
    
    glEnableVertexAttribArray( attribute );
    
    glVertexAttribPointer( attribute, 4, GL_FLOAT, GL_FALSE, 0, COLOR );
    
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
}


