//
//  NGL.h
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#ifndef NGL_Test_NGL_h
#define NGL_Test_NGL_h

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include <assert.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "Vector.h"
#include "Matrix.h"
#include "CoreEngine.h"
#include "NGLProgram.h"

//! The depth of the modelview matrix stack.
#define MAX_MODELVIEW_MATRIX	8

//! The depth of the projection matrix stack.
#define MAX_PROJECTION_MATRIX	2

//! The depth of the texture matrix stack.
#define MAX_TEXTURE_MATRIX		2

enum
{
	//! The modelview matrix identifier.
	MODELVIEW_MATRIX = 0,
    
	//! The projection matrix identifier.
	PROJECTION_MATRIX = 1,
	
	//! The texture matrix identifier.	
	TEXTURE_MATRIX	  = 2
};

//! The definition of the global GFX structure. This structure maintain the matrix stacks and current indexes. 
typedef struct
{
	//! The current matrix mode (either MODELVIEW_MATRIX (default), PROJECTION_MATRIX, TEXTURE_MATRIX).
	unsigned char	matrix_mode;
	
	//! The current modelview matrix index in the stack.
	unsigned char	modelview_matrix_index;
    
	//! The current projection matrix index in the stack.
	unsigned char	projection_matrix_index;
	
	//! The current texture matrix index in the stack.	
	unsigned char	texture_matrix_index;
    
	//! Array of 4x4 matrix that represent the modelview matrix stack.
	mat4			modelview_matrix[ MAX_MODELVIEW_MATRIX ];
    
	//! Array of 4x4 matrix that represent the projection matrix stack.
	mat4			projection_matrix[ MAX_PROJECTION_MATRIX ];
    
	//! Array of 4x4 matrix that represent the texture matrix stack.
	mat4			texture_matrix[ MAX_TEXTURE_MATRIX ];
	
	//! Used to store the result of the modelview matrix multiply by the projection matrix. \sa GFX_get_modelview_projection_matrix
	mat4			modelview_projection_matrix;
	
	//! Used to store the result of the inverse, tranposed modelview matrix. \sa GFX_get_normal_matrix
	mat3			normal_matrix;
    
} NGL;

//! Global GFX structure. Declared as extern in gfx.h and implemented in gfx.cpp
extern NGL ngl;

void NGL_start( void );

void NGL_set_matrix_mode( unsigned int uiMode );

void NGL_load_identity( void );

void NGL_push_matrix( void );

void NGL_pop_matrix( void );

void NGL_load_matrix( void );

void NGL_multiply_matrix( mat4 *m );

void NGL_translate( float x, float y, float z );

void NGL_rotate( float angle, float x, float y, float z );

void NGL_scale( float x, float y, float z );

mat4 *NGL_get_modelview_matrix( void );

mat4 *NGL_get_projection_matrix( void );

mat4 *NGL_get_modelview_projection_matrix( void );

mat4 *NGL_get_texture_matrix( void );

mat4 *NGL_get_normal_matrix( void );

void NGL_set_orthographic( float screen_ratio, float scale, float aspect_ratio, float clip_start, float clip_end, float screen_orientation );

void NGL_set_perspective( float fovy, float aspect_ratio, float clip_start, float clip_end, float screen_orientation );

#endif
