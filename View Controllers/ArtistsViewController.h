//
//  ArtistsViewController.h
//  Ampache
//
//  Created by David Eddy on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmpacheSession.h"


@interface ArtistsViewController : UITableViewController {
	NSMutableArray *data, *artists;
	AmpacheSession *ampache_conn;
}

@property (nonatomic, retain) NSMutableArray *data, *artists;


- (void)createAlbumsView:(int)row;

@end
