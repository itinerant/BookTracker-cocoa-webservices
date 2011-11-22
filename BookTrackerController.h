//
//  BookTrackerController.h
//  BookTracker
//
//  Created by Jon Doud on 8/4/08.
//  Copyright 2008 Jon Doud. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BookTrackerController : NSObject {
	// add controls
	IBOutlet NSPopUpButton *readerAdd;
	IBOutlet NSTextField *titleAdd;
	IBOutlet NSComboBox *authorAdd;
	IBOutlet NSComboBox *genreAdd;
	IBOutlet NSComboBox *categoryAdd;
	IBOutlet NSPopUpButton *dateAdd;
	IBOutlet NSButton *audiobookAdd;
	IBOutlet NSTextField *pagesAdd;
  IBOutlet NSTextField *isbnAdd;
	IBOutlet NSProgressIndicator *progress;
	
	// filter controls
	IBOutlet NSPopUpButton *readerFilter;
	IBOutlet NSSearchField *titleFilter;
	IBOutlet NSSearchField *authorFilter;
	IBOutlet NSPopUpButton *genreFilter;
	IBOutlet NSPopUpButton *categoryFilter;
	IBOutlet NSPopUpButton *monthFilter;
	IBOutlet NSPopUpButton *yearFilter;
	IBOutlet NSMatrix *audiobookFilter;
	
	// totals labels
	IBOutlet NSTextField *audiobookTotal;
	IBOutlet NSTextField *bookTotal;
	IBOutlet NSTextField *pageTotal;
	
	// table
	IBOutlet NSTableView *table;
	
	// elements
	NSArray *readers;
	NSArray *months;
	NSArray *years;
	NSArray *currentMonths;
	NSArray *itemNodes;
	
	// sort descriptors
	NSArray *authors;
	NSArray *genres;
	NSArray *categories;
}
- (IBAction)filter:(id)sender;
- (IBAction)addBook:(id)sender;
- (IBAction)setCurrentSelection:(id)sender;
- (IBAction)clearFilters:(id)sender;
- (void)setControlData;
- (NSXMLDocument *)callWebService:(NSString *)request;
- (void)postBook:(NSString *)post;
- (NSArray *)arrayFromNodeArray:(NSArray *)nodeArray;
- (NSString*)encodeString:(NSString *)unencodedString;
- (void)setStatusFields;

@end
