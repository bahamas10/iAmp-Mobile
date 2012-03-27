//
//  NowPlayingViewController.m
//  Ampache
//
//  Created by David Eddy on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "AmpacheAppDelegate.h"

@implementation NowPlayingViewController

@synthesize artist_label, album_label, song_label, album_art, urlConnection, responseData;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

	}
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	album_art_fixed = album_art.center;
	if (current_song) { // load current song if set
		[self update_current_song:current_song];
	}
}

- (void)update_current_song:(NSDictionary *)data {
	current_song = data;
	[artist_label setText:[data objectForKey:@"artist"]];
	[album_label  setText:[data objectForKey:@"album"]];
	[song_label   setText:[data objectForKey:@"title"]];
	song_time = [(NSString *)[data objectForKey:@"time"] intValue];

	[time_song setText:[self seconds_to_human_readable:song_time]];

	[self load_album_art:[data objectForKey:@"art"]];
}


#pragma mark -
#pragma mark Helper methods for album art
- (void)load_album_art:(NSString *)art {
	//start album as blank
	[[self album_art] setImage:[UIImage imageNamed:@"BlankAlbum.jpg"]];
	// set border around album art
	[album_art.layer setBorderColor:[[UIColor blackColor] CGColor]];
	[album_art.layer setBorderWidth:2.0];

	NSURL *url = [NSURL URLWithString:art];
	NSLog(@"URL of artwork = %@", art);
	NSURLRequest *request = [NSURLRequest requestWithURL:url
						 cachePolicy:NSURLRequestUseProtocolCachePolicy
					     timeoutInterval:10.0];

	// make the connection and retrieve the data
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

	if (urlConnection) {
		// everything is good
	} else {
		NSLog(@"No URL connection");
		[urlConnection cancel];

	}
}

#pragma mark -
#pragma mark Slide Album Art

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	first_location = [touch locationInView:touch.view];

	NSLog(@"First Location: %f, %f", first_location.x, first_location.y);

	[self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// sliding the album art
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:touch.view];

	// the limits
	float bottom_limit = album_art_fixed.y;
	float top_limit = album_art_fixed.y - 93;


	CGPoint new_location;
	new_location.x = album_art_fixed.x; // lock the x coordinate

	// the y coordinates
	float offset  = (location.y - first_location.y); // where finger is - original drag
	float current = album_art.center.y; // where the art currently is
	new_location.y = current + offset;
	// adjust the y coordinate... limit it
	if (new_location.y > bottom_limit) {
		new_location.y = bottom_limit;
	} else if (new_location.y < top_limit) {
		new_location.y = top_limit;
	}

	NSLog(@"New Location: %f, %f", new_location.x, new_location.y);
	album_art.center = new_location;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// sliding the album art

	[self touchesMoved:touches withEvent:event];

	// the limits
	float bottom_limit = album_art_fixed.y;
	float top_limit = album_art_fixed.y - 93;
	float middle = (bottom_limit + top_limit) / 2;


	CGPoint new_location;
	new_location.x = album_art_fixed.x; // lock the x coordinate

	// snap the album art up or down
	if (album_art.center.y <= middle) {
		new_location.y = top_limit;
	} else {
		new_location.y = bottom_limit;
	}
	album_art.center = new_location;

}

#pragma mark -
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	// cast NSURLResponse to NSHTTPURLResponse
	NSHTTPURLResponse * httpResponse =  (NSHTTPURLResponse *)response;
	int statusCode = [httpResponse statusCode];
	if (statusCode == 404 || statusCode == 500 ){
		NSLog(@"404 or 500");
		// album art couldn't load
		[self connectionFailed];
	} else {
		responseData = [[NSMutableData alloc] init];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[responseData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[[self album_art] setImage:[UIImage imageWithData:responseData]];
	// set border around album art
	[album_art.layer setBorderColor:[[UIColor blackColor] CGColor]];
	[album_art.layer setBorderWidth:2.0];
	NSLog(@"Set album art");
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	// something failed
	NSLog(@"connection=%@ didFailWithError error= %@",self.urlConnection, error);
}


- (void)connectionFailed {
	[urlConnection cancel];
}


#pragma mark -
#pragma mark Update Progress
- (void)updateProgress:(NSTimer *)updatedTimer {
	AmpacheAppDelegate *appDelegate = (AmpacheAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([appDelegate streamer].bitRate != 0.0) { // playing
		double progress = [appDelegate streamer].progress;
		//NSLog(@"Progress = %f, song_time = %d", progress/(double)song_time, song_time);
		progressView.progress = progress/(double)song_time;

		[time_elapsed setText:[self seconds_to_human_readable:(int)progress]];
	} else {
		progressView.progress = 0.0;
	}
}


#pragma mark -
#pragma mark standard functions

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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

#pragma mark -
#pragma mark Convenience Functions

- (NSString *)seconds_to_human_readable:(int)total_seconds{
    int seconds = total_seconds % 60; // get the remainder
    int minutes = (total_seconds / 60) % 60; // get minutes the same way
    int hours   = total_seconds / 60 / 60;  // this function won't go higher than hours.. shouldn't be a problem
	if (hours == 0) { // don't print hours then
		return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
	}
	return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}



@end
