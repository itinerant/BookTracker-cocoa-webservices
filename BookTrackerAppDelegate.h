//
//  BookTrackerAppDelegate.h
//  BookTracker
//
//  Created by Jon Doud on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BookTrackerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;
- (void)windowWillClose:(NSNotification *)aNotification;

@end
