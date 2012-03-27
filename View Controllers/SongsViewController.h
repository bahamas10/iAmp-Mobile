//
//  untitled.h
//  Ampache
//
//  Created by David Eddy on 10/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AmpacheSession.h"
#import "AudioStreamer.h"

@interface SongsViewController: UITableViewController {
	NSMutableArray *data, *songs;
}
@property (nonatomic, retain) NSMutableArray *data, *songs;

- (void)playSong:(int)id;


@end
