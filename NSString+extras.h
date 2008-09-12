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
	NSString+extras.h
	NetNewsWire

	Created by Brent Simmons on Fri Jun 14 2002.
	Copyright (c) 2002 Brent Simmons. All rights reserved.
*/


#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>


@interface NSString (extras)


- (NSString *) replaceAll: (NSString *) searchFor with: (NSString *) replaceWith;

- (NSString *) convertEntities;

- (NSString *) convertHighCharsToEntities;

- (NSString *) trimWhiteSpace;

- (NSString *) stripHTML;

- (NSString *) ellipsizeAfterNWords: (int) n;

- (BOOL) isGoodURLString;

+ (NSString *) createLink: (NSString *) text withURL: (NSString *) URL;

+ (BOOL) stringIsEmpty: (NSString *) s;


@end