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
	NSString+extras.m
	NetNewsWire

	Created by Brent Simmons on Fri Jun 14 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
*/

#import "NSString+extras.h"


@implementation NSString (extras)


- (NSString *) replaceAll: (NSString *) searchFor with: (NSString *) replaceWith {

	NSArray *stringComponents = [self componentsSeparatedByString: searchFor];

	return [stringComponents componentsJoinedByString: replaceWith];
	} /*replaceAll*/


- (NSString *) convertEntities {
	
	NSString *s = [[self copy] autorelease];
	
	s = [s replaceAll: @"&" with: @"&amp;"];
	s = [s replaceAll: @">" with: @"&gt;"];
	s = [s replaceAll: @"<" with: @"&lt;"];
	s = [s replaceAll: @"\"" with: @"&quot;"];
	
	return (NSString *) [[s copy] autorelease];
	} /*convertEntities*/
	

- (NSString *) convertHighCharsToEntities {
	
	int len = [self length];
	NSMutableString *s = [NSMutableString stringWithCapacity: [self length]];
	int i;
	unichar ch;
	NSString *subString;
	
	for (i = 0; i < len; i++) {
		
		ch = [self characterAtIndex: i];
		
		if (ch < 128)
			subString = [self substringWithRange: NSMakeRange (i, 1)];
		else			
			subString = [NSString stringWithFormat: @"&%d;", ch];

		[s appendString: subString];
		} /*for*/
		
	return (NSString *) [s copy];
	} /*convertHighCharsToEntities*/
	
	
- (NSString *) trimWhiteSpace {
	
	NSMutableString *s = [[self mutableCopy] autorelease];
	
	CFStringTrimWhitespace ((CFMutableStringRef) s);

	return (NSString *) [[s copy] autorelease];
	} /*trimWhiteSpace*/


- (NSString *) ellipsizeAfterNWords: (int) n {
	
	NSArray *stringComponents = [self componentsSeparatedByString: @" "];
	NSMutableArray *componentsCopy = [stringComponents mutableCopy];
	int ix = n;
	int len = [componentsCopy count];
	
	if (len < n)
		ix = len;
	
	[componentsCopy removeObjectsInRange: NSMakeRange (ix, len - ix)];

	return [componentsCopy componentsJoinedByString: @" "];
	} /*ellipsizeAfterNWords*/


- (BOOL) isGoodURLString {
	
	NSURL *URL;
	
	if ([NSString stringIsEmpty: self])
		return (NO);
	
	if (![self hasPrefix: @"http://"])
		if (![self hasPrefix: @"file:///"])
			return (NO);
	
	URL = [NSURL URLWithString: self];
	
	if (URL == nil)
		return (NO);
		
	return (YES);	
	} /*isGoodURLString*/
	

- (NSString *) stripHTML {
	
	int len = [self length];
	NSMutableString *s = [NSMutableString stringWithCapacity: len];
	int i = 0, level = 0;
	
	for (i = 0; i < len; i++) {
		
		NSString *ch = [self substringWithRange: NSMakeRange (i, 1)];
		
		if ([ch isEqualTo: @"<"])
			level++;
		
		else if ([ch isEqualTo: @">"]) {
		
			level--;
			
			if (level == 0)			
				[s appendString: @" "];
			} /*else if*/
		
		else if (level == 0)			
			[s appendString: ch];
		} /*for*/
	
	return (NSString *) [[s copy] autorelease];
	} /*stripHTML*/


+ (NSString *) createLink: (NSString *) text withURL: (NSString *) URL {
	
	NSMutableString *link = [[[NSMutableString alloc] init] autorelease];
	
	[link appendString: @"<a href=\""];
	
	[link appendString: URL];
	
	[link appendString: @"\">"];
	
	[link appendString: text];
	
	[link appendString: @"</a>"];		

	return ((NSString *) [[link copy] autorelease]);
	} /*createLink*/


+ (BOOL) stringIsEmpty: (NSString *) s {

	NSString *copy;
	
	if (s == nil)
		return (YES);
	
	if ([s isEqualTo: @""])
		return (YES);
	
	copy = [[s copy] autorelease];
	
	if ([[copy trimWhiteSpace] isEqualTo: @""])
		return (YES);
		
	return (NO);
	} /*stringIsEmpty*/

@end
