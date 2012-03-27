//
//  SettingsViewController.h
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmpacheAppDelegate.h"

@interface SettingsViewController : UIViewController {
	IBOutlet UIButton *saveButton, *clearKeyboardButton;
	IBOutlet UITextField *urlField, *usernameField, *passwordField;

}

- (void)showModalView:(UIViewController *)controller animated:(BOOL)animated;

- (IBAction)clearKeyboardButton:(id)sender;
- (IBAction)saveData:(id)sender;
- (IBAction)slideFrameUp;
- (IBAction)slideFrameDown;
- (IBAction)slideFrame:(BOOL)up;
- (void)loadData;

@end
