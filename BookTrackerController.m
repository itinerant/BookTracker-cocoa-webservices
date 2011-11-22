//
//  BookTrackerController.m
//  BookTracker
//
//  Created by Jon Doud on 8/4/08.
//  Copyright 2008 Jon Doud. All rights reserved.
//

#import "BookTrackerController.h"

@implementation BookTrackerController
- (id)init 
{
	[super init];
	
	// initialize arrays
	readers = [[NSArray alloc] initWithObjects: @"", @"Jon", @"Tibby", @"Emily", @"Rhys", @"Rebecca", @"Hannah", @"Jane", nil];
	months = [[NSArray alloc] initWithObjects: @"", @"Jan", @"Feb", @"Mar", @"Apr",
			  @"May", @"Jun", @"Jul", @"Aug", @"Sep",
			  @"Oct", @"Nov", @"Dec", nil];
	years = [[NSArray alloc] initWithObjects: @"", @"2012", @"2011", @"2010", @"2009", @"2008", @"2007", @"2006", 
			 @"2005", @"2004", @"2003", nil];
	NSCalendarDate *thisMonth = [NSCalendarDate calendarDate];
	currentMonths = [[NSArray alloc] initWithObjects: 
					 [[NSString alloc] initWithFormat:@"%@ %d", [months objectAtIndex:[thisMonth monthOfYear]-1], [thisMonth yearOfCommonEra]],
					 [[NSString alloc] initWithFormat:@"%@ %d", [months objectAtIndex:[thisMonth monthOfYear]], [thisMonth yearOfCommonEra]], 
					 nil];
	return self;
}

- (void)dealloc
{
	[readers release];
	[months release];
	[years release];
	[currentMonths release];
	[super dealloc];	
}

- (void)awakeFromNib 
{
	// set reader values
	[readerAdd removeAllItems];
	[readerFilter removeAllItems];
	[readerAdd addItemsWithTitles:readers];
	[readerFilter addItemsWithTitles:readers];
	
	// set genre values
	[genreFilter removeAllItems];
	[categoryFilter removeAllItems];
	
	// set month and year values
	[dateAdd removeAllItems];
	[dateAdd addItemsWithTitles:currentMonths];
	[dateAdd selectItemAtIndex:1];
	[monthFilter removeAllItems];
	[monthFilter addItemsWithTitles:months];
	[yearFilter removeAllItems];
	[yearFilter addItemsWithTitles:years];
	
	[self setControlData];
}

- (IBAction)filter:(id)sender 
{	
	// Set default search
	NSMutableString *allItems = [[NSMutableString alloc] initWithString:@"null"];
	NSMutableString *searchReader = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchTitle = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchAuthor = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchGenre = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchCategory = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchMonth = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchYear = [[NSMutableString alloc] initWithString:allItems]; 
	NSMutableString *searchAudiobook = [[NSMutableString alloc] initWithString:allItems];
	
	// reader
	if([readerFilter indexOfSelectedItem] != 0)
	{
		[searchReader setString:(@"%@", [readerFilter titleOfSelectedItem])];
	}
	// title
	if(![[titleFilter stringValue] isEqualToString:@""])
	{
		[searchTitle appendFormat:@"%@\%", [titleFilter stringValue]];
	}
	// author
	if(![[authorFilter stringValue] isEqualToString:@""])
	{
		[searchAuthor appendFormat:@"%@\%", [authorFilter stringValue]];
	}
	// genre
	if([genreFilter indexOfSelectedItem] != 0)
	{
		[searchGenre setString:(@"%@", [genreFilter titleOfSelectedItem])];
	}
	// category
	if([categoryFilter indexOfSelectedItem] != 0)
	{
		[searchCategory setString:(@"%@", [categoryFilter titleOfSelectedItem])];
	}
	// month
	if([monthFilter indexOfSelectedItem] != 0)
	{
		[searchMonth setString:(@"%@", [monthFilter titleOfSelectedItem])];
	}
	// year
	if([yearFilter indexOfSelectedItem] != 0)
	{
		[searchYear setString:(@"%@", [yearFilter titleOfSelectedItem])];
	}
	// audiobook
	if([[[audiobookFilter selectedCell] title] isEqualToString:@"Yes"])
	{
		[searchAudiobook setString:@"1"];
	}
	else if([[[audiobookFilter selectedCell] title] isEqualToString:@"No"])
	{
		[searchAudiobook setString:@"0"];
	}
	
	// Load table data
  NSMutableString *request = [[NSMutableString alloc] initWithFormat:@"http://doudfamily.dyndns.org/books/"];
	[request appendFormat:@"%@/", [self encodeString:searchReader]];
	[request appendFormat:@"%@/", [self encodeString:searchTitle]];
	[request appendFormat:@"%@/", [self encodeString:searchAuthor]];
	[request appendFormat:@"%@/", [self encodeString:searchGenre]];
	[request appendFormat:@"%@/", [self encodeString:searchCategory]];
	[request appendFormat:@"%@/", [self encodeString:searchMonth]];
	[request appendFormat:@"%@/", [self encodeString:searchYear]];
	[request appendFormat:@"%@", [self encodeString:searchAudiobook]];
	
	[searchReader release];
	[searchTitle release];
	[searchAuthor release];
	[searchGenre release];
	[searchCategory release];
	[searchMonth release];
	[searchYear release];
	[searchAudiobook release];
	
	NSXMLDocument *doc = [self callWebService:request];
	NSError *error;
	[itemNodes release];
	itemNodes = [[doc nodesForXPath:@"books/book" error:&error] retain];
	[table reloadData];
	[self setStatusFields];
	[request release];
	
}

