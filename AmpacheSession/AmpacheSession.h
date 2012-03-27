//
//  AmpacheSession.h
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AmpacheSession : NSObject <NSXMLParserDelegate> {
	// Ampache Specific ivars
	NSURL *url;
	NSString *username, *password, *auth;
	int artists_num, albums_num, songs_num, auth_current_retry;
	// XML parser ivars
	NSMutableArray *items;
	NSXMLParser *xmlParser;
	NSString *currentElement, *currentItem;
	NSMutableDictionary *item;

	NSMutableString *xml_auth, *xml_songs_num, *xml_artists_num,
					*xml_albums_num, *xml_name, *xml_artist, *xml_album,
					*xml_year, *xml_tracks, *xml_art, *xml_title, *xml_time,
	*xml_url, *xml_size, *xml_id, *xml_error;
}
@property (nonatomic, copy) NSString *username, *password, *auth;

@property (nonatomic, copy) NSURL *url;

@property (nonatomic, assign) int artists_num, albums_num, songs_num, auth_current_retry;


- (id)initWthUsername:(NSString *)a_username
			 password:(NSString *)a_password
				  url:(NSURL *)a_url;

- (void)setCredentialsWithUsername:(NSString *)a_username
						password:(NSString *)a_password
							 url:(NSURL *)a_url;

- (BOOL)authenticate;
- (NSMutableArray *)get_artists;
- (NSMutableArray *)get_albums_by_artist_id:(NSString *)artist_id;
- (NSMutableArray *)get_songs_by_album_id:(NSString *)album_id;


// XML
- (void)parseXMLFileAtURL:(NSURL *)URL;
- (void)clearAllXMLVariables;


// private
- (NSString *)trimNewLines:(NSString *)value;
- (NSString *)SHA256:(NSString *)value;

- (void)startActivityIndicator;
- (void)stopActivityIndicator;

@end
