//
//  SampleUIKitViewController.h
//  iovSample
//
//  Copyright (c) 2010-2021 iovation, Inc. All rights reserved.
//

@import UIKit;

@interface SampleUIKitViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *urlField;
@property (nonatomic, weak) IBOutlet UITextView *bbTextView;

- (IBAction)generateBlackbox:(id)sender;
- (IBAction)submitBlackbox:(id)sender;

@end
