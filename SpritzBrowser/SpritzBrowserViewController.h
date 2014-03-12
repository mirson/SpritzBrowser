//
//  SpritzBrowserViewController.h
//  SpritzBrowser
//
//  Created by Alexander Mirson on 09/03/14.
//  Copyright (c) 2014 Alexander Mirson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spritz-SDK/Spritz_SDK.h>
#import "SVWebViewController.h"
#import "WebViewControllerActivitySpritz.h"
#import "NJKWebViewProgress.h"

@interface SpritzBrowserViewController : UINavigationController <UIWebViewDelegate, SVWebViewControllerActivityDelegate, SpritzViewControllerDelegate, SpritzConnectorCredentialsDelegate, WebViewControllerActivitySpritzDelegate, UITextFieldDelegate, NJKWebViewProgressDelegate>
{
//    UILabel *pageTitle;
    UITextField *addressField;
}

//@property (nonatomic, strong) UILabel *pageTitle;
@property (nonatomic, strong) UITextField *addressField;

@property (nonatomic, strong) UIColor *barsTintColor;

@end
