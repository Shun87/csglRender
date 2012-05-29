//
//  NGL.cpp
//  NGL_Test
//
//  Created by chenshun on 12-5-29.
//  Copyright 2012年 chenshun. All rights reserved.
//

#include "NGL.h"

NGL ngl;

void NGL_start( void )
{
    memset(&ngl, 0, sizeof(NGL));
    
    glEnable( GL_DEPTH_TEST );
    
    glClearColor( 0.0f, 0.0f, 0.0f, 1.0f );
	
	glClear( GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
    NGL_set_matrix_mode( TEXTURE_MATRIX );
    NGL_load_identity();
    
    NGL_set_matrix_mode( PROJECTION_MATRIX );
    NGL_load_identity();
    
    NGL_set_matrix_mode( MODELVIEW_MATRIX );
    NGL_load_identity();
}

void NGL_set_matrix_mode( unsigned int uiMode )
{
    ngl.matrix_mode = uiMode;
}

void NGL_load_identity( void )
{
    switch ( ngl.matrix_mode )
    {
        case MODELVIEW_MATRIX:
        {
            mat4 *m = NGL_get_modelview_matrix();
            m->Identity();
        }
            break;
        case PROJECTION_MATRIX:
        {
            mat4 *m = NGL_get_projection_matrix();
            m->Identity();
        }
            break;
            
        default:
            break;
    }
}

mat4 *NGL_get_modelview_matrix( void )
{ 
    return &ngl.modelview_matrix[ ngl.modelview_matrix_index ]; 
}


/*!
 Return the projection matrix pointer on the top of the projection matrix stack.
 
 \return  Return a 4x4 matrix pointer of the top most projection matrix index.
 */
mat4 *NGL_get_projection_matrix( void )
{ 
    return &ngl.projection_matrix[ ngl.projection_matrix_index ]; 
}


/*!
 Return the texture matrix pointer on the top of the texture matrix stack.
 
 \return  Return a 4x4 matrix pointer of the top most texture matrix index.
 */
mat4 *NGL_get_texture_matrix( void )
{ 
    return &ngl.texture_matrix[ ngl.texture_matrix_index ]; 
}

/*!
 Return the result of the of the top most modelview matrix multiplied by the top
 most projection matrix.
 
 \return Return the 4x4 matrix pointer of the projection matrix index.	
 */
mat4 *NGL_get_modelview_projection_matrix( void )
{
    mat4 *projection = NGL_get_projection_matrix();
    mat4 *model = NGL_get_modelview_matrix();
    ngl.modelview_projection_matrix = (*projection) * (*model);
	return &ngl.modelview_projection_matrix; 
}
