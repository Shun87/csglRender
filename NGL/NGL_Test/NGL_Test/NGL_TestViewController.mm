//
//  NGL_TestViewController.m
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#import "NGL_TestViewController.h"
#import "NGLView.h"
#include "CoreEngine.h"

@implementation NGL_TestViewController

CoreEngine *s_pEngine;
#pragma mark - View lifecycle


- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

- (void)render
{
    [(NGLView *)self.view setFramebuffer];
    
    if (NULL !=s_pEngine)
    {
        s_pEngine->Draw();
    }
    
    [(NGLView *)self.view presentFramebuffer];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = self.view.frame;
    int nWidth = CGRectGetWidth(rect);
    int nHeight = CGRectGetHeight(rect);
    s_pEngine = CoreEngine::Creat(nWidth, nHeight);
    
    [self setupDisplayLink];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
