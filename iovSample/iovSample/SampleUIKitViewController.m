//
//  SampleUIKitViewController.m
//  iovSample
//
//  This example show how you can integrate the iovation ios library into your iOS Application
//  Created by Greg Crow on 9/11/13.
//  Copyright (c) 2013 iovation, Inc. All rights reserved.
//

#import "SampleUIKitViewController.h"
@import FraudForce;

@interface SampleUIKitViewController ()
- (void)sendBlackboxToURL:(NSURL*)postUrl;
@end

@implementation SampleUIKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.urlField.text = [NSUserDefaults.standardUserDefaults stringForKey:@"blackboxURL"];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)displayAlert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notification"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
	[alertView show];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self submitButtonTapped:self.button];
    return YES;
}

-(IBAction)submitButtonTapped:(id)sender
{
    [self.urlField resignFirstResponder];
    NSString *postUrlStr = [self.urlField text];

    if ([postUrlStr length] <= 0) {
        // let the user know they need to enter some data
        [self displayAlert:@"Please enter a URL!"];
        return;
    }

    // we have some data, but is it in the correct format for our requestSelector
    NSURL *postUrl = [NSURL URLWithString:postUrlStr];
    if ([postUrl.scheme hasPrefix:@"http"]
        && ([[postUrl resourceSpecifier] rangeOfString:@"//"].location != NSNotFound)
    ) {
        [self.activity startAnimating];
        [self sendBlackboxToURL:postUrl];
    } else {
        [self displayAlert:@"Invalid URL format. Example: http://yourdomain.com/resource"];
    }
}

-(IBAction)urlFieldEditingDidEnd:(id)sender
{
    [NSUserDefaults.standardUserDefaults setObject:self.urlField.text forKey:@"blackboxURL"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)sendBlackboxToURL:(NSURL*)postUrl
{
    // Create the blackbox to send in your request
    NSString *blackBox = [FraudForce blackbox];
    self.bbTextView.text = blackBox;
    self.bbTextView.textColor = UIColor.whiteColor;
    NSString *postData = [NSString stringWithFormat:@"bb=%@", blackBox];
    NSData   *msgBody  = [postData dataUsingEncoding:NSUTF8StringEncoding];

	// Build your request object to post the blackbox to your server (example)
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    request.HTTPMethod      = @"POST";
    request.timeoutInterval = 5;
	[request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)msgBody.length] forHTTPHeaderField:@"Content-Length"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:msgBody];

    // Submit an asynchronous request and set up a completion handler.
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)res;
        NSString *message = [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode];
        if (response.statusCode < 200 || response.statusCode >= 300) {
            NSLog(@"Request failed; status code: %lld", (long long)response.statusCode);
            NSLog(@"Response: %@", message);
        }
        [self.activity stopAnimating];
        [self displayAlert:[NSString stringWithFormat:@"%lld: %@",
            (long long)response.statusCode,
            message
        ]];
    }];
}

@end
