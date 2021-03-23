//
//  SampleWebKitViewController.m
//  iovSample
//
//  Copyright (c) 2010-2021 iovation, Inc. All rights reserved.
//

#import "SampleWebKitViewController.h"
@import FraudForce;

@interface SampleWebKitViewController ()
@property (nonatomic, weak) WKWebView *webView;
@end


@implementation SampleWebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createWebView];
    [self loadWebView:nil];
}

- (void)createWebView {
    // Set up on load script, via a WKUserScript that is injected "AtDocumentEnd".
    // The script both populates the textarea element (whose id=bb) with a blackbox string, as well as
    // defining a Blackbox object literal whose injectInto property is a function that triggers the
    // WKScriptMessageHandler protocol method defined in this class.
    NSString *url = [NSUserDefaults.standardUserDefaults stringForKey: @"blackboxURL"];
    NSString *js = [NSString stringWithFormat:
        @"document.getElementById('bb').value = '%@'\n"
        "var Blackbox = { injectInto: function (id) { window.webkit.messageHandlers.bb.postMessage(id) } }\n"
        "%@",
        FraudForce.blackbox,
        url == nil ? @"" : [NSString stringWithFormat:@"document.getElementById('url').value = '%@'\n", url]
    ];

    WKUserScript *userScript = [[WKUserScript alloc]
          initWithSource:js
           injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
        forMainFrameOnly:YES
    ];
    WKUserContentController *userContentController = [WKUserContentController new];
    [userContentController addUserScript:userScript];

    // Set up bb notification.
    [userContentController addScriptMessageHandler:self name:@"bb"];
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.userContentController = userContentController;

    // Create the WebKit-based WebView, and install it into the view hierarchy.
    WKWebView *webKitView = [[WKWebView alloc] initWithFrame:self.webkitContainer.bounds configuration:configuration];
    [self.webkitContainer addSubview:webKitView];
    [webKitView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [webKitView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
    self.webView = webKitView;
}

- (IBAction)loadWebView:(id)sender {
    // Load up the webView with content.
    if (self.webView.title.length > 0) {
        // The webView is already displaying the html web page from the app bundle. Inject a new
        // blackbox in response to the reload request.
        NSString *bb = FraudForce.blackbox;
        NSString *jsCode = [NSString stringWithFormat:@"document.getElementById('bb').value = '%@'",  bb];
        [self.webView evaluateJavaScript:jsCode completionHandler:nil];
    } else {
        NSURL *bundleHtmlUrl = [NSBundle.mainBundle URLForResource:@"webkit" withExtension:@"html"];
        NSString *htmlString = [NSString stringWithContentsOfURL:bundleHtmlUrl encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController
     didReceiveScriptMessage:(WKScriptMessage *)message
{
    // Consider checking properties of message.webView.URL, such as the host
    // property, to ensure that it's a request from a known source.
    if (![message.name isEqualToString:@"bb"]) return;

    // Inject the blackbox.
    [message.webView evaluateJavaScript:[NSString stringWithFormat:
        @"document.getElementById('%@').value = '%@'",
        message.body,
        FraudForce.blackbox
    ] completionHandler: nil];
}

@end
