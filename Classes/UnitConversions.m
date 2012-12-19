//
//  UnitConversions.m
//  cctracker
//
//  Created by Paul Borokhov on 1/2/10.
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

#import "UnitConversions.h"
#import <math.h>

@implementation UnitConversions
+ (double)convertSpeedToPreferredUnit:(double)original {
    if (isnan(original) || original < 0) original = 0;
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"useMetric"]) {
        case UNIT_INDEX_IMPERIAL:
            return [UnitConversions convertSpeedToMph:original];
        case UNIT_INDEX_METRIC:
            return [UnitConversions convertSpeedToKmh:original];
        default:
            return [UnitConversions convertSpeedToSI:original];
    }
}

+ (double)convertSpeedToKmh:(double)original {
    // http://www.google.com/search?q=1%20m/s%20in%20km/h
    return original*3.6;
}

+ (double)convertSpeedToMph:(double)original {
    // http://www.google.com/search?q=1%20m/s%20in%20mph
    return original*2.23693629;
}

+ (double)convertSpeedToSI:(double)original {
    // currently iphone OS reports speeds in m/s, so return directly
    return original;
}

+ (NSString*)userPreferredSpeedUnitDescription {
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"useMetric"]) {
        case UNIT_INDEX_IMPERIAL:
            return @"mph";
        case UNIT_INDEX_METRIC:
            return @"km/h";
        default:
            return @"m/s";
    }
}

+ (double)convertDistanceToPreferredUnit:(double)original {
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"useMetric"]) {
        case UNIT_INDEX_IMPERIAL:
            return [UnitConversions convertDistanceToFeet:original];
        case UNIT_INDEX_METRIC:
            return [UnitConversions convertDistanceToMeters:original];
        default:
            return [UnitConversions convertDistanceToSI:original];
    }
}
+ (double)convertDistanceToMeters:(double)original {
    // currently iphone OS returns distances in meters
    return original;
}

+ (double)convertDistanceToFeet:(double)original {
    // http://www.google.com/search?q=1%20m%20in%20ft
    return original*3.2808399;
}

+ (double)convertDistanceToSI:(double)original {
    // SI = meters, so just return
    return original;
}

+ (NSString*)userPreferredDistanceUnitDescription {
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"useMetric"]) {
        case UNIT_INDEX_IMPERIAL:
            return @"ft";
        case UNIT_INDEX_METRIC:
        default:
            return @"m";
    }
}

+ (NSString*)preciseStringForSeconds:(int)seconds {
    NSString *hour = @"";
    NSString *minute = @"";
    NSString *second = @"";
    int hours = seconds / (60 * 60);
    int minutes = (seconds / 60) % 60;
    int remseconds = seconds % 60;
    //NSLog(@"%d s = %d h %d m %d s", seconds, hours, minutes, remseconds);
    if (hours > 0) {
        /*if (hours > 1) hour = [NSString stringWithFormat:@"%d hours", hours];
         else hour = @"1 hour";*/
        hour = [NSString stringWithFormat:@"%d h ", hours];
    }
    if (minutes > 0) {
        /*if (minutes > 1) minute = [NSString stringWithFormat:@"%d minutes", minutes];
         else minute = @"1 minute";*/
        minute = [NSString stringWithFormat:@"%d m ", minutes];
    }
    if (remseconds > 0) {
        /*if (remseconds > 1) second = [NSString stringWithFormat:@"%d seconds", remseconds];
         else second = @"1 second";*/
        second = [NSString stringWithFormat:@"%d sec", remseconds];
    }
    return [NSString stringWithFormat:@"%@%@%@", hour, minute, second];
}

+ (NSString*)readableStringForSeconds:(int)seconds {
    NSString *hour = @"";
    NSString *minute = @"";
    NSString *second = @"";
    int hours = seconds / (60 * 60);
    int minutes = (seconds / 60) % 60;
    int remseconds = seconds % 60;

    if (hours > 0) {
        hour = [NSString stringWithFormat:@"%d h ", hours];
    }
    if (minutes > 0) {
        minute = [NSString stringWithFormat:@" %d min", minutes];
        if (minutes > 9) {
            // generate "estimated" strings
            if (remseconds > 0 && remseconds < 30) {
                return [NSString stringWithFormat:@"about %@%d min", hour, minutes];
            } else if (remseconds >= 30) {
                if (minutes == 59) return [NSString stringWithFormat:@"almost %d h", hours+1]; // round up to next hour
                else return [NSString stringWithFormat:@"almost %@%d min", hour, minutes+1];
            }
        }
    }
    if (remseconds > 0) {
        second = [NSString stringWithFormat:@" %d sec", remseconds];
    }
    return [NSString stringWithFormat:@"%@%@%@", hour, minute, second];
}

@end
