//
//  SongsViewController.m
//  Ampache
//
//  Created by David Eddy on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SongsViewController.h"
#import "AmpacheAppDelegate.h"


@implementation SongsViewController

@synthesize data, songs;


- (void)playSong:(int)row {
	AmpacheAppDelegate *appDelegate = (AmpacheAppDelegate *)[[UIApplication sharedApplication] delegate];
	//AmpacheSession *ampache_conn = [appDelegate ampache_conn];
	//AudioStreamer *streamer = [appDelegate streamer];
	NSLog(@"App Delegate Retain = %d", [appDelegate retain]);


	NSDictionary *current_song = [songs objectAtIndex:row];

	[appDelegate destroyStreamer];
	[appDelegate createStreamer:current_song];

	NSLog(@"Sending current song to app delegate: %@", current_song);
	[appDelegate update_current_song:current_song];
	NSLog(@"streamer = %@", [appDelegate streamer]);



	[appDelegate tabBarController].selectedIndex = 0;

}



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	 // Return YES for supported orientations
	 return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
 }


#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	NSUInteger row = [indexPath row];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self playSong:row];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
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
	[data release];
}


@end
