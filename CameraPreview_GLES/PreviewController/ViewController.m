//
//  ViewController.m
//  PreviewController
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 Crearo. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize backView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = self.backView.bounds;
    glView = [[GLView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self.backView addSubview:glView];
    
    VideoProcessor *sprocessor = [[VideoProcessor alloc] init];
    sprocessor.delegate = self;
    [sprocessor setupAndStartCaptureSession];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc{
    [glView release];
    processor.delegate = nil;
    [processor release];
    [super dealloc];
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
    {
        [glView displayPixelBuffer:pixelBuffer];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
