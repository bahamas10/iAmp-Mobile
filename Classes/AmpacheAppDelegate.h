//
//  AmpacheAppDelegate.h
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ArtistsViewController.h"
#import "SettingsViewController.h"
#import "NowPlayingViewController.h"
#import "FirstTimeViewController.h"

#import "AmpacheSession.h"
#import	"AudioStreamer.h"


@interface AmpacheAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController *tabBarController;
	AmpacheSession *ampache_conn;
	NSTimer *progressUpdateTimer;
	AudioStreamer *streamer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) AmpacheSession *ampache_conn;
@property (nonatomic, retain) AudioStreamer *streamer;

- (BOOL)loadAmpache;

- (void)createStreamer:(NSDictionary *)current_song;
- (void)destroyStreamer;

- (void)update_current_song:(NSDictionary *)data;

@end

