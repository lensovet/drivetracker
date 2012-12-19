//
//  DataCollector.h
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

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DataRecorder.h"
#import "ACMathSummaryStatisticsiPhone/ACSummaryPositiveStatistics.h"
#import "SynthesizeSingleton.h"
@class CurrentTripViewController;

@interface DataCollector : NSObject <CLLocationManagerDelegate, UIAccelerometerDelegate> {
}

+(DataCollector*) sharedDataCollector;
+ (NSArray*)params;
- (void)toggleCCStatus;
- (NSArray*)tripData;
- (NSArray*)GPSData;
- (NSArray*)accelData;
- (void)registerTableDS:(CurrentTripViewController*)source;
- (void)registerMap:(MKMapView*)map;
- (IBAction)toggleDataCapture:(id) sender;
- (void)applicationWillTerminate;

@property(readwrite, assign) double longitude;
@property(readwrite, assign) double latitude;
@property(readwrite, assign) double lastlongitude;
@property(readwrite, assign) double lastlatitude;
@property(readwrite, assign) double precision;
@property(readwrite, assign) double speed;
@property(readwrite, assign) double odb_speed;
@property(readwrite, retain) NSDate *locLastUpdate;
@property(readwrite, assign) NSDateFormatter *dateformatter;
@property(readwrite, assign) double accx;
@property(readwrite, assign) double accy;
@property(readwrite, assign) double accz;
@property(readwrite, retain) NSDate *accLastUpdate;
@property(readwrite, retain) NSDate *tripStartDate;
@property(readwrite, assign) int tripid;

@property(readwrite, nonatomic, retain) CurrentTripViewController *source;
@property(readwrite, nonatomic, assign) MKMapView *map;
@property(readwrite, nonatomic, assign) UIButton *cc;

@property(readwrite, assign) BOOL collectingData;
@property(readwrite, retain) CLLocationManager *locmanager;

@property(readwrite, assign) id<DataRecorder> recorder;

@property(readwrite, retain) NSString *uuid;

@property(readwrite, retain) ACSummaryPositiveStatistics *speedstats;

@end
