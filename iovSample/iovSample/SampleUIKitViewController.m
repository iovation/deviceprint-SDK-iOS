//
//  SampleUIKitViewController.m
//  iovSample
//
//  Copyright (c) 2010-2021 iovation, Inc. All rights reserved.
//

#import "SampleUIKitViewController.h"
@import FraudForce;


@implementation SampleUIKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.urlField.text = [NSUserDefaults.standardUserDefaults stringForKey:@"blackboxURL"];
    [self generateBlackbox:nil];
}

- (void)viewDidLayoutSubview {
    [super viewDidLayoutSubviews];
    [self.bbTextView setContentOffset:CGPointMake(0.0, 0.0) animated:false];
}

- (void)displayAlert:(NSString *)message title:(NSString *)title {
    if (title == nil) {
        title = @"Cannot Submit";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (IBAction)generateBlackbox:(id)sender {
    NSString *bb = FraudForce.blackbox;
    self.bbTextView.text = bb;
    if (self.bbTextView.contentOffset.y != 0.0) {
        self.bbTextView.contentOffset = CGPointMake(0.0, 0.0);
    }
}

- (IBAction)submitBlackbox:(id)sender
{
    NSString *urlString = self.urlField.text;
    if (urlString.length == 0) {
        // Let the user know they need to enter some data.
        [self displayAlert:@"Please enter a URL!" title:nil];
        return;
    }
    // Ensure the URL meets expectations.
    NSURL *postURL = [NSURL URLWithString:urlString];
    if (![postURL.scheme hasPrefix:@"http"] || ![postURL.resourceSpecifier containsString:@"//"]) {
        [self displayAlert:@"Invalid URL format. Example: https://yourdomain.com/resource" title:nil];
        return;
    }

    [self.urlField resignFirstResponder];
    // Generate the blackbox string (if one is not already populating the text-view).
    if (self.bbTextView.text.length == 0) {
        [self generateBlackbox:nil];
    }

    // Create the blackbox data to send in your request.
    NSString *blackbox = self.bbTextView.text;
    NSData *messageBody = [[NSString stringWithFormat:@"bb=%@", blackbox] dataUsingEncoding:NSUTF8StringEncoding];
    if (messageBody.length == 0) {
        [self displayAlert:@"Failed to convert blackbox string to data" title:nil];
    }

    // Build your request object to post the blackbox to your server (example).
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:5.0];
    request.HTTPMethod = @"POST";
    request.HTTPBody = messageBody;
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)messageBody.length] forHTTPHeaderField:@"Content-Length"];
	[request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    // Submit an asynchronous request and set up a completion handler.
    NSURLSession *submitBoxSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    NSURLSessionDataTask *submitBoxTask = [submitBoxSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            const NSInteger statusCode = httpResponse.statusCode;
            NSString *statusMessage = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            if (statusCode < 200 || statusCode >= 300) {
                NSLog(@"Request failed; status code: %lld", (long long)statusCode);
                NSLog(@"Response: %@", statusMessage);
            }
            NSString *displayText = [NSString stringWithFormat:@"%lld: %@", (long long)statusCode, statusMessage];
            [self displayAlert:displayText title:@"Request Response"];
        } else if (error != nil) {
            [self displayAlert:error.localizedDescription title:@"Error"];
        }
    }];
    [submitBoxTask resume];
}

#pragma mark - UITextFieldDelegate protocol

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.urlField) {
        [NSUserDefaults.standardUserDefaults setObject:self.urlField.text forKey:@"blackboxURL"];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

@end
