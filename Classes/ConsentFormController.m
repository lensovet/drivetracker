//
//  ConsentFormController.m
//  cctracker
//
//  Created by Paul Borokhov on 3/29/10.
//  Copyright 2010 Paul Borokhov. All rights reserved.
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

#import "ConsentFormController.h"


@implementation ConsentFormController

- (void)showAlert:(id)origsender {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Consent to Participate in Research" message:NSLocalizedStringFromTable(@"consentMessage", nil, nil) delegate:self cancelButtonTitle:@"I Decline" otherButtonTitles:@"I Agree", nil] autorelease];
    self.sender = origsender;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // declined
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sendingCCITData"];
    } else {
        // accepted
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sendingCCITData"];
        // record date of acceptance
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"ccitAcceptanceDate"];
    }
    if (self.sender && [self.sender respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) [self.sender alertView:alertView clickedButtonAtIndex:buttonIndex];
    // release yourself!
    [self release];
}

@end
