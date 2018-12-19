//
//  SampleUIKitViewController.h
//  iovSample
//
//  Created by Greg Crow on 9/11/13.
//  Copyright (c) 2013 iovation, Inc. All rights reserved.
//

@import UIKit;

@interface SampleUIKitViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) IBOutlet UITextField *urlField;
@property (nonatomic, strong) IBOutlet UITextView *bbTextView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity;

-(IBAction)submitButtonTapped:(id)sender;

-(IBAction)urlFieldEditingDidEnd:(id)sender;
-(void)displayAlert:(NSString *) msg;

@end
