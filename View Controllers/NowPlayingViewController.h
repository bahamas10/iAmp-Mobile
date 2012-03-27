//
//  NowPlayingViewController.h
//  Ampache
//
//  Created by David Eddy on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NowPlayingViewController : UIViewController{
	IBOutlet UILabel *artist_label, *album_label, *song_label, *time_elapsed, *time_song;
	IBOutlet UIImageView *album_art;
	IBOutlet UIProgressView *progressView;
	NSDictionary *current_song;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
	CGPoint album_art_fixed;
	CGPoint first_location;

	int song_time;
}

@property (nonatomic, retain) IBOutlet UILabel *artist_label, *album_label, *song_label;
@property (nonatomic, retain) IBOutlet UIImageView *album_art;

- (void)update_current_song:(NSDictionary *)data;
- (void)load_album_art:(NSString *)art;
- (void)connectionFailed;

- (NSString *)seconds_to_human_readable:(int)total_seconds;


@property (nonatomic,retain) NSMutableData *responseData;
@property (nonatomic,retain) NSURLConnection *urlConnection;

@end
