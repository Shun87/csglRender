//
//  CoreEngine.h
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#ifndef _CoreEngine____H___
#define _CoreEngine____H___

class CoreEngine {
public:
    CoreEngine(int nWidth, int nHeight);
    ~CoreEngine();
    
    static CoreEngine *Creat(int nWidth, int nHeight);
    void Start();
    void Draw();

protected:
    char *m_pVertext;
    char *m_pFragment;
};


#endif
