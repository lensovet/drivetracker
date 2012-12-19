//
//  StatsViewController.m
//  cctracker
//
//  Created by Paul Borokhov on 12/27/09.
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

#import "StatsViewController.h"
#import "UIViewAdditions.h"
#import "DataCollector.h"

@implementation StatsViewController

- (void)viewDidUnload {
    [self setLastTripButton:nil];
    [self setStatselector:nil];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [_statselector release];
    [_lastTripButton release];
    [super dealloc];
}

- (void)setupTable {
    self.table = [[[CurrentTripViewController alloc] initWithNibName:@"TableView" bundle:nil] autorelease];
}

- (void)setupLTTable {
    self.archive = [[[ArchivedTripViewController alloc] initWithNibName:@"TableView" bundle:nil] autorelease];
    NSLog(@"%@", self.archive.view);
}

- (void) toggleTrip {
    if ([DataCollector sharedDataCollector].collectingData) {
            // add current summary view
        self.statselector.titleView = self.tripSelector;
        [self placeCurrentView];
    } else {
            // remove current summary view
        self.statselector.titleView = nil;
        [self placeArchiveView];
    }
}

- (void) placeArchiveView {
    if (!self.archive) [self setupLTTable];
    [self.tripPlaceholder replaceSubviewsWithControllerView:self.archive replacingOldView:self.table];
}

- (void) placeCurrentView {
    if (!self.table) [self setupTable];
    [self.tripPlaceholder replaceSubviewsWithControllerView:self.table replacingOldView:self.archive];
}

- (IBAction) toggleView:(id) sender {
    // 0 = current; 1 = prev
    if (self.statselector.titleView == nil) return;
    
    if (((UISegmentedControl*)sender).selectedSegmentIndex == 0) {
        [self placeCurrentView];
    } else {
        [self placeArchiveView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.tripSelector.selectedSegmentIndex == 0) [self.table viewWillDisappear:animated];
    else [self.archive viewWillDisappear:animated];
    self.table = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![DataCollector sharedDataCollector].collectingData) [self toggleTrip];
    else [self toggleView:self.tripSelector];
}

@end
