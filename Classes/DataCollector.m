//
//  DataCollector.m
//  cctracker
//
//  Created by Paul Borokhov on 11/20/09.
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

#import "DataCollector.h"
#import "CurrentTripViewController.h"
#import "MMRemoteDataRecorder.h"
#import "UnitConversions.h"
#import "cctrackerAppDelegate.h"

@implementation DataCollector

SYNTHESIZE_SINGLETON_FOR_CLASS(DataCollector);

+ (NSArray*)params {
    return [NSArray arrayWithObjects:/*@"id",*/ @"t", @"o", @"a", @"p", @"g_s" /*, @"x", @"y", @"z", @"c", @"o_s" for ODB speed, @"app"*/, nil];
}

-(id) init {
    if ((self = [super init])) {
        self.uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uuid"];
        self.recorder = [[MMRemoteDataRecorder alloc] sharedRecorder];
        self.collectingData = NO;
        self.longitude = 0;
        self.latitude = 0;
        self.lastlatitude = 0;
        self.lastlongitude = 0;
        self.speed = -1;
        self.odb_speed = -1;
        self.precision = 0;
        self.locLastUpdate = [NSDate date]; //[NSDate dateWithTimeIntervalSince1970:0];
        self.accLastUpdate = self.locLastUpdate; //[NSDate dateWithTimeIntervalSince1970:0];
        self.dateformatter = [[NSDateFormatter alloc] init];
        [self.dateformatter setDateStyle:NSDateFormatterFullStyle];
        [self.dateformatter setTimeStyle:NSDateFormatterMediumStyle];
        [self.dateformatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        self.accx = 0;
        self.accy = 0;
        self.accz = 0;
        self.map = nil;
        self.source = nil;
        self.locmanager = nil;
        self.speedstats = [[ACSummaryPositiveStatistics alloc] init];
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"location update received");
    if (!self.collectingData) {
        //NSLog(@"not collecting data, ending loc updates");
        [manager stopUpdatingLocation];
        return;
    }
    self.longitude = newLocation.coordinate.longitude;
    self.latitude = newLocation.coordinate.latitude;
    self.speed = newLocation.speed;
    [self.speedstats addValue:self.speed];
    self.precision = newLocation.horizontalAccuracy;
    self.locLastUpdate = newLocation.timestamp;
    BOOL locationChanged = YES;
    // optimization: if location hasn't changed and speed is 0, just return
    if (self.longitude == self.lastlongitude && self.latitude == self.lastlatitude && self.speed == 0.0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"dropzeroes"]) {
        locationChanged = NO;
    } else {
        self.lastlatitude = self.latitude;
        self.lastlongitude = self.longitude;
    }

    //NSLog(@"Contemplating telling source about our changes, we're instance %@", self);
    if (self.source) {
        [self.source replaceRowsAtSection:0 withRows:[self tripData]];
        [self.source replaceRowsAtSection:1 withRows:[self GPSData]];
    }
    
    if (locationChanged) {
        if (self.map) {
            double span = self.precision > 150 ? self.precision+20 : 170;  // don't zoom in too far
            CLLocationCoordinate2D coord;
            coord.latitude = self.latitude;
            coord.longitude = self.longitude;
            MKCoordinateRegion center = MKCoordinateRegionMakeWithDistance(coord, span, span);
            [self.map setRegion:center animated:YES];
        }
        [self.recorder recordDataForDate:self.locLastUpdate withLong:self.longitude withLat:self.latitude withPrecision:self.precision withSpeed:self.speed withAccelX:self.accx withAccelY:self.accy withAccelZ:self.accz withCCStatus:NO];
    }
}

// the two conversion functions below are taken from http://cocoawithlove.com/2009/09/whereismymac-snow-leopard-corelocation.html
// hah, apparently superfluous given MKCoordinateRegionMakeWithDistance. See http://developer.apple.com/iPhone/library/documentation/MapKit/Reference/MapKitFunctionsReference/Reference/reference.html#jumpTo_3

