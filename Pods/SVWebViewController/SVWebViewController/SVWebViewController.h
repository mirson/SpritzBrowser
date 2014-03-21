//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "SVModalWebViewController.h"

@protocol SVWebViewControllerActivityDelegate;

@interface SVWebViewController : UIViewController

@property (nonatomic, weak) id<SVWebViewControllerActivityDelegate> activityDelegate;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (id)initWithAddress:(NSString*)urlString delegate:(id<UIWebViewDelegate>)delegate;
- (id)initWithURL:(NSURL*)URL delegate:(id<UIWebViewDelegate>)delegate;

- (void)loadURL:(NSURL *)pageURL;
- (void)stopLoading;
- (void)updateToolbarItems;
- (void)setToolbarItemsCompleted;

@end

@protocol SVWebViewControllerActivityDelegate <NSObject>

- (NSArray *)activities;

@end
