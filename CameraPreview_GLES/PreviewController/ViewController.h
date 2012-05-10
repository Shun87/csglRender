//
//  ViewController.h
//  PreviewController
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 Crearo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"
#import "VideoProcessor.h"

#import <MessageUI/MessageUI.h>
@interface ViewController : UIViewController<VideoProcessorDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
{
    VideoProcessor *processor;
    GLView *glView;
    UIView *backView;
    
}
@property (nonatomic, retain) IBOutlet UIView *backView;

- (IBAction)btnSend:(id)sender;
@end