- (NSArray*)tripData {
    NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.3f %@", [UnitConversions convertSpeedToPreferredUnit:[self.speedstats mean]], [UnitConversions userPreferredSpeedUnitDescription]], [UnitConversions readableStringForSeconds:lrint([self.locLastUpdate timeIntervalSinceDate:self.tripStartDate])], [self.dateformatter stringFromDate:[NSDate date]], nil];
    return data;
}

- (NSArray*)GPSData {
    //NSString *speedunit = [UnitConversions userPreferredSpeedUnitDescription];
    NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.3f%d", self.longitude, 0x00b0], [NSString stringWithFormat:@"%.3f%d", self.latitude, 0x00b0], [NSString stringWithFormat:@"%.1f %@", [UnitConversions convertSpeedToPreferredUnit:self.speed], [UnitConversions userPreferredSpeedUnitDescription]], [NSString stringWithFormat:@"%.2f %@", [UnitConversions convertDistanceToPreferredUnit:self.precision], [UnitConversions userPreferredDistanceUnitDescription]], [self.dateformatter stringFromDate:self.locLastUpdate], nil];
    return data;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    if (!self.collectingData) {
        accelerometer.delegate = nil;
        return;
    }
    self.accx = acceleration.x;
    self.accy = acceleration.y;
    self.accz = acceleration.z;
    self.accLastUpdate = [NSDate date];
    if (self.source) {
        [self.source replaceRowsAtSection:2 withRows:[self accelData]];
        [self.source replaceRowsAtSection:0 withRows:[self tripData]];
    }
    //[self.recorder recordDataForDate:self.accLastUpdate withLong:self.longitude withLat:self.latitude withPrecision:self.precision withSpeed:self.speed withAccelX:self.accx withAccelY:self.accy withAccelZ:self.accz withCCStatus:self.ccStatus];
}

- (NSArray*)accelData {
    //NSArray *data = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%.3f", self.accx], [NSString stringWithFormat:@"%.3f", self.accy], [NSString stringWithFormat:@"%.3f", self.accz], [self.accLastUpdate description], nil];
    return [NSArray arrayWithObject:[self.dateformatter stringFromDate:self.accLastUpdate]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // wohoo
}

- (void)registerTableDS:(CurrentTripViewController*)tsource {
    //NSLog(@"Registering table on instance %@", self);
    self.source = tsource;
}

- (void)registerMap:(MKMapView*)mmap {
    self.map = mmap;
}

- (IBAction)toggleDataCapture:(id) sender {
    //NSLog(@"toggling");
    if (self.collectingData) {
        // turn off
        //NSLog(@"Turning off data coll");
        self.collectingData = NO;
        // reenable screen locking
        [((cctrackerAppDelegate*)[[UIApplication sharedApplication] delegate]) datacollectionEnded];
        // save current trip as "Last"
        [[NSUserDefaults standardUserDefaults] setObject:self.tripStartDate forKey:@"LTstart"];
        [[NSUserDefaults standardUserDefaults] setDouble:[self.speedstats mean] forKey:@"LTavgspeed"];
        [[NSUserDefaults standardUserDefaults] setInteger:lrint([[NSDate date] timeIntervalSinceDate:self.tripStartDate]) forKey:@"LTduration"];      
    } else {
        // turn on
        self.collectingData = YES;
        self.locmanager = [[[CLLocationManager alloc] init] autorelease];
        self.locmanager.delegate = self;
        self.locmanager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locmanager startUpdatingLocation];
        /*UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
        accel.delegate = self;
        accel.updateInterval = 1.0;*/
        // disable screen locking
        [((cctrackerAppDelegate*)[[UIApplication sharedApplication] delegate]) datacollectionStarted];
        self.tripStartDate = [NSDate date];
        self.tripid = [[NSUserDefaults standardUserDefaults] integerForKey:@"tripid"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.tripid+1 forKey:@"tripid"];
    }
}

- (void)applicationWillTerminate {
    if (self.collectingData) [self toggleDataCapture:nil];
    [self.recorder applicationWillTerminate];
}

-(void) dealloc {
    [self.locLastUpdate release];
    [self.accLastUpdate release];
    [self.uuid release];
    [self.locmanager release];
    [self.recorder release];
    [self.dateformatter release];
    [super dealloc];
}

@end
