//
//  FirstTimeViewController.h
//  Ampache
//
//  Created by David Eddy on 11/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstTimeViewController : UIViewController {
	IBOutlet UIButton *dismissButton;
}

- (IBAction)dismissView:(id)sender;

@end
