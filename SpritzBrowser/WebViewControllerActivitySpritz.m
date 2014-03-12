//
//  WebViewControllerActivitySpritz.m
//  SpritzBrowser
//
//  Created by Alexander Mirson on 10/03/14.
//  Copyright (c) 2014 Alexander Mirson. All rights reserved.
//

#import "WebViewControllerActivitySpritz.h"
#import "SpritzBrowserViewController.h"

@implementation WebViewControllerActivitySpritz

- (UIImage *)activityImage {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return [UIImage imageNamed:[self.activityType stringByAppendingString:@"-iPad"]];
    else
        return [UIImage imageNamed:@"SVWebViewControllerActivityChrome.png"];
}

- (NSString *)activityTitle {
	return NSLocalizedStringFromTable(@"Open in Spritz", @"SVWebViewController", nil);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    NSString *openingURL = [self.URLToOpen.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.activityDelegate performActivity:openingURL];
    
	[self activityDidFinish:YES];
}

@end
