//
//  SpritzBrowserViewController.m
//  SpritzBrowser
//
//  Created by Alexander Mirson on 09/03/14.
//  Copyright (c) 2014 Alexander Mirson. All rights reserved.
//

#import "SpritzBrowserViewController.h"
#import "MBProgressHUD.h"
#import "NJKWebViewProgressView.h"

static const CGFloat kMargin = 16.0f;
static const CGFloat kSpacer = 6.0f;
//static const CGFloat kLabelHeight = 12.0f;
//static const CGFloat kLabelFontSize = 10.0f;
static const CGFloat kAddressHeight = 28.0f;
static const CGFloat kAddressFontSize = 18.0f;

static const NSInteger kAddressCancelButtonTag = 1002;

static NSString *clientID = @"AlexanderTest";
static NSString *clientSecret = @"fgRsKKzgP6";
static NSString *redirectURI = @"http://www.spritzinc.com/";

@interface SpritzBrowserViewController ()
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    UIWebView *_webView;
}

@property (nonatomic, strong) SVWebViewController *webViewController;

@end


@implementation SpritzBrowserViewController

//@synthesize pageTitle;
@synthesize addressField;

#pragma mark - Initialization

- (id)init
{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    self.webViewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.google.com"]
                                                             delegate:_progressProxy];
    self.webViewController.activityDelegate = self;
    
    if (self = [super initWithRootViewController:self.webViewController]) {
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
//    CGRect labelFrame = CGRectMake(kMargin,
//                                   kSpacer,
//                                   self.navigationBar.bounds.size.width - 2*kMargin,
//                                   kLabelHeight);
//    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
//    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    label.backgroundColor = [UIColor clearColor];
//    label.font = [UIFont systemFontOfSize:kLabelFontSize];
//    label.textAlignment = NSTextAlignmentCenter;
//    [self.navigationBar addSubview:label];
//    self.pageTitle = label;
    
    CGRect addressFrame = CGRectMake(kMargin,
                                     // kSpacer*2 + kLabelHeight,
                                     kSpacer,
                                     // labelFrame.size.width,
                                     self.navigationBar.bounds.size.width - 2*kMargin,
                                     kAddressHeight);
    UITextField *address = [[UITextField alloc] initWithFrame:addressFrame];
    address.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    address.borderStyle = UITextBorderStyleRoundedRect;
    address.font = [UIFont systemFontOfSize:kAddressFontSize];
    address.autocapitalizationType = UITextAutocapitalizationTypeNone;
    address.autocorrectionType = UITextAutocorrectionTypeNo;
    address.keyboardType = UIKeyboardTypeWebSearch;
    address.returnKeyType = UIReturnKeyGo;
    address.delegate = self;
    [self.navigationBar addSubview:address];
    self.addressField = address;
    
//    [address addTarget:self
//                action:@selector(loadAddress:event:)
//      forControlEvents:UIControlEventEditingDidEndOnExit|UIControlEventEditingDidEnd];

    CGFloat progressBarHeight = 2.5f;
    CGRect navigaitonBarBounds = self.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(spritzConnectorDidAuthentificate:)
                                                 name:spritzConnectorDidAuthentificateNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    self.webViewController.title = self.title;
    self.navigationBar.tintColor = self.barsTintColor;

    [self.navigationBar addSubview:_progressView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [SpritzConnector sharedConnector].delegate = self;
        [[SpritzConnector sharedConnector] setUpDataStore];
        [[SpritzConnector sharedConnector] authenticateClient];
//        SpritzSettings *spritzSettings = [SpritzSettings sharedSpritzSettings];
//        [[SpritzDataStore sharedStore] saveDefaultUserSettings:spritzSettings];
//        [[SpritzDataStore sharedStore].userSettings setWordsPerMinute:280];
	});
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

- (void)spritzConnectorDidAuthentificate:(NSNotification *)notification
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadAddress:(id)sender event:(UIEvent *)event
{
    NSString *urlString = [self.addressField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url != nil && (!([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]))) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:[url absoluteString]]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if ([urlString rangeOfString:@"."].location != NSNotFound && [NSURLConnection canHandleRequest:request]) {
        [self.webViewController loadURL:url];
    } else {
        [self searchWeb:sender];
    }
}

- (void)searchWeb:(id)sender
{
	NSString *searchQuery = self.addressField.text;
    NSString *encodedSearchQuery = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                         NULL,
                                                                                                         (CFStringRef)searchQuery,
                                                                                                         NULL,
                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                         kCFStringEncodingUTF8
                                                                                                         ));
	NSString *urlString = [@"http://www.google.de/search?q=" stringByAppendingString:encodedSearchQuery];
    
    [self.webViewController loadURL:[NSURL URLWithString:urlString]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    _webView = webView;
    
    self.addressField.text = [[[webView request] URL] absoluteString];
    [self.webViewController updateToolbarItems];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    _webView = webView;
    
    self.addressField.text = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.addressField.textAlignment = NSTextAlignmentCenter;
                     }
                     completion:^(BOOL finished) {
                     }];
