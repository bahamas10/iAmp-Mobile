//
//  untitled.h
//  Ampache
//
//  Created by David Eddy on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmpacheSession.h"

@interface AlbumsViewController: UITableViewController {
	NSMutableArray *data, *albums;
	AmpacheSession *ampache_conn;
}
@property (nonatomic, retain) NSMutableArray *data, *albums;

- (void)createSongsView:(int)row;

@end
