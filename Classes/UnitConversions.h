//
//  UnitConversions.h
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

#import <Foundation/Foundation.h>
#define UNIT_INDEX_IMPERIAL 0
#define UNIT_INDEX_METRIC 1
#define UNIT_INDEX_SI 2

@interface UnitConversions : NSObject {

}
+ (double)convertSpeedToPreferredUnit:(double)original;
+ (double)convertSpeedToKmh:(double)original;
+ (double)convertSpeedToMph:(double)original;
+ (double)convertSpeedToSI:(double)original;
+ (NSString*)userPreferredSpeedUnitDescription;

+ (double)convertDistanceToPreferredUnit:(double)original;
+ (double)convertDistanceToMeters:(double)original;
+ (double)convertDistanceToFeet:(double)original;
+ (double)convertDistanceToSI:(double)original;
+ (NSString*)userPreferredDistanceUnitDescription;

+ (NSString*)preciseStringForSeconds:(int)seconds;
+ (NSString*)readableStringForSeconds:(int)seconds;

@end
