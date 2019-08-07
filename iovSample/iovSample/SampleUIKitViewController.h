//
//  SampleUIKitViewController.h
//  iovSample
//
//  Copyright (c) 2010-2019 iovation, Inc. All rights reserved.
//

@import UIKit;

@interface SampleUIKitViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *urlField;
@property (nonatomic, weak) IBOutlet UITextView *bbTextView;

- (IBAction)generateBlackbox:(id)sender;
- (IBAction)submitBlackbox:(id)sender;

@end
