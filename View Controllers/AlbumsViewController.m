    //
//  AlbumsViewController.m
//  Ampache
//
//  Created by David Eddy on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlbumsViewController.h"
#import "SongsViewController.h"
#import "AmpacheAppDelegate.h"


@implementation AlbumsViewController

@synthesize data, albums;


- (void)createSongsView:(int)row {
	// user selected an Album

	//get the ampache session object
	if (!ampache_conn) { // if this doesn't have a pointer to the delegates create one
		AmpacheAppDelegate *appDelegate = (AmpacheAppDelegate *)[[UIApplication sharedApplication] delegate];
		ampache_conn = [appDelegate ampache_conn];
	}

	NSLog(@"Creating Songs View for row %d", row);
	SongsViewController *sonVC = [[SongsViewController alloc] initWithStyle:UITableViewStylePlain];
	NSDictionary *current_album = [albums objectAtIndex:row];

	// set the title to the albums name
	[sonVC setTitle:[current_album objectForKey:@"name"]];

	NSLog(@"Current Album = %@", current_album);

	// get the songs for the artist
	NSMutableArray *songs = [ampache_conn get_songs_by_album_id:[current_album objectForKey:@"id"]];
	NSLog(@"Songs = %@", songs);

	// create the data for the table view
	NSMutableArray *song_data = [[NSMutableArray alloc] init];
	for (NSDictionary *dict in songs) {
		[song_data addObject:[dict objectForKey:@"title"]];
	}

	[sonVC setSongs:songs];
	[sonVC setData:song_data];

	// show the view
	[self.navigationController pushViewController:sonVC animated:YES ];

	[songs release];
	[song_data release];
	[sonVC release];
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
	[self createSongsView:row];
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
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
