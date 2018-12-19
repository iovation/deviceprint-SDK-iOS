//
//  SampleUIWebViewController.h
//  iovSample
//
//  Created by David E. Wheeler on 10/1/14.
//  Copyright (c) 2014 iovation, Inc. All rights reserved.
//

@import UIKit;

@interface SampleUIWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
