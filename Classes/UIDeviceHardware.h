//
//  UIDeviceHardware.h
//
//  Used to determine EXACT version of device software is running on.
// code from http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
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

#import <Foundation/Foundation.h>

@interface UIDeviceHardware : NSObject 

+ (NSString *) platform;
+ (NSString *) platformString;

@end