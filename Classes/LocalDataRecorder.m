//
//  LocalDataRecorder.m
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

#import "LocalDataRecorder.h"
#import "GTMNSDictionary+URLArguments.h"
#import "DataCollector.h"
#include <math.h>

@implementation LocalDataRecorder

- (id<DataRecorder>)sharedRecorder {
    if ((self = [super init])) {
        self.params = [DataCollector params];
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/%@.datalog", [[NSDate date] description]];
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:filepath contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        if (success) {
            self.file = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
            self.readbytes = 0;
        } else self.readbytes = -1;
    }
    return self;
}

- (void)recordDataForDate:(NSDate*)timestamp withLong:(double)longitude withLat:(double)latitude withPrecision:(double)precision withSpeed:(double)speed withAccelX:(double)accelx withAccelY:(double)accely withAccelZ:(double)accelz withCCStatus:(BOOL)cc {
    [self recordDataForDate:timestamp withLong:longitude withLat:latitude withPrecision:precision withSpeed:speed withAccelX:accelx withAccelY:accely withAccelZ:accelz withCCStatus:cc withODBSpeed:-1];
}

- (void)recordDataForDate:(NSDate*)timestamp withLong:(double)longitude withLat:(double)latitude withPrecision:(double)precision withSpeed:(double)speed withAccelX:(double)accelx withAccelY:(double)accely withAccelZ:(double)accelz withCCStatus:(BOOL)cc withODBSpeed:(double)odb_speed {
    NSArray *vals = [NSArray arrayWithObjects:[DataCollector sharedDataCollector].uuid, [NSString stringWithFormat:@"%ld", lround([timestamp timeIntervalSince1970])], [NSString stringWithFormat:@"%.4f", longitude], [NSString stringWithFormat:@"%.4f", latitude], [NSString stringWithFormat:@"%.4f", precision], [NSString stringWithFormat:@"%.4f", speed], [NSString stringWithFormat:@"%.4f", accelx], [NSString stringWithFormat:@"%.4f", accely], [NSString stringWithFormat:@"%.4f", accelz], cc ? @"t" : @"f", nil];
    
    if (self.readbytes < 0) return;
    [NSThread detachNewThreadSelector:@selector(writeDataToDisk:) toTarget:self withObject:vals];
}

- (void)writeDataToDisk:(id)vals {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjects:(NSArray*)vals forKeys:self.params];
    NSString *record = [[data gtm_httpArgumentsString] stringByAppendingString:@"\n"];
    @synchronized(self) {
        @try { [self.file writeData:[record dataUsingEncoding:NSUTF8StringEncoding]]; self.readbytes = [self.file offsetInFile]; }
        @catch (NSException * e) {
            // something bad happened. let's try to save & then stop writing.
            @try { [self saveFiles]; }
            @catch (NSException * e) { /* forget it */ }
            self.readbytes = -1;
        }
    }
    [pool drain];
}

- (void)applicationWillTerminate {
    // save state here!
    [self saveFiles];
}

- (void)saveFiles {
    if (self.readbytes >= 0) {
        [self.file synchronizeFile];
        [self.file closeFile];
    }    
}

- (void)dealloc {
    [self.file release];
    [self.params release];
    [super dealloc];
}

@end
