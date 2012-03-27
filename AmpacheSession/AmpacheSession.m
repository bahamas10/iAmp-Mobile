//
//  AmpacheSession.m
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AmpacheSession.h"
#import <CommonCrypto/CommonHMAC.h>


@implementation AmpacheSession

@synthesize username, password, auth;
@synthesize url;
@synthesize artists_num, albums_num, songs_num, auth_current_retry;

- (id)init {
	if (!(self = [super init] )){
		return nil;
	}
	[self initWthUsername:nil password:nil url:nil];
	return self;
}

- (id)initWthUsername:(NSString *)a_username password:(NSString *)a_password url:(NSURL *)a_url {
	if (!(self = [super init] )){
		return nil;
	}
	[self setUsername:a_username];
	[self setPassword:a_password];
	[self setUrl:a_url];

	[self setAuth:nil];
	[self setArtists_num:-1];
	[self setAlbums_num:-1];
	[self setSongs_num:-1];
	[self setAuth_current_retry:0];
	return self;
}

- (void)setCredentialsWithUsername:(NSString *)a_username password:(NSString *)a_password url:(NSURL *)a_url {
	[self setUsername:a_username];
	[self setPassword:a_password];
	[self setUrl:a_url];
}

-(BOOL)authenticate { // Authenticate to the Server
	[self startActivityIndicator];
	// API Version
	int api_version = 350001;
	// get the time stamp
	int timestamp = [[NSDate date] timeIntervalSince1970];
	// hash the passphrase
	NSString *key = [self SHA256:password];
	NSString *passphrase = [self SHA256:[NSString stringWithFormat:@"%d%@", timestamp, key]];
	NSLog(@"%@", passphrase);

	// Format the GET data
	NSString *data = [NSString
					  stringWithFormat:@"action=handshake&version=%d&user=%@&timestamp=%d&auth=%@",
					  api_version, username, timestamp, passphrase];
	// Create the new URL with the data
	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",url,data]];

	[self parseXMLFileAtURL:newURL];
	[self stopActivityIndicator];

	NSLog(@"XML AUTH = '%@'", xml_auth);

	if ([xml_auth length] == 0) { // failed
		NSLog(@"Error authenticating: %@", xml_error);
		return NO;
	}

	// everything OK up until now
	auth = [[self trimNewLines:xml_auth] retain];

	if (auth != nil) {
		return YES;
	} // else
	return NO;
}

- (NSMutableArray *)get_artists {
	if (!auth) { // not authenticated
		return NO;
	}

	[self startActivityIndicator];

	// Format the GET data
	NSString *data = [NSString stringWithFormat:@"action=artists&auth=%@", auth];
	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",url,data]];

	[self parseXMLFileAtURL:newURL];

	[self stopActivityIndicator];

	return items;

}

- (NSMutableArray *)get_albums_by_artist_id:(NSString *)artist_id {
	if (!auth) { // not authenticated
		return NO;
	}

	[self startActivityIndicator];

	// Format the GET data
	NSString *data = [NSString stringWithFormat:@"action=artist_albums&filter=%@&auth=%@", artist_id, auth];
	NSLog(@"data = %@",data);
	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",url,data]];
	NSLog(@"%@", newURL);
	[self parseXMLFileAtURL:newURL];

	[self stopActivityIndicator];

	return items;
}

- (NSMutableArray *)get_songs_by_album_id:(NSString *)album_id {
	if (!auth) { // not authenticated
		return NO;
	}

	[self startActivityIndicator];

	// Format the GET data
	NSString *data = [NSString stringWithFormat:@"action=album_songs&filter=%@&auth=%@", album_id, auth];
	NSLog(@"data = %@",data);
	NSURL *newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",url,data]];
	NSLog(@"%@", newURL);
	[self parseXMLFileAtURL:newURL];

	[self stopActivityIndicator];

	return items;
}



#pragma mark XML Parser

