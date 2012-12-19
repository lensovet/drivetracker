//
//  TableViewController.m
//  cctracker
//
//  Created by Paul Borokhov on 11/21/09.
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

#import "CurrentTripViewController.h"
#import "DataCollector.h"

@implementation CurrentTripViewController

static NSString *CellIdentifier = @"InfoTable";

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //NSLog(@"loading view...");
    [super viewDidLoad];
    self.categories = [NSArray arrayWithObjects:@"Trip info", @"Current GPS data", @"Accelerometer data", nil];
    NSArray *tripinfolabels = [NSArray arrayWithObjects:@"Average speed", @"Trip duration", nil];
    NSArray *gpsLabels = [NSArray arrayWithObjects:@"Longitude", @"Latitude", @"Speed", @"Precision", nil];
    NSArray *accLabels = [NSArray array]; //[NSArray arrayWithObjects:@"x", @"y", @"z", nil];
    self.labels = [NSArray arrayWithObjects:tripinfolabels, gpsLabels, accLabels, nil];
    self.rows = [NSMutableArray arrayWithCapacity:3];
    
    [self.rows addObject:[[DataCollector sharedDataCollector] tripData]];
    [self.rows addObject:[[DataCollector sharedDataCollector] GPSData]];
    [self.rows addObject:[[DataCollector sharedDataCollector] accelData]];    
    [[DataCollector sharedDataCollector] registerTableDS:self];
}

- (void)viewDidUnload {
    //NSLog(@"unloading view");
    [[DataCollector sharedDataCollector] registerTableDS:nil];
	self.labels = nil;
    self.rows = nil;
    self.categories = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"table appearing...");
    [[DataCollector sharedDataCollector] registerTableDS:self];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    //NSLog(@"table disappearing...");
    [[DataCollector sharedDataCollector] registerTableDS:nil];
    [super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; 
    if (cell == nil) { 
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease]; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell. 
    cell.textLabel.text = [[self.labels objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [[self.rows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.rows objectAtIndex:section] count] > 0) return [[self.rows objectAtIndex:section] count]-1;
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.categories objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSArray *items = [self.rows objectAtIndex:section];
    return [items objectAtIndex:[items count]-1];
}

// Contract: last row is always an NSDate object storing the last update time of the reading. We use it for the footer of the section and never display it as an actual row.
- (void)replaceRowsAtSection:(int)section withRows:(NSArray*)nrows {
    //NSLog(@"replacing sec %d!", section);
    @synchronized(self) {
        [self.rows replaceObjectAtIndex:section withObject:nrows];
        [(UITableView*) self.view reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)dealloc {
    //NSLog(@"deallocing");
    [super dealloc];
    [CellIdentifier release];
    // everything else has already been freed in viewDidUnload!
    //NSLog(@"...done");
}


@end
