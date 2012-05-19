//
//  NGLProgram.cpp
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//
#include "NGL.h"

NGLProgram::NGLProgram(char *verSrc, char *fragSrc)
{
    m_pVerCode = verSrc;
    m_pFragCode = fragSrc;
    
    m_verShader = 0;
    m_fragShader = 0;
    
    m_pid = 0;
}

NGLProgram::~NGLProgram()
{
}

GLuint NGLProgram::CreatProgram()
{
    int nStatus = 1;
    m_pid = glCreateProgram();
    
    nStatus *= CompileShader(m_verShader, m_pVerCode, GL_VERTEX_SHADER);
    nStatus *= CompileShader(m_fragShader, m_pFragCode, GL_FRAGMENT_SHADER);
    
    glAttachShader(m_pid, m_verShader);
    glAttachShader(m_pid, m_fragShader);

    // Link program
	nStatus *= glueLinkProgram(m_pid);
    if (nStatus != 0)
    {
        int i = 0;
        char name[MAX_CHAR];
		int nLen = 0;
		int nTotal = 0;
		int nSize = 0;
        GLenum type = 0;
        
        glGetProgramiv(m_pid, GL_ACTIVE_ATTRIBUTES, &nTotal);
        
        while (i != nTotal) 
        {
            glGetActiveAttrib(m_pid,
                              i,
                              MAX_CHAR,
                              &nLen,
                              &nSize,
                              &type,
                              name
                              );
            AddVertexAttrib(name, type);
            i++;
        }
        
        glGetProgramiv(m_pid, GL_ACTIVE_UNIFORMS, &nTotal);
        i = 0;
        while( i != nTotal )
        {
            glGetActiveUniform(m_pid,
                               i,
                               MAX_CHAR,
                               &nLen,
                               &nSize,
                               &type,
                               name
                               );
            
           
            AddUnifom(name, type);
            
            ++i;
        }
        return 1;
    }
    
    return 0;
}

void NGLProgram::FreeProgram()
{
    if (m_pid != 0)
    {
        glDeleteProgram(m_pid);
        m_pid = 0;
    }
    
    if (m_verShader != 0)
    {
        glDeleteShader(m_verShader);
        m_verShader = 0;
    }
    
    if (m_fragShader)
    {
        glDeleteShader(m_fragShader);
        m_fragShader = 0;
    }
}

char NGLProgram::GetVertexAttribLocation(char *pName)
{
    if (m_attribArray.size() > 0)
    {
        std::vector<VERTEX_ATTRIB>::iterator it = m_attribArray.begin();
        while (it != m_attribArray.end())
        {
            VERTEX_ATTRIB &attrib = *it;
            if (strcmp(attrib.name, pName) == 0)
            {
                return attrib.location;
            }
            
            it++;
        }
    }
    
    return -1;
}

char NGLProgram::GetUniformLocation(char *pName)
{
    if (m_uniformArray.size() > 0)
    {
        std::vector<UNIFORM>::iterator it = m_uniformArray.begin();
        while (it != m_uniformArray.end())
        {
            UNIFORM &uniform = *it;
            if (strcmp(uniform.name, pName) == 0)
            {
                return uniform.location;
            }
            
            it++;
        }
    }
    
    return -1;
}

/* Link a program with all currently attached shaders */
GLint NGLProgram::glueLinkProgram(GLuint program, bool bDebug)
{
	GLint nStatus;
	
	glLinkProgram(program);
	
    if (bDebug)
    {
        GLint logLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(program, logLength, &logLength, log);
            printf("Program link log:\n%s", log);
            free(log);
        }
    }
    
	glGetProgramiv(program, GL_LINK_STATUS, &nStatus);
	if (nStatus == 0)
		printf("Failed to link program %d", program);
	
	return nStatus;
}

unsigned int NGLProgram::GetProgramID()
{
    return m_pid;
}

int NGLProgram::CompileShader(unsigned int &shader, const char *code, unsigned int type, bool bDebug)
{
    if (shader != 0)
    {
        return 0;
    }
    
    shader = glCreateShader(type);
    glShaderSource(shader, 1, &code, NULL);
    glCompileShader(shader);
    
    if (bDebug)
    {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            printf("CompileShader error\r\n");
            free(log);
        } 
    }
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        printf("Failed to compile shader:\n");
        glDeleteShader(shader);
        return 0;
    }
    
    return 1;
}

void NGLProgram::AddVertexAttrib(char *name, unsigned int type)
{
    VERTEX_ATTRIB attrib;
    memset(&attrib, 0, sizeof(VERTEX_ATTRIB));
    strcpy(attrib.name, name);
    attrib.type = type;
    attrib.location = glGetAttribLocation(m_pid, name);
    m_attribArray.push_back(attrib);
}

void NGLProgram::AddUnifom(char *name, unsigned int type)
{
    UNIFORM uniform;
    memset(&uniform, 0, sizeof(UNIFORM));
    strcpy(uniform.name, name);
    uniform.type = type;
    uniform.location = glGetUniformLocation(m_pid, name);
    m_uniformArray.push_back(uniform);
}


