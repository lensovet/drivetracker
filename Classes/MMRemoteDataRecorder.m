//
//  MMRemoteDataRecorder.m
//  cctracker
//
//  Created by Paul Borokhov on 11/29/09.
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

#import "MMRemoteDataRecorder.h"
#import "GTMNSDictionary+URLArguments.h"
#import "DataCollector.h"
#import "cctrackerAppDelegate.h"
#include <math.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "UIDeviceHardware.h"

@implementation MMRemoteDataRecorder

static NSString *phonemodel = nil;

- (id<DataRecorder>)sharedRecorder {
    if ((self = [super init])) {
        self.params = [DataCollector params];
        [self reinitializeFallbackHandle];
        phonemodel = [[UIDeviceHardware platform] retain];
    }
    return self;
}

- (void)reinitializeFallbackHandle {
    NSString *filepath = WaitingDataFilename;
    BOOL success = NO;
    filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",filepath];
    
    if ([[NSFileManager defaultManager] isWritableFileAtPath:filepath]) success = YES;
    else success = [[NSFileManager defaultManager] createFileAtPath:filepath contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    if (success) {
        self.cachefile = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
        [self.cachefile seekToEndOfFile];
        self.readbytes = 0;
    } else self.readbytes = -1;//*/
}

- (void)recordDataForDate:(NSDate*)timestamp withLong:(double)longitude withLat:(double)latitude withPrecision:(double)precision withSpeed:(double)speed withAccelX:(double)accelx withAccelY:(double)accely withAccelZ:(double)accelz withCCStatus:(BOOL)cc {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sendingCCITData"]) [self recordDataForDate:timestamp withLong:longitude withLat:latitude withPrecision:precision withSpeed:speed withAccelX:accelx withAccelY:accely withAccelZ:accelz withCCStatus:cc withODBSpeed:-1];
}

- (void)recordDataForDate:(NSDate*)timestamp withLong:(double)longitude withLat:(double)latitude withPrecision:(double)precision withSpeed:(double)speed withAccelX:(double)accelx withAccelY:(double)accely withAccelZ:(double)accelz withCCStatus:(BOOL)cc withODBSpeed:(double)odb_speed {
    NSArray *vals = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", lrint([timestamp timeIntervalSince1970])], [NSString stringWithFormat:@"%.6f", longitude], [NSString stringWithFormat:@"%.6f", latitude], [NSString stringWithFormat:@"%.4f", precision], [NSString stringWithFormat:@"%.4f", speed], /*[NSString stringWithFormat:@"%.4f", accelx], [NSString stringWithFormat:@"%.4f", accely], [NSString stringWithFormat:@"%.4f", accelz], cc ? @"t" : @"f", [NSString stringWithFormat:@"%.4f", odb_speed],*/ nil];
    
    [NSThread detachNewThreadSelector:@selector(writeDataToDisk:) toTarget:self withObject:vals];
}

- (void)writeDataToDisk:(id)vals {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjects:(NSArray*)vals forKeys:self.params];
    NSString *record = [data gtm_httpArgumentsString];
    // FIXME: version 1 of batching, simply "fail" all initial requests
    // if we're still here, something went wrong. write data to the file and move on.
    @synchronized([[UIApplication sharedApplication] delegate]) {
        @try { [self.cachefile writeData:[[record stringByAppendingFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]]; self.readbytes = [self.cachefile offsetInFile]; }
        @catch (NSException * e) {
            // something bad happened. let's try to save & then stop writing.
            @try { [self saveFiles]; }
            @catch (NSException * e) { /* forget it */ }
            self.readbytes = -1;
        }//*/
    }
    if (self.readbytes != -1) ((cctrackerAppDelegate*)[[UIApplication sharedApplication] delegate]).hasLocalData = YES;
    [pool drain];
}

+ (BOOL)makeURLRequest:(NSString*)data {
    NSError *err = nil;
    [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://www.lensovet.net/~untouchable/drivetracker//"]]; //@"http://drivetracker.appspot.com/"]];
    [request setPostValue:[DataCollector sharedDataCollector].uuid forKey:@"id"];
    [request setPostValue:data forKey:@"data"];
    [request setPostValue:@"cc_3" forKey:@"app"];
    [request setPostValue:phonemodel forKey:@"dev"];
    [request setPostValue:[UIDevice currentDevice].systemVersion forKey:@"os"];
    [request setPostValue:[NSString stringWithFormat:@"%d", [DataCollector sharedDataCollector].tripid] forKey:@"tripid"];
    [request startSynchronous];
    err = [request error];
    if (request) {
        if ([request responseStatusCode] == 200 || [request responseStatusCode] == 502) {
            // success!
            // 502 represents a DeadlineExceededError. we're never going to get around this, so just bail.
            //NSLog(@"Wrote data to server");
            return YES;
        } else if ([request responseStatusCode] == 412) {
            // "duplicate" data - we already have this UUID,timestamp value in the database. just drop and continue.
            //NSLog(@"Duplicate record in DB, so dropping");
            return YES;
        } else NSLog(@"non-200 code returned while resending data, code %d, data %@", [request responseStatusCode], data);
    } else NSLog(@"connection failed while resending data! %@", [err description]);
    return NO;
}

- (void)applicationWillTerminate {
    // save state here!
    [self saveFiles];
}

- (void)saveFiles {
    if (self.readbytes >= 0) {
        [self.cachefile synchronizeFile];
        [self.cachefile closeFile];
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@",WaitingDataFilename];
        NSArray *lines = [[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
        int num = 0;
        for (NSString *item in lines) {
            if ([item isEqualToString:@""]) continue;
            else {
                num++;
                break;
            }
        }
        if (num == 0) [[NSFileManager defaultManager] removeItemAtPath:filepath error:NULL];
    }    
}

- (void)dealloc {
    [self.cachefile release];
    [self.params release];
    [super dealloc];
}

@end
