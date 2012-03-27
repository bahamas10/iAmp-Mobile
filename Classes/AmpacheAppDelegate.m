//
//  AmpacheAppDelegate.m
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AmpacheAppDelegate.h"

@implementation AmpacheAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize ampache_conn, streamer;




#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		// create the tab bar
	tabBarController = [[UITabBarController alloc] init];

	// create the viewControllers
	ArtistsViewController *artVC    = [[ArtistsViewController alloc] initWithStyle:UITableViewStylePlain];
	SettingsViewController *setVC   = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	NowPlayingViewController *nowVC = [[NowPlayingViewController alloc] initWithNibName:@"NowPlayingViewController" bundle:nil];

	// add the views to the tabbarcontroller
	UINavigationController *artNVC  = [[UINavigationController alloc] initWithRootViewController:artVC];
	tabBarController.viewControllers = [NSArray arrayWithObjects:nowVC, artNVC, setVC, nil];

	tabBarController.selectedIndex = 1; // load artists view


	// pictures for the tab bar
	artVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Artists" image:[UIImage imageNamed:@"BarArtists.png"] tag:0];
	setVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"settings.png"] tag:1];
	nowVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Now Playing" image:[UIImage imageNamed:@"BarComposers"] tag:2];

	artNVC.navigationBar.tintColor = [UIColor blackColor];

	// set the titles
	[artVC setTitle:@"Artists"];
	[setVC setTitle:@"Settings"];
	[nowVC setTitle:@"Now Playing"];

	// release them now
	[artVC release];
	[setVC release];
	[nowVC release];


	[window addSubview:tabBarController.view];
	// done loading window

	[self loadAmpache]; // load ampache


	[window makeKeyAndVisible];

	return YES;
}

- (BOOL)loadAmpache {
	// check for the users credentials

	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

	NSString *username = (NSString *)[prefs objectForKey:@"username"];
	NSString *password = (NSString *)[prefs objectForKey:@"password"];
	NSString *url_str  = (NSString *)[prefs objectForKey:@"url"];

	NSMutableArray *data    = [[NSMutableArray alloc] init];
	NSMutableArray *artists = [[NSMutableArray alloc] init];

	if (username != nil && password != nil && url_str != nil &&
		[username length] != 0 && [password length] != 0 && [url_str length] != 0) { // credentials are set
		NSLog(@"username = %@", username);
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/server/xml.server.php", url_str]];
		NSLog(@"Using this URL: %@", url);
		ampache_conn = [[AmpacheSession alloc] initWthUsername:username password:password url:url];
		if ([ampache_conn authenticate]) {
			NSLog(@"Authenticated!");
			artists = [ampache_conn get_artists];
			NSLog(@"%@", artists);

			for (NSDictionary *dict in artists) {
				NSLog(@"dict in artists: %@", dict);
				[data addObject:[dict objectForKey:@"name"]];
			}
			// set the data for the artists window
			[(ArtistsViewController *)[[tabBarController.viewControllers objectAtIndex:1] topViewController ] setData:data];
			[(ArtistsViewController *)[[tabBarController.viewControllers objectAtIndex:1] topViewController ] setArtists:artists];

			return YES;
		} else { // error authenticating
			NSLog(@"Error Authenticating");
		}
	} else {
		NSLog(@"No Credentials Found");
		FirstTimeViewController *firstTimeViewController = [[FirstTimeViewController alloc] init];
		[(SettingsViewController *)[tabBarController.viewControllers objectAtIndex:2] showModalView:firstTimeViewController animated:YES];
		[firstTimeViewController release];
	}

	// if it makes it this far it failed to authenticate
	tabBarController.selectedIndex = 2; // load settings view


	return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


- (void)update_current_song:(NSDictionary *)data {
	NSLog(@"data recieved by the delegate: %@", data);
	[[[tabBarController viewControllers] objectAtIndex:0] update_current_song:data];  // now playing
}

#pragma mark AudioStreamer Functions
/* Both functions taken from AudioStreamer.h */
/* URL */

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer {
	if (streamer) {
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];

		[streamer stop];
		[streamer release];
		streamer = nil;
		NSLog(@"Streamer Killed");
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer:(NSDictionary *)current_song {
	if (streamer) {
		return;
	}

	[self destroyStreamer];


	NSURL *url = [NSURL URLWithString:[current_song objectForKey:@"url"]];
	NSLog(@"%@", url);
	streamer = [[AudioStreamer alloc] initWithURL:url];
	[streamer start];

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];

	progressUpdateTimer =
	[NSTimer
	 scheduledTimerWithTimeInterval:0.1
	 target:[tabBarController.viewControllers objectAtIndex:0]
	 selector:@selector(updateProgress:)
	 userInfo:nil
	 repeats:YES];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];
}


//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification {
	if ([streamer isWaiting]) {
		NSLog(@"Streamer is waiting");
		//[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
	}
	else if ([streamer isPlaying]) {
		NSLog(@"Streamer is playing");
		//[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
	}
	else if ([streamer isIdle]) {
		NSLog(@"Streamer is idle");
		[self destroyStreamer];
		//[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
	}
}

#pragma mark -
#pragma mark Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	// nothing
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