- (IBAction)addBook:(id)sender 
{
	// required fields
	if([readerAdd indexOfSelectedItem] == 0 || [[titleAdd stringValue] isEqualToString:@""] ||
	   [[authorAdd stringValue] isEqualToString:@""] || [[genreAdd stringValue] isEqualToString:@""] ||
		([[pagesAdd stringValue] isEqualToString:@""] && [audiobookAdd state] == 0))
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Missing required fields!\n\nThe following fields are required:\nReader\nTitle\nAuthor\nGenre\n\nand one of\nPages or Audiobook"];
		[alert runModal];
		return;
	}
	
	NSMutableString *request = [[NSMutableString alloc] initWithFormat:@"http://doudfamily.dyndns.org/books"];
	[request appendFormat:@"?reader=%@", [readerAdd titleOfSelectedItem]];
	[request appendFormat:@"&title=%@", [self encodeString:[titleAdd stringValue]]];
	[request appendFormat:@"&author=%@", [self encodeString:[authorAdd stringValue]]];
	[request appendFormat:@"&genre=%@", [self encodeString:[genreAdd stringValue]]];
	if([[categoryAdd stringValue] compare:@""] != NSOrderedSame)
		[request appendFormat:@"&category=%@", [self encodeString:[categoryAdd stringValue]]];
	[request appendFormat:@"&date=%@", [self encodeString:[dateAdd titleOfSelectedItem]]];
	[request appendFormat:@"&pages=%@", [pagesAdd stringValue]];
	[request appendFormat:@"&audiobook=%d", [audiobookAdd intValue]];
  [request appendFormat:@"&isbn=%@", [isbnAdd stringValue]];
	[self postBook:request];

	// reset fields
	[self setControlData];

	// clear fields
	[titleAdd setStringValue:@""];
	[authorAdd setStringValue:@""];
	[genreAdd setStringValue:@""];
	[categoryAdd setStringValue:@""];
	[pagesAdd setStringValue:@""];
	[audiobookAdd setState:0];
}

- (IBAction)setCurrentSelection:(id)sender
{
	int row = [table selectedRow];
	[readerAdd setObjectValue:@""];
	[titleAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:1 row:row] stringValue]]];
	[authorAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:2 row:row] stringValue]]];
	[genreAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:3 row:row] stringValue]]];
	[categoryAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:4 row:row] stringValue]]];
	[pagesAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:6 row:row] stringValue]]];
	if([[[table preparedCellAtColumn:7 row:row] stringValue] compare:@"Yes"] == NSOrderedSame)
		[audiobookAdd setState:1];
	else 
		[audiobookAdd setState:0];
  [isbnAdd setObjectValue:[[NSString alloc] initWithFormat:@"%@", [[table preparedCellAtColumn:8 row:row] stringValue]]];
}

- (IBAction)clearFilters:(id)sender
{	
	[readerFilter setObjectValue:@""];
	[titleFilter setObjectValue:@""];
	[authorFilter setObjectValue:@""];
	[genreFilter setObjectValue:@""];
	[categoryFilter setObjectValue:@""];
	[monthFilter setObjectValue:@""];
	[yearFilter setObjectValue:@""];
	[audiobookFilter selectCellAtRow:0 column:2];
	
	[self filter:nil];
}

