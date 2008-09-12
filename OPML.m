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
	OPML.m
	NetNewsWire

	Created by Brent Simmons on Fri Jun 21 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
*/


#import "OPML.h"
#import "NSString+extras.h"


@implementation OPML


- (OPML *) initWithData: (NSData *) d {
	
	CFXMLTreeRef tree;
	
	tree = CFXMLTreeCreateFromData (kCFAllocatorDefault, (CFDataRef) d,
			NULL,  kCFXMLParserSkipWhitespace, kCFXMLNodeCurrentVersion);
	
	if (tree == nil) {
		
		/*If there was a problem parsing the OPML file,
		raise an exception.*/
	
		NSException *exception = [NSException exceptionWithName: @"OPMLParseFailed"
			reason: @"The XML parser could not parse the OPML data." userInfo: nil];
		
		[exception raise];
		} /*if*/
	
	[self createheaderdictionary: tree];

	[self createbodyarray: tree];
	
	CFRelease (tree);

	return (self);
	} /*initWithData*/
	

- (OPML *) initWithURL: (NSURL *) url {
	
	NSURLHandle *urlHandle;
	NSData *d;
	
	urlHandle = [url URLHandleUsingCache: NO];

	d = [urlHandle resourceData];
	
	if ([urlHandle status] == NSURLHandleLoadFailed) {
		
		/*If there was a problem reading the file,
		raise an exception.*/
		
		NSException *exception = [NSException exceptionWithName: @"OPMLDownloadFailed"
			reason: [urlHandle failureReason] userInfo: nil];

		[exception raise];
		} /*if*/
	
	if (d == nil) {
		
		/*Another possible error.*/
		
		NSException *exception = [NSException exceptionWithName: @"OPMLNoData"
			reason: @"Unknown error." userInfo: nil];

		[exception raise];
		} /*if*/
	
	return [self initWithData: d];	
	} /*initWithUrl*/


- (NSDictionary *) head {
	
	return (head);
	} /*head*/
	

- (NSArray *) body {
	
	return (body);
	} /*body*/
	
	
/*Private*/


- (void) additemsfromtree: (CFXMLTreeRef) tree into: (NSMutableArray *) items {
	
	CFXMLTreeRef childTree;
	CFXMLNodeRef childNode;
	NSString *childName;
	int childCount, itemChildCount, i;
	
	childCount = CFTreeGetChildCount (tree);
	
	for (i = 0; i < childCount; i++) {
		
		NSMutableDictionary *itemDictionaryMutable;
		
		childTree = CFTreeGetChildAtIndex (tree, i);
		
		childNode = CFXMLTreeGetNode (childTree);
		
		childName = (NSString *) CFXMLNodeGetString (childNode);
		
		itemDictionaryMutable = [NSMutableDictionary dictionaryWithCapacity: 1];
		
		[self flattenitemattributes: childNode into: itemDictionaryMutable];
		
		itemChildCount = CFTreeGetChildCount (childTree);
		
		if (itemChildCount > 0) {
			
			NSMutableArray *childItems = [NSMutableArray arrayWithCapacity: itemChildCount];
			
			[self additemsfromtree: childTree into: childItems]; /*recurse*/
		
			[itemDictionaryMutable setObject: childItems forKey: @"_children"];
			} /*if*/

		[items addObject: itemDictionaryMutable];
		} /*for*/
	} /*additemsfromtree*/
	
	
- (void) createbodyarray: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef bodyTree;
	NSMutableArray *itemsArrayMutable;
	
	bodyTree = [self getbodytree: tree];
	
	if (bodyTree == nil) {
		
		NSException *exception = [NSException exceptionWithName: @"OPMLParserCreateBodyArrayFailed"
			reason: @"Couldn’t find the outline items." userInfo: nil];

		[exception raise];
		} /*if*/
	
	itemsArrayMutable = [NSMutableArray arrayWithCapacity: 1];
	
	[self additemsfromtree: bodyTree into: itemsArrayMutable];
		
	body = [itemsArrayMutable copy];
	} /*createbodyarray*/


- (void) flattenitemattributes: (CFXMLNodeRef) node into: (NSMutableDictionary *) dictionary {
	
	const CFXMLElementInfo *elementInfo;
	NSDictionary *orig;
	NSMutableDictionary *copy;
	NSEnumerator *enumerator;
	NSString *key;
	
	elementInfo = CFXMLNodeGetInfoPtr (node);
	
	orig = (NSDictionary *) (*elementInfo).attributes;
	
	copy = [orig mutableCopy];
	
	enumerator = [copy keyEnumerator];
	
	while (key = [enumerator nextObject]) {
		
		NSString *item = [copy objectForKey: key];
		NSString *newItem = [item replaceAll: @"&amp;" with: @"&"];
		
		[copy setObject: newItem forKey: key];
		} /*while*/
		
	[dictionary addEntriesFromDictionary: copy];
	
	[copy autorelease];
	} /*flattenitemattributes*/


