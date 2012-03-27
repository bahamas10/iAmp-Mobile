//
//  ArtistsViewController.m
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "ArtistsViewController.h"
#import "AlbumsViewController.h"
#import	"AmpacheAppDelegate.h"

@implementation ArtistsViewController

@synthesize data, artists;


- (void)createAlbumsView:(int)row {
	// user selected an Artist

	//get the ampache session object
	if (!ampache_conn) {
		AmpacheAppDelegate *appDelegate = (AmpacheAppDelegate *)[[UIApplication sharedApplication] delegate];
		ampache_conn = [appDelegate ampache_conn];
	}


	NSLog(@"Creating Albums View for row %d", row);
	AlbumsViewController *albVC = [[AlbumsViewController alloc] initWithStyle:UITableViewStylePlain];
	NSDictionary *current_artist = [artists objectAtIndex:row];

	// set the title to the artists name
	[albVC setTitle:[current_artist objectForKey:@"name"]];

	// get the albums for the artist
	NSMutableArray *albums = [ampache_conn get_albums_by_artist_id:[current_artist objectForKey:@"id"]];
	NSLog(@"Albums = %@", albums);

	// create the data for the table view
	NSMutableArray *album_data = [[NSMutableArray alloc] init];
	for (NSDictionary *dict in albums) {
		[album_data addObject:[dict objectForKey:@"name"]];
	}

	[albVC setAlbums:albums];
	[albVC setData:album_data];

	// show the view
	[self.navigationController pushViewController:albVC animated:YES ];


	[albums release];
	[album_data release];
	[albVC release];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	NSUInteger row = [indexPath row];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self createAlbumsView:row];
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

- (void)setData:(NSMutableArray *)r_data {
	data = r_data;
	[self.tableView reloadData];
}


@end
