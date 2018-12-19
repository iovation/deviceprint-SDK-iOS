//
//  SampleWebKitViewController.m
//  iovSample
//
//  Created by David E. Wheeler on 9/8/15.
//  Copyright © 2015 iovation, Inc. All rights reserved.
//

#import "SampleWebKitViewController.h"
@import FraudForce;

#define haveWebKit NSClassFromString(@"WKWebView") != nil
@interface SampleWebKitViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) IBOutlet UILabel *compatLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshButton;

@end

@implementation SampleWebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (haveWebKit) {
        [self createWebView];
        [self loadWebView];
    }
    self.refreshButton.enabled = haveWebKit;
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Take the properly constrainted (via storyboard) compatLabel frame and apply it to the unconstrained
    // (programmatically-created, WebKit-based) webView frame. This complicated approach is a side effect
    // of our iOS 7 deployment target, thus, no strict iOS 8+ (e.g. WebKit) dependencies.
    self.webView.frame = self.compatLabel.frame;
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

    // Create the web view.
    WKWebView *webKitView = [[WKWebView alloc]
        initWithFrame:self.compatLabel.frame
        configuration:configuration
    ];
    
    // Install the web view into the view hierarchy.
    [self.view addSubview:webKitView];
    self.webView = webKitView;
    self.compatLabel.hidden = YES;
}


- (void)loadWebView {
    // Load up the webView with content.
    if (self.webView.title.length == 0) {
        [self.webView loadHTMLString:[NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"webkit" ofType:@"html"]
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil]
                             baseURL:nil];
    } else {
        // The webView is already displaying the html web page from the app bundle. Inject a new
        // blackbox in response to the reload request.
        NSString *bb = FraudForce.blackbox;
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('bb').value = '%@'",  bb]
                       completionHandler:nil];
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