- (void)parseXMLFileAtURL:(NSURL *)URL {
	items = [[NSMutableArray alloc] init];
	currentItem = nil;
	currentElement = [[NSString alloc] init];

	xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:URL];

	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[xmlParser setDelegate:self];

	// properties
	[xmlParser setShouldProcessNamespaces:NO];
	[xmlParser setShouldReportNamespacePrefixes:NO];
	[xmlParser setShouldResolveExternalEntities:NO];

	[xmlParser parse]; // blocking
}


- (void)parserDidStartDocument:(NSXMLParser *)parser {
	//NSLog(@"Starting the xml parser");
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString *error = [NSString stringWithFormat:@"Error code %i", [parseError code]];
	NSLog(@"Error: %@", error);

	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Cannot connect to Ampache!" message:error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	//NSLog(@"current element = %@, found element: %@", currentElement, elementName);
	currentElement = [elementName copy];
	if (!currentItem) {
		currentItem = [elementName copy];
	}
	//NSLog(@"Current Item is NOW SET TO %@", currentItem);

	if ([currentElement isEqualToString:@"root"]) { // starting the first parse
		[self clearAllXMLVariables];
		currentItem = nil;
	} else if ([currentItem isEqualToString:@"artist"]) { // parsing artists
	//	NSLog(@"currentItem is equal to string artist");
		if ([elementName isEqualToString:@"artist"]) { // starting a new artist
			[self clearAllXMLVariables];
	//		NSLog(@"Clearing All Variables");
			xml_id = [attributeDict objectForKey:@"id"];
		}
		//currentItem = [elementName copy];
	} else if ([currentItem isEqualToString:@"album"]) { // parsing albums
		if ([elementName isEqualToString:@"album"]) { // starting a new album
			[self clearAllXMLVariables];
			xml_id = [attributeDict objectForKey:@"id"];
		}
	} else if ([currentItem isEqualToString:@"song"]) { // parsing songs
		if ([elementName isEqualToString:@"song"]) { // starting a new song
			[self clearAllXMLVariables];
			xml_id = [attributeDict objectForKey:@"id"];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{

	//NSLog(@"Ended element: %@", elementName);
	if (currentItem != nil) {
		//NSLog(@"current item is at this when element ended: %@", currentItem);
	}

	if ([currentItem isEqualToString:@"artist"]) {
		if ([elementName isEqualToString:@"artist"]) {
			//NSLog(@"---- Ended current item artist-----");
			//NSLog(@"xml_name = %@", xml_name);
			[item setObject:[self trimNewLines:xml_name]   forKey:@"name"];
			[item setObject:[self trimNewLines:xml_id]     forKey:@"id"];


			//NSLog(@"adding story: %@ - item = %@", xml_name, item);
			[items addObject:[item copy]];
		}
	} else if ([currentItem isEqualToString:@"album"]) {
		if ([elementName isEqualToString:@"album"]) {
			[item setObject:[self trimNewLines:xml_name]   forKey:@"name"];
			[item setObject:[self trimNewLines:xml_year]   forKey:@"year"];
			[item setObject:[self trimNewLines:xml_tracks] forKey:@"tracks"];
			[item setObject:[self trimNewLines:xml_art]    forKey:@"art"];
			[item setObject:[self trimNewLines:xml_id]     forKey:@"id"];

			[items addObject:[item copy]];
		}
	} else if ([currentItem isEqualToString:@"song"]) {
		if ([elementName isEqualToString:@"song"]) {
			[item setObject:[self trimNewLines:xml_title]  forKey:@"title"];
			[item setObject:[self trimNewLines:xml_time]   forKey:@"time"];
			[item setObject:[self trimNewLines:xml_size]   forKey:@"size"];
			[item setObject:[self trimNewLines:xml_id]     forKey:@"id"];
			[item setObject:[self trimNewLines:xml_url]    forKey:@"url"];
			[item setObject:[self trimNewLines:xml_album]  forKey:@"album"];
			[item setObject:[self trimNewLines:xml_artist] forKey:@"artist"];
			[item setObject:[self trimNewLines:xml_art]    forKey:@"art"];

			[items addObject:[item copy]];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	//NSLog(@"found characters: %@", string);
	// save the characters for the current item...
	if ([currentElement isEqualToString:@"name"]) {
		[xml_name appendString:string];
	} else if ([currentElement isEqualToString:@"year"]) {
		[xml_year appendString:string];
	} else if ([currentElement isEqualToString:@"error"]) {
			[xml_error appendString:string];
	} else if ([currentElement isEqualToString:@"auth"]) {
		[xml_auth appendString:string];
	} else if ([currentElement isEqualToString:@"songs"]) {
		[xml_songs_num appendString:string];
	} else if ([currentElement isEqualToString:@"albums"]) {
		[xml_albums_num appendString:string];
	} else if ([currentElement isEqualToString:@"artists"]) {
		[xml_artists_num appendString:string];
	} else if ([currentElement isEqualToString:@"title"]) {
		[xml_title appendString:string];
	} else if ([currentElement isEqualToString:@"tracks"]) {
		[xml_tracks appendString:string];
	} else if ([currentElement isEqualToString:@"art"]) {
		[xml_art appendString:string];
	} else if ([currentElement isEqualToString:@"size"]) {
		[xml_size appendString:string];
	} else if ([currentElement isEqualToString:@"url"]) {
		[xml_url appendString:string];
	} else if ([currentElement isEqualToString:@"time"]) {
		[xml_time appendString:string];
	} else if ([currentElement isEqualToString:@"artist"]) {
		[xml_artist appendString:string];
	} else if ([currentElement isEqualToString:@"album"]) {
		[xml_album appendString:string];
	}

}

- (void)parserDidEndDocument:(NSXMLParser *)parser {

	//[activityIndicator stopAnimating];
	//[activityIndicator removeFromSuperview];

//	NSLog(@"all done!");
//	NSLog(@"items array has %d items", [items count]);
}


- (void)clearAllXMLVariables {
	item = [[NSMutableDictionary alloc] init];
	xml_id = [[NSMutableString alloc] init];
	xml_auth = [[NSMutableString alloc] init];
	xml_songs_num = [[NSMutableString alloc] init];
	xml_artists_num = [[NSMutableString alloc] init];
	xml_albums_num = [[NSMutableString alloc] init];
	xml_name = [[NSMutableString alloc] init];
	xml_artist = [[NSMutableString alloc] init];
	xml_album = [[NSMutableString alloc] init];
	xml_year = [[NSMutableString alloc] init];
	xml_tracks = [[NSMutableString alloc] init];
	xml_art = [[NSMutableString alloc] init];
	xml_title = [[NSMutableString alloc] init];
	xml_time = [[NSMutableString alloc] init];
	xml_url = [[NSMutableString alloc] init];
	xml_size = [[NSMutableString alloc] init];
	xml_error = [[NSMutableString alloc] init];
}


#pragma mark Private Functions
// SHA256 function taken from
// http://www.iphonedevsdk.com/forum/iphone-sdk-development/60684-hashing-nsstring-encoded-utf-8-using-sha256-than-base64.html
- (NSString *)SHA256:(NSString *)value {
	const char *s = [value cStringUsingEncoding:NSUTF8StringEncoding]; // NSUTF16LittleEndianStringEncoding
	NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
	uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
	CC_SHA256(keyData.bytes, keyData.length, digest);
	NSData *out = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
	NSString *hash = [out description];
	hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
	hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
	return hash;
}

#pragma mark convenience
// Trim whitespace and newlines
- (NSString *)trimNewLines:(NSString *)value {
	return [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
			stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (void)startActivityIndicator {
	 UIApplication* app = [UIApplication sharedApplication];
	 app.networkActivityIndicatorVisible = YES;
}

- (void)stopActivityIndicator {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
}

#pragma mark Built In
-(NSString *) description {
	return [NSString stringWithFormat:@"Username = %@, Password = %@, URL = %@, auth = %@",
			username, password, url, auth];
}
@end