- (CFXMLTreeRef) getopmltree: (CFXMLTreeRef) tree {
	
	return [self getnamedtree: tree name: @"opml"];
	} /*getopmltree*/
	

- (CFXMLTreeRef) getbodytree: (CFXMLTreeRef) tree {
	
	return [self getsubtree: tree subTreeName: @"body"];
	} /*getbodytree*/


- (CFXMLTreeRef) getheadtree: (CFXMLTreeRef) tree {
	
	return [self getsubtree: tree subTreeName: @"head"];
	} /*getheadtree*/


- (CFXMLTreeRef) getsubtree: (CFXMLTreeRef) tree subTreeName: (NSString *) name {
	
	CFXMLTreeRef opmlTree = [self getopmltree: tree];
	
	if (opmlTree == nil)
		return (nil);
	
	return [self getnamedtree: opmlTree name: name];
	} /*getsubtree*/
	

- (CFXMLTreeRef) getnamedtree: (CFXMLTreeRef) currentTree name: (NSString *) name {
	
	int childCount, index;
	CFXMLNodeRef xmlNode;
	CFXMLTreeRef xmlTreeNode;
	NSString *itemName;
	
	childCount = CFTreeGetChildCount (currentTree);
	
	for (index = childCount - 1; index >= 0; index--) {
		
		xmlTreeNode = CFTreeGetChildAtIndex (currentTree, index);
		
		xmlNode = CFXMLTreeGetNode (xmlTreeNode);
		
		itemName = (NSString *) CFXMLNodeGetString (xmlNode);
		
		if ([itemName isEqualToString: name])
			return (xmlTreeNode);
		} /*for*/
	
	return (nil);
	} /*getnamedtree*/


- (void) createheaderdictionary: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef headTree, childTree;
	CFXMLNodeRef childNode;
	int childCount, i;
	NSString *childName, *childValue;
	NSMutableDictionary *headerItemsMutable;
	
	headerItemsMutable = [NSMutableDictionary dictionaryWithCapacity: 1];
		
	headTree = [self getheadtree: tree];
	
	if (headTree == nil) {
	
		NSException *exception = [NSException exceptionWithName: @"OPMLCreateHeaderDictionaryFailed"
			reason: @"Couldn’t find the <head> tree." userInfo: nil];

		[exception raise];
		} /*if*/

	childCount = CFTreeGetChildCount (headTree);
	
	for (i = 0; i < childCount; i++) {
		
		childTree = CFTreeGetChildAtIndex (headTree, i);
		
		childNode = CFXMLTreeGetNode (childTree);
		
		childName = (NSString *) CFXMLNodeGetString (childNode);
		
		childValue = [self getelementvalue: childTree];
				
		[headerItemsMutable setObject: childValue forKey: childName];
		} /*for*/
	
	head = [headerItemsMutable copy];
	} /*createheaderdictionary*/


- (NSString *) getelementvalue: (CFXMLTreeRef) tree {
	
	CFXMLNodeRef node;
	CFXMLTreeRef itemTree;
	int childCount, ix;
	NSMutableString *valueMutable;
	NSString *value;
	NSString *name;
	
	childCount = CFTreeGetChildCount (tree);
	
	valueMutable = [[NSMutableString alloc] init];
	
	for (ix = 0; ix < childCount; ix++) {
		
		itemTree = CFTreeGetChildAtIndex (tree, ix);
		
		node = CFXMLTreeGetNode (itemTree);
		
		name = (NSString *) CFXMLNodeGetString (node);
		
		if (name != nil) {
		
			if (CFXMLNodeGetTypeCode (node) == kCFXMLNodeTypeEntityReference) {
				
				if ([name isEqualTo: @"lt"])
					name = @"<";

				if ([name isEqualTo: @"gt"])
					name = @">";
				
				if ([name isEqualTo: @"quot"])
					name = @"\"";
				
				if ([name isEqualTo: @"amp"])
					name = @"&";				
				} /*if*/
						
			[valueMutable appendString: name];
			} /*if*/
		} /*for*/
	
	value = [valueMutable copy];
	
	[valueMutable autorelease];

	return ([value autorelease]);
	} /*getelementvalue*/


@end
