//
//  NGL_TestAppDelegate.h
//  NGL_Test
//
//  Created by chenshun on 12-5-19.
//  Copyright 2012年 chenshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NGL_TestViewController;

@interface NGL_TestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet NGL_TestViewController *viewController;

@end
