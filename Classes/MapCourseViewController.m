//
//  MapCourseViewController.m
//  cctracker
//
//  Created by Paul Borokhov on 12/25/09.
//  Copyright 2009, 2010 Paul Borokhov. All rights reserved.
//
/*
 **
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * DriveTracker is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
//

#import "MapCourseViewController.h"
#import "DataCollector.h"
#import "YAJL.h"
#include <unistd.h>

@implementation MapCourseViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	[self.map release];
}

- (void)viewWillAppear:(BOOL)animated {
    [[DataCollector sharedDataCollector] registerMap:self.map];
    [self.map setDelegate:self];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[DataCollector sharedDataCollector] registerMap:nil];
    [self.map setDelegate:nil];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [super dealloc];
}

@end

@implementation NSString (ComparisonAdditions)

- (NSComparisonResult)numericCompare:(NSString *)aString {
    switch ([self compare:aString options:NSNumericSearch]) {
        case NSOrderedAscending:
            return NSOrderedDescending;
        case NSOrderedDescending:
            return NSOrderedAscending;
        default:
            return NSOrderedSame;
    }
}

@end