//    self.addressField.text = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    [self.webViewController updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self.webViewController updateToolbarItems];
}

#pragma mark - SVWebViewControllerActivityDelegate

- (NSArray *)activities
{
    WebViewControllerActivitySpritz *activity = [WebViewControllerActivitySpritz new];
    activity.activityDelegate = self;
    return @[activity];
}

#pragma mark - SpritzViewControllerDelegate

- (void)spritzViewControllerDidFinish:(SpritzViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SpritzConnectorCredentialsDelegate

- (NSString *)clientID
{
    return clientID;
}

- (NSString *)clientSecret
{
    return clientSecret;
}

- (NSString *)redirectURI
{
    return redirectURI;
}

#pragma mark - WebViewControllerActivitySpritzDelegate

- (void)performActivity:(NSString *)openingURL
{
    [self performSelector:@selector(startAfterDelay:) withObject:openingURL afterDelay:0.6];
}

- (void)startAfterDelay:(NSString *)openingURL
{
    MainSpritzViewController *_mainSpritzViewController = [MainSpritzViewController new];
    _mainSpritzViewController.spritzViewControllerDelegate = self;
    [self presentViewController:_mainSpritzViewController animated:YES completion:^(void) {
        [_mainSpritzViewController.spritzViewController startSpritzing:openingURL
                                                            sourceType:SourceFlagURL];
    }];
}

- (void)startAfterDelay_old:(NSString *)openingURL
{
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"Spritz-SDK" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SpritzStoryboard" bundle:resourceBundle];
    SpritzViewController *_spritzViewController;
	_spritzViewController = [storyboard instantiateViewControllerWithIdentifier:@"SpritzViewController"];
    _spritzViewController.delegate = self;
	[self presentViewController:_spritzViewController animated:YES completion:nil];
    
    [MBProgressHUD showHUDAddedTo:_spritzViewController.view animated:YES];
    
    NSString *URL = @"http://boilerpipe-web.appspot.com/extract";
    NSDictionary *parameters = @{ @"output" : @"text",
                                  @"url" : openingURL };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:URL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [MBProgressHUD hideHUDForView:_spritzViewController.view animated:YES];
        
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [_spritzViewController startSpritzing:text sourceType:SourceFlagPlain];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [UIAlertView showSpritzAPIError:error];
    }];
}

#pragma mark - UITextFieldDelegate

- (void)addressFieldCancel
{
    self.addressField.text = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self.addressField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self loadAddress:nil event:nil];

	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [self.addressField setSelectedTextRange:[self.addressField textRangeFromPosition:self.addressField.beginningOfDocument
//                                                                          toPosition:self.addressField.endOfDocument]];
    
    // Stop loading if we are loading a page
    [self.webViewController stopLoading];
    
    // Move a "cancel" button into the nav bar a la Safari.
    UINavigationBar *navBar = self.navigationBar;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
    [cancelButton setFrame:CGRectMake(navBar.bounds.size.width,
                                      kSpacer,
                                      75 - kMargin,
                                      kAddressHeight)];
    [cancelButton setHidden:NO];
    [cancelButton setEnabled:YES];
    [cancelButton addTarget:self action:@selector(addressFieldCancel) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = kAddressCancelButtonTag;
    
    
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.addressField.frame = CGRectMake(kMargin,
                                                              kSpacer,
                                                              navBar.bounds.size.width - 2*kMargin - 75,
                                                              kAddressHeight);
                         self.addressField.textAlignment = NSTextAlignmentLeft;
                         
                         [cancelButton setFrame:CGRectMake(navBar.bounds.size.width - 75,
                                                           kSpacer,
                                                           75 - kMargin,
                                                           kAddressHeight)];
                         [navBar addSubview:cancelButton];
                         
                     }
                     completion:^(BOOL finished) {
                         self.addressField.clearButtonMode = UITextFieldViewModeAlways;
                     }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UINavigationBar *navBar = self.navigationBar;
    UIButton *cancelButton = (UIButton *)[self.view viewWithTag:kAddressCancelButtonTag];
    
    self.addressField.clearButtonMode = UITextFieldViewModeNever;
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.addressField.frame = CGRectMake(kMargin,
                                                              kSpacer,
                                                              navBar.bounds.size.width - 2*kMargin,
                                                              kAddressHeight);
                         self.addressField.textAlignment = NSTextAlignmentCenter;
                         
                         [cancelButton setFrame:CGRectMake(navBar.bounds.size.width,
                                                           kSpacer,
                                                           75 - kMargin,
                                                           kAddressHeight)];
                     }
                     completion:^(BOOL finished) {
                         [cancelButton removeFromSuperview];
                     }]; 
}

#pragma mark - NJKWebViewProgressDelegate

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    
    // hook to set toolbar items proper
    if (progress == 1.0) {
        [self.webViewController setToolbarItemsCompleted];
    }
}

@end
