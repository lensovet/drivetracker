//
//  cctrackerAppDelegate.m
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

#import "cctrackerAppDelegate.h"
#import "DataCollector.h"
#import "Insomniac.h"
#import "ConsentFormController.h"

@implementation cctrackerAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.rootViewController = self.tabBarController;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"allowLocking"]) [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"allowLocking"];

    self.hasLocalData = NO;
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",WaitingDataFilename];    
    if ([[NSFileManager defaultManager] isWritableFileAtPath:filepath]) {
        // see if maybe the file is empty first
        if ([[NSFileHandle fileHandleForUpdatingAtPath:filepath] seekToEndOfFile] != 0) self.hasLocalData = YES;
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunchComplete"]) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uidstring = (NSString*) CFUUIDCreateString(NULL, uuid);
        [[NSUserDefaults standardUserDefaults] setObject:uidstring forKey:@"uuid"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunchComplete"];
        [uidstring release];
        CFRelease(uuid);
        [[[ConsentFormController alloc] init] showAlert:self];
    }
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey] != nil) {
        // we got relaunched after getting killed. what should we do?
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"tripid"]) [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"tripid"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"dropzeroes"]) [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dropzeroes"];
    
    [NSThread detachNewThreadSelector:@selector(checkDropzeroBehavior:) toTarget:self withObject:nil];
    
    return YES;
}

- (void)checkDropzeroBehavior:(id)userinfo {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // call some URL which will return a plist
    NSDictionary *prefs = nil; //= [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]] mutabilityOption:0 format:NULL errorDescription:nil];
    // read value and set it locally
    if (prefs) [[NSUserDefaults standardUserDefaults] setBool:[[prefs objectForKey:@"dropzeroes"] boolValue] forKey:@"dropzeroes"];
    [pool release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // called when application is killed (in iOS 4+) or when user has decided to respond to an alert (in earlier iOS versions)
    [[DataCollector sharedDataCollector] applicationWillTerminate];
    application.idleTimerDisabled = NO;
    [[Insomniac sharedInsomniac] stopPlayback];
    // TODO: save current routing state
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // called when application is moved to the background for some reason in iOS 4+
    /*  Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. You should also disable updates to your application’s user interface and avoid using some types of shared system resources (such as the user’s contacts database).
     
     Your implementation of this method has approximately five seconds to perform any tasks and return. If you need additional time to perform any final tasks, you can request additional execution time from the system.*/
    // TODO: stop all UI updates, including appearing of "data waiting" view
    // TODO: save trip state for later restoring.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /* this method is called as part of the transition from the background to the inactive state. You can use this method to undo many of the changes you made to your application upon entering the background. The call to this method is invariably followed by a call to the applicationDidBecomeActive: method, which then moves the application from the inactive to the active state. */
    // TODO: refresh UI, restore trip
}

- (void)setHasLocalData:(BOOL)new {
    BOOL old = self.hasLocalData;
    _hasLocalData = new;
    if (new != old) [[NSNotificationCenter defaultCenter] postNotificationName:HasLocalDataValueChangedNotification object:nil];
}

// Make MobileSubstrate happy with the delegate methods it expects
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /* The delegate can implement this method to make adjustments when the application transitions from an inactive state to an active state. See below for when an application is inactive.
     
     Just after it becomes active, the application also posts a UIApplicationDidBecomeActiveNotification. */
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /* The delegate can implement this method to make adjustments when the application transitions from an active state to an inactive state. When an application is inactive, it is executing but is not dispatching incoming events. This occurs when an overlay window pops up or when the device is locked. In iOS 4+, this also occurs when the user quits the application and it begins the transition to the background state. An application in the inactive state continues to run but does not dispatch incoming events to responders.
     
     Just before it becomes inactive, the application also posts a UIApplicationWillResignActiveNotification. */
}

- (void)datacollectionStarted {
    [[Insomniac sharedInsomniac] startDatacollection];
}

- (void)datacollectionEnded {
    [[Insomniac sharedInsomniac] stopDatacollection];
}

- (void)dealloc {
    [self.tabBarController release];
    [self.window release];
    [super dealloc];
}

@end

