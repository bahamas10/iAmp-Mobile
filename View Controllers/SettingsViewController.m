//
//  SettingsViewController.m
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadData];
}

// Present the modal view
- (void)showModalView:(UIViewController *)controller animated:(BOOL)animated {
	[self presentModalViewController:controller animated:animated];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)clearKeyboardButton:(id)sender {
	[usernameField resignFirstResponder];
	[passwordField resignFirstResponder];
	[urlField      resignFirstResponder];
	NSLog(@"Resign");
}

- (IBAction)saveData:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[usernameField text] forKey:@"username"];
	[prefs setObject:[passwordField text] forKey:@"password"];
	[prefs setObject:[urlField text]      forKey:@"url"];
	[prefs synchronize];
	[self clearKeyboardButton:nil];

	AmpacheAppDelegate *appDelegate = (AmpacheAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([appDelegate loadAmpache]) { // successful auth
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Authentication Successful" message:@"Successfully authenticated to the Ampache server." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	} else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Authentication Failure" message:@"Failed to authenticate to the Ampache server." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

- (void)loadData {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[usernameField setText:[prefs objectForKey:@"username"]];
	[passwordField setText:[prefs objectForKey:@"password"]];
	[urlField      setText:[prefs objectForKey:@"url"]];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}



#pragma mark Show Hidden Fields
// function taken from http://stackoverflow.com/questions/1247113/iphone-keyboard-covers-text-field
// Slide the frame up when the text fields editBegin or editEnd
-(IBAction) slideFrameUp {
	[self slideFrame:YES];
}

-(IBAction) slideFrameDown {
	[self slideFrame:NO];
}

-(void) slideFrame:(BOOL) up {
	const int movementDistance = 160; // tweak as needed
	const float movementDuration = 0.3f; // tweak as needed

	int movement = (up ? -movementDistance : movementDistance);

	[UIView beginAnimations: @"anim" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	self.view.frame = CGRectOffset(self.view.frame, 0, movement);
	[UIView commitAnimations];
}


@end
