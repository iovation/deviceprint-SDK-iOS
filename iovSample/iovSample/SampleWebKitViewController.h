//
//  SampleWebKitViewController.h
//  iovSample
//
//  Copyright (c) 2010-2021 iovation, Inc. All rights reserved.
//

@import UIKit;
@import WebKit;

@interface SampleWebKitViewController : UIViewController <WKScriptMessageHandler>

@property (nonatomic, weak) IBOutlet UIView *webkitContainer;

- (IBAction)loadWebView:(id)sender;

@end
