//
//  ArchivedTripViewController.m
//  cctracker
//
//  Created by Paul Borokhov on 1/8/10.
//  Copyright 2010 Paul Borokhov. All rights reserved.
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

#import "ArchivedTripViewController.h"
#import "UnitConversions.h"

@implementation ArchivedTripViewController

static NSString *CellIdentifier = @"ArchiveTable";

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //NSLog(@"loading view...");
    [super viewDidLoad];
    self.format = [[[NSDateFormatter alloc] init] autorelease];
    [self.format setDateStyle:NSDateFormatterMediumStyle];
    [self.format setTimeStyle:NSDateFormatterShortStyle];
    self.lastupdate = nil;
    self.categories = [NSArray arrayWithObject:@"Trip info"];
    NSArray *tripinfolabels = [NSArray arrayWithObjects:@"Average speed", @"Duration", @"Start time", nil];
    self.labels = [NSArray arrayWithObject:tripinfolabels];
    self.rows = [NSMutableArray arrayWithCapacity:1];
    
    NSArray *tripdata = [self fetchLastTrip];
    if (tripdata) [self.rows addObject:tripdata];
}

- (NSArray*)fetchLastTrip {
    NSDate *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTstart"];
    int currentUnit = [[NSUserDefaults standardUserDefaults] integerForKey:@"useMetric"];
    if (start) {
        if (start != self.lastupdate || currentUnit != self.lastUnit) {
            self.lastupdate = start;
            self.lastUnit = currentUnit;
            double avgspeed = [[NSUserDefaults standardUserDefaults] doubleForKey:@"LTavgspeed"];
            int duration = [[NSUserDefaults standardUserDefaults] integerForKey:@"LTduration"];
            return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.3f %@", [UnitConversions convertSpeedToPreferredUnit:avgspeed], [UnitConversions userPreferredSpeedUnitDescription]], [UnitConversions readableStringForSeconds:duration], [self.format stringFromDate:start], nil];
        } else return nil;
    } else return [NSArray array];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    //NSLog(@"unloading view");
	self.labels = nil;
    self.rows = nil;
    self.categories = nil;
    self.format = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLog(@"table appearing...");
    [super viewWillAppear:animated];
    NSArray *tripdata = [self fetchLastTrip];
    if (tripdata) [self replaceRowsAtSection:0 withRows:tripdata];
}

- (void)viewWillDisappear:(BOOL)animated {
    //NSLog(@"table disappearing...");
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
    return [[self.rows objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.categories objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

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
    [super dealloc];
    [CellIdentifier release];
}

@end