- (void)setControlData
{
	// Start progress animation
	[progress startAnimation:nil];
	
	// Load author data
  NSXMLDocument *doc = [self callWebService:@"http://doudfamily.dyndns.org/authors"];
	NSError *error;
	NSArray *nodes = [doc nodesForXPath:@"authors/author" error:&error];
	authors = [self arrayFromNodeArray:nodes];
	[authorAdd removeAllItems];
	[authorAdd addItemsWithObjectValues:authors];
	
	// Load genre data
  doc = [self callWebService:@"http://doudfamily.dyndns.org/genres"];
	nodes = [doc nodesForXPath:@"genres/genre" error:&error];
	genres = [self arrayFromNodeArray:nodes];
	[genreAdd removeAllItems];
	[genreFilter removeAllItems];
	[genreFilter addItemWithTitle:@""];
	[genreFilter addItemsWithTitles:genres];
	[genreAdd addItemsWithObjectValues:genres];
	
	// Load category data
  doc = [self callWebService:@"http://doudfamily.dyndns.org/categories"];
	nodes = [doc nodesForXPath:@"categories/category" error:&error];
	categories = [self arrayFromNodeArray:nodes];
	[categoryAdd removeAllItems];
	[categoryFilter removeAllItems];
	[categoryAdd addItemsWithObjectValues:categories];
	[categoryFilter addItemsWithTitles:categories];
	
	// Load books
	[self filter:nil];
	
	// scroll to end of list
	if([table numberOfRows] > 0)
		[table scrollRowToVisible:[table numberOfRows]-1];
	
	// update status fields
	[self setStatusFields];
	
	// Stop progress animation
	[progress stopAnimation:nil];
}

- (NSXMLDocument *)callWebService:(NSString *)request
{
	
	NSXMLDocument *doc;
	NSURL *url = [NSURL URLWithString:request];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
												cachePolicy:NSURLRequestReloadIgnoringCacheData
											timeoutInterval:30];
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	
	if(!urlData) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		return nil;
	}
	
	doc = [[NSXMLDocument alloc] initWithData:urlData options:0 error:&error];
	if(!doc) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		return nil;
	}
	
	return doc;
}

- (void)postBook:(NSString *)post
{ 
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];  
  
  NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
  
  NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
  [request setURL:[NSURL URLWithString:@"http://doudfamily.dyndns.org/books"]];  
  [request setHTTPMethod:@"POST"];  
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
  [request setHTTPBody:postData];  
  
  NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];  
  if (conn)   
  {  
    // inform the user that the post was successful  
  }   
  else   
  {  
    // inform the user that the post failed
  }  
}

- (NSArray *)arrayFromNodeArray:(NSArray *)nodeArray
{
	NSMutableArray *items = [[NSMutableArray alloc] init];
	int count = [nodeArray count];
	for(int i=0; i<count; i++)
	{
		[items addObject:[[nodeArray objectAtIndex:i] stringValue]];
	}
	return items;
}

- (NSString *)stringForPath:(NSString *)xp ofNode:(NSXMLNode *)n
{
	NSError *error;
	NSArray *nodes = [n nodesForXPath:xp error:&error];
	if(!nodes) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		return nil;
	}
	if([nodes count] == 0) {
		return nil;
	} else {
		if([xp compare:@"audiobook"] == NSOrderedSame) {
			if([[[nodes objectAtIndex:0] stringValue] compare:@"0"] == NSOrderedSame)
				return @"No";
			else 
				return @"Yes";

		}
		else
			return [[nodes objectAtIndex:0] stringValue];
	}
}

- (NSString*)encodeString:(NSString *)unencodedString
{
	
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
									   (CFStringRef)unencodedString,
															   NULL,
							(CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
											kCFStringEncodingUTF8 );
}

- (void)setStatusFields
{
	int count = [table numberOfRows];
	int pages = 0;
	int audiobooks = 0;
	for(int i=0; i<count; i++)
	{
		pages += [[table preparedCellAtColumn:6 row:i] intValue];
		if([[[table preparedCellAtColumn:7 row:i] stringValue] compare:@"Yes"] == NSOrderedSame)
			audiobooks++;
	}
	[audiobookTotal setStringValue:[[NSString alloc] initWithFormat:@"Audiobooks: %d", audiobooks]];
	if(pages > 1000)
		[pageTotal setStringValue:[[NSString alloc] initWithFormat:@"%d,%d", pages / 1000, pages % 1000]];
	else
		[pageTotal setStringValue:[[NSString alloc] initWithFormat:@"%d pages", pages]];
	[bookTotal setStringValue:[[NSString alloc] initWithFormat:@"Showing %d of %d books", count, count]];
	 
}

# pragma mark table data source methods
- (int)numberOfRowsInTableView:(NSTableView *)tv
{
	return [itemNodes count];
}

- (id)tableView:(NSTableView *)tv
	objectValueForTableColumn:(NSTableColumn *)tableColumn
						  row:(int)row

{
	NSXMLNode *node = [itemNodes objectAtIndex:row];
	NSString *xPath = [tableColumn identifier];
	return [self stringForPath:xPath ofNode:node];
}

@end

