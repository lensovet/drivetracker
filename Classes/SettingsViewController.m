//
//  SettingsViewController.m
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

#import "SettingsViewController.h"
#import "UIViewAdditions.h"
#import "ConsentFormController.h"
#import "Insomniac.h"
#import "DataCollector.h"

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCCITLabels];
    self.metric.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"useMetric"];
    [self updateOBDViews];
    self.lockingtoggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"allowLocking"];
    [self updateUUIDLabel];
}

- (void)dealloc {
    [super dealloc];
}

- (void)updateUUIDLabel {
    self.uuid.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
}

- (void)updateCCITLabels {
    BOOL accepted = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendingCCITData"];
    if (accepted) {
        [self.ccit setTitle:@"Stop sending data" forState:UIControlStateNormal];
        self.explanation.text = [NSString stringWithFormat:@"Your data is currently being sent since %@", [[DataCollector sharedDataCollector].dateformatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"ccitAcceptanceDate"]]];
    } else {
        [self.ccit setTitle:@"Start sending data" forState:UIControlStateNormal];
        self.explanation.text = @"You must consent to sending data before it can be transmitted.";
    }
}

- (IBAction) done:(id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) toggleDataSending:(id) sender {
    BOOL accepted = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendingCCITData"];
    if (accepted) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendingCCITData"];
        [self updateCCITLabels];
    } else {
        // present alert
        [[[ConsentFormController alloc] init] showAlert:self];
    }
}

- (IBAction) toggleUnits:(id) sender {
    // imperial = 0; metric = 1; SI = 2
    // defined in UnitConversions.h
    [[NSUserDefaults standardUserDefaults] setInteger:((UISegmentedControl*)sender).selectedSegmentIndex forKey:@"useMetric"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self updateCCITLabels];
}

- (IBAction) setupOBD:(id) sender {
    // for now, just swap views and set pref
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"OBD not implemented" message:@"OBD support is currently not implemented, but will be added in a future version!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Great", nil] autorelease];
    [alert show];
    /*BOOL obdsetup = [[NSUserDefaults standardUserDefaults] boolForKey:@"OBDSetupComplete"];
    if (obdsetup) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OBDSetupComplete"];
        [self updateOBDViews];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OBDSetupComplete"];
        [self updateOBDViews];
    }*/
}

- (IBAction) disconnectOBD:(id) sender {
    // for now, just swap views and set pref
    BOOL obdsetup = [[NSUserDefaults standardUserDefaults] boolForKey:@"OBDSetupComplete"];
    if (!obdsetup) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OBDSetupComplete"];
        [self updateOBDViews];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OBDSetupComplete"];
        [self updateOBDViews];
    }
}

- (void)updateOBDViews {
    BOOL obdsetup = [[NSUserDefaults standardUserDefaults] boolForKey:@"OBDSetupComplete"];
    if (obdsetup) [self.obdPlaceholder replaceSubviewsWithView:self.obdDisconnect]; // set up Disconnect view
    else [self.obdPlaceholder replaceSubviewsWithView:self.obdSetup]; // set up Set up... view
}

- (IBAction) toggleScreenLock:(id) sender {
    if (((UISwitch*)sender).on) {
        [[Insomniac sharedInsomniac] setMustDisableIdleTimer:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"allowLocking"];
    }
    else {
        [[Insomniac sharedInsomniac] setMustDisableIdleTimer:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"allowLocking"];
    }
}

@end
