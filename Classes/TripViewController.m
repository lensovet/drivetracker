//
//  FirstViewController.m
//  cctracker
//
//  Created by Paul Borokhov on 11/16/09.
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

#import "TripViewController.h"
#import "DataCollector.h"
#import "cctrackerAppDelegate.h"
#import "SettingsViewController.h"
#import "UIViewAdditions.h"
#import "MMRemoteDataRecorder.h"
#import "Insomniac.h"
#import "StatsViewController.h"

@implementation TripViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.tracking addTarget:[DataCollector sharedDataCollector] action:@selector(toggleDataCapture) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
    [self.starttripview release];
    [self.stoptripview release];
    [self.startstopplaceholder release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpStartStopViews:NO];
    [self setSendStatusLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction)toggleDataCapture:(id) sender {
    [self setUpStartStopViews:YES];
    [self setSendStatusLabel];
}

- (void)setSendStatusLabel {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sendingCCITData"]) {
        if ([DataCollector sharedDataCollector].collectingData) self.sendStatus.text = @"Data is being sent";
        else self.sendStatus.text = @"Data will be sent after trip starts";
    } else {
        if ([DataCollector sharedDataCollector].collectingData) self.sendStatus.text = @"Data is being aggregated locally only";
        else self.sendStatus.text = @"Data will only be aggregated locally";
    }
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self.view layer] addAnimation:animation forKey:@"statuslabel"];    
}

- (void) setUpStartStopViews:(BOOL) toggle {
    DataCollector *col = [DataCollector sharedDataCollector];
    BOOL recording = col.collectingData;
    if (toggle) {
        [col toggleDataCapture:nil];
        recording = !recording;
        UITabBarController *tc = ((cctrackerAppDelegate*)[UIApplication sharedApplication].delegate).tabBarController;
        if (tc.viewControllers.count > 1) {
            StatsViewController *sc = (StatsViewController*)tc.viewControllers[1];
            if (sc) [sc toggleTrip];
        }
    }
    [self swapStartStopViews:!recording];
}

- (void) swapStartStopViews:(BOOL) start {
    if (start)  [self.startstopplaceholder replaceSubviewsWithView:self.starttripview]; // set up start view
    else {
        NSArray *childs = self.stoptripview.subviews;
        UIButton *stop = [childs objectAtIndex:0];
        stop.frame = CGRectMake(0, 29, 292, 141);
        stop.titleLabel.font = [UIFont boldSystemFontOfSize:60];
        [self.startstopplaceholder replaceSubviewsWithView:self.stoptripview]; // set up stop/cc view
    }
}

- (void) sendErroredData:(id) sender {
    [[Insomniac sharedInsomniac] sendErroredData:sender];
}

- (IBAction) showSettingsView:(id) sender {
    SettingsViewController *settings = [[[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil] autorelease];
	settings.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    settings.view.frame = self.mainview.frame;
	[self presentModalViewController:settings animated:YES];
}

@end
