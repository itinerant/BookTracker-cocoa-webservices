//
//  BookTrackerAppDelegate.m
//  BookTracker
//
//  Created by Jon Doud on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BookTrackerAppDelegate.h"

@implementation BookTrackerAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

- (void)windowWillClose:(NSNotification *)aNotification 
{
	[NSApp terminate:self];
}

@end
