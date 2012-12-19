//
//  StatsViewController.h
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

#import <UIKit/UIKit.h>
#import "CurrentTripViewController.h"
#import "ArchivedTripViewController.h"

@interface StatsViewController : UIViewController {

}
- (IBAction) toggleView:(id) sender;
- (void) toggleTrip;

@property(readonly, nonatomic, assign) IBOutlet UISegmentedControl *tripSelector;
@property(readonly, nonatomic, assign) IBOutlet UIView *tripPlaceholder;
@property (retain, nonatomic) IBOutlet UINavigationItem *statselector;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *lastTripButton;
@property(readwrite, nonatomic, retain) CurrentTripViewController *table;
@property(readwrite, nonatomic, retain) ArchivedTripViewController *archive;

@end
