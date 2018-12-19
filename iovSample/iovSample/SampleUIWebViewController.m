//
//  SampleUIWebViewController.m
//  iovSample
//
//  Created by David E. Wheeler on 10/1/14.
//  Copyright (c) 2014 iovation, Inc. All rights reserved.
//

#import "SampleUIWebViewController.h"
@import FraudForce;

@interface SampleUIWebViewController ()

@end

@implementation SampleUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFile];
}

- (IBAction)loadFile {
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"uiwebview" ofType:@"html"];
    [self.webView loadData:[NSData dataWithContentsOfFile:filePath]
                  MIMEType:@"text/html"
          textEncodingName:@"UTF-8"
                   baseURL:[NSURL new]
    ];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    // Fill the URL field with the value stored from the native view.
    NSString *url = [NSUserDefaults.standardUserDefaults stringForKey:@"blackboxURL"];
    if (url != nil) {
        [wv stringByEvaluatingJavaScriptFromString:[NSString
            stringWithFormat:@"document.getElementById('url').value = '%@'", url
        ]];
    }

    // Inject a JavaScript function that can be called by the HTML to fill
    // a hidden field by ID.
    [wv stringByEvaluatingJavaScriptFromString:@" \
        var Blackbox = { \
            injectInto: function(id) { \
                var iframe = document.createElement('IFRAME'); \
                iframe.setAttribute('src', 'iov://blackbox/fill#' + id); \
                document.documentElement.appendChild(iframe); \
                iframe.parentNode.removeChild(iframe); \
                iframe = null; \
            } \
         } \
     "];

    // Inject a blackbox into a known form field. Use only if the HTML page is
    // known to you and expecting a blackbox.
    NSString *bb = [FraudForce blackbox];
    [wv stringByEvaluatingJavaScriptFromString:[NSString
        stringWithFormat:@"document.getElementById('bb').value = '%@'",  bb
    ]];
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = request.URL;
    // Return true if it is not an iov:// URL.
    if (![url.scheme isEqualToString:@"iov"]) return YES;

    // Consider checking other parts of the url, such as the host property, to
    // ensure that it's a request from a known source.

    // Get the fragment identifying the hidden field to populate or return.
    NSString *frag = url.fragment;
    if (frag == nil) return YES;

    // Inject the blackbox into the hidden field.
    NSString *bb = [FraudForce blackbox];
    [wv stringByEvaluatingJavaScriptFromString:[NSString
        stringWithFormat:@"document.getElementById('%@').value = '%@'", frag, bb
    ]];

    // Return false to prevent a request and reload.
    return NO;
}

@end
