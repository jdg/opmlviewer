/*

BSD License

Copyright (c) 2002, Brent Simmons
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

*	Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.
*	Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.
*	Neither the name of ranchero.com or Brent Simmons nor the names of its
	contributors may be used to endorse or promote products derived
	from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


*/

/*
	OPMLViewer.m
	OPMLViewer

	Created by Brent Simmons on Fri Aug 02 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
*/


#import "OPMLViewer.h"
#import "ImageAndTextCell.h"


@implementation OPMLViewer


- (void) awakeFromNib {
	
	/*
	Set a default URL. How 'bout the XML-RPC resources
	directory from UserLand.
	*/
	
	NSTableColumn *tableColumn = nil;
	ImageAndTextCell *imageAndTextCell = nil;

	[urlField setStringValue: @"http://www.xmlrpc.com/discuss/reader$1568.opml"];
	
	opml = nil;
	
	tableColumn = [outlineView tableColumnWithIdentifier: @"headline"];
	
	imageAndTextCell = [[[ImageAndTextCell alloc] init] autorelease];
	
	[imageAndTextCell setEditable: NO];
	
	[tableColumn setDataCell: imageAndTextCell];
	
	[outlineView setIntercellSpacing: NSMakeSize (5, 2)];
	
	[outlineView setTarget: self];

	[outlineView setDoubleAction: @selector (openInBrowser:)];
	
	linkImage = [[NSImage imageNamed: @"globe"] retain];
	} /*awakeFromNib*/


- (IBAction) viewOPML: (id) sender {
	
	NSURL *url = [NSURL URLWithString: [urlField stringValue]];
	
	[opml release];
	
	if (url != nil) {
		
		/*Get the OPML, parse it, then reload the outline.*/
		
		NSString *title;
		
		opml = [[OPML alloc] initWithURL: url];
		
		title = [[opml head] objectForKey: @"title"];
		
		if (title == nil)
			title = @"Untitled";
		
		[mainWindow setTitle: title];
				
		[outlineView reloadData];
		
		[self updateTextView];
		} /*if*/
	} /*viewOPML*/


- (IBAction) openInBrowser: (id) sender {
	
	NSString *link = [self getLink: [outlineView itemAtRow: [outlineView selectedRow]]];
	
	if (link == nil)
		return;
	
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: (link)]];	
	} /*openInBrowser*/


- (void) updateTextView {
	
	NSDictionary *item;
	NSEnumerator *enumerator;
	NSString *key;
	id oneItem;
	NSMutableString *s = [NSMutableString stringWithCapacity: 64]; /*whatever*/
	NSAttributedString *attString;
	
	if (opml == nil)
		return;

	item = [outlineView itemAtRow: [outlineView selectedRow]];
	
	enumerator = [item keyEnumerator];
		
	while (key = [enumerator nextObject]) {
		
		if ([key isEqualTo: @"text"])
			continue; /*Skip because it's displayed in the outline*/
			
		oneItem = [item objectForKey: key];
		
		if ([oneItem isKindOfClass: [NSString class]]) { /*NSStrings only*/

			[s appendString: [NSString stringWithFormat: @"%@: ", key]];
		
			[s appendString: oneItem];
		
			[s appendString: @"\n\n"];
			} /*if*/	
		} /*while*/
	
	attString = [[NSAttributedString alloc] initWithString: s];
	
	[[textView textStorage] setAttributedString: attString];
	
	[attString release];
	} /*updateTextView*/
	
	
/*Utility stuff*/


- (NSString *) getLink: (NSDictionary *) item {
		
	NSString *s = [item objectForKey: @"url"];
	
	if (s == nil)
		return (nil);
	
	return (s);
	} /*getLink*/

	
- (NSString *) getText: (NSDictionary *) item {
	
	/*
	Get the text element. If there isn't one, name it "No Text."
	*/
	
	NSString *s = [item objectForKey: @"text"];
	
	if (s == nil)
		return (@"No Text");
	
	return (s);
	} /*getText*/
	
	
- (NSArray *) getChildren: (NSDictionary *) item {	
	
	return [item objectForKey: @"_children"];	
	} /*getChildren*/


- (NSDictionary *) getNthItem: (int) index from: (NSDictionary *) item {
	
	NSArray *children = [self getChildren: item];
	
	return [children objectAtIndex: index];
	} /*getNthItem*/
	
	
- (int) countChildren: (NSDictionary *) item {
	
	NSArray *children = [self getChildren: item];
	
	if (children == nil)
		return (0);
	
	return ([children count]);	
	} /*countChildren*/
	

- (BOOL) hasChildren: (NSDictionary *) item {
	
	if ([self countChildren: item] > 0)
		return (YES);
	
	return (NO);
	} /*hasChildren*/
	
	
/*NSOutlineView data source methods*/

- (int) outlineView: (NSOutlineView *) outlineView numberOfChildrenOfItem: (id) item {

	if (opml == nil)
		return (0);
		
	if (item == nil)
		return [[opml body] count];
		
	return [self countChildren: item];
	} /*numberOfChildren*/


- (BOOL) outlineView: (NSOutlineView *) outlineView isItemExpandable: (id) item {

	if (opml == nil)
		return (NO);
		
	return [self hasChildren: item];
	} /*isItemExpandable*/
	

- (id) outlineView: (NSOutlineView *) outlineView child: (int) index ofItem: (id) item {
	
	if (opml == nil)
		return (nil);
		
	if (item == nil)
		return [[opml body] objectAtIndex: index];
	
	return [self getNthItem: index from: item];
	} /*child*/


- (id) outlineView: (NSOutlineView *) outlineView
	objectValueForTableColumn: (NSTableColumn *) tableColumn byItem: (id) item {

	return [self getText: item];
	} /*objectValueForTableColumn*/


- (void) outlineView: (NSOutlineView *) outlineView willDisplayCell: (id) cell
	forTableColumn: (NSTableColumn *) tableColumn item: (id) item {
	
	[cell setFont: [NSFont fontWithName: @"Lucida Grande" size: 11]];

	if ([self getLink: item] == nil)
		[(ImageAndTextCell*) cell setImage: nil];
	else
		[(ImageAndTextCell*) cell setImage: linkImage];
	} /*willDisplayCell*/


- (void) outlineViewSelectionDidChange: (NSNotification *) notification {
	
	[self updateTextView];
	} /*selectionDidChange*/



@end
