//
//  WebViewControllerActivitySpritz.h
//  SpritzBrowser
//
//  Created by Alexander Mirson on 10/03/14.
//  Copyright (c) 2014 Alexander Mirson. All rights reserved.
//

#import "SVWebViewControllerActivity.h"

@protocol WebViewControllerActivitySpritzDelegate;

@interface WebViewControllerActivitySpritz : SVWebViewControllerActivity

@property (nonatomic, strong) id<WebViewControllerActivitySpritzDelegate> activityDelegate;

@end

@protocol WebViewControllerActivitySpritzDelegate <NSObject>

- (void)performActivity:(NSString *)openingURL;

@end
