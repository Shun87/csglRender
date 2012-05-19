//
//  NGLProgram.h
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#ifndef __NGLProgram____H___
#define __NGLProgram____H___

typedef struct
{
	//! The name of the uniform.
	char			name[ MAX_CHAR ];
	
	//! The variable type for this uniform.
	unsigned int	type;
	
	//! The location id maintained by GLSL for this uniform.
	int				location;
	
	//! Determine if the uniform is constant or shoud be updated every frame.
	unsigned char	constant;
    
} UNIFORM;


//! Structure to deal with vertex attribute variables.
typedef struct
{
	//! The name of the vertex attribute.
	char			name[ MAX_CHAR ];
	
	//! The variable type for this vertex attribute.
	unsigned int	type;
	
	//! The location of the id maintained GLSL for this vertex attribute. 
	int				location;
	
} VERTEX_ATTRIB;

class NGLProgram {
public:
    NGLProgram(char *verSrc, char *fragSrc);
    ~NGLProgram();
    
    unsigned int GetProgramID();
    
    GLuint CreatProgram();
    
    void FreeProgram();
    
    char GetVertexAttribLocation(char *pName);
    
    char GetUniformLocation(char *pName);
    
protected:
    char *m_pVerCode;
    char *m_pFragCode;
    unsigned int m_verShader;
    unsigned int m_fragShader;
    unsigned int m_pid;
    
    //! Array of UNIFORM variables.
    std::vector<UNIFORM> m_uniformArray;
    
    //! Array of vertex attributes.
    std::vector<VERTEX_ATTRIB> m_attribArray;
    
protected:
    GLint glueLinkProgram(GLuint program, bool bDebug = true);
    int CompileShader(unsigned int &shader, const char *code, unsigned int type, bool bDebug = true);
    void AddVertexAttrib(char *name, unsigned int type);
    void AddUnifom(char *name, unsigned int type);
};

#endif
