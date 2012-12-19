//
//  UIToggleButton.m
//  cctracker
//
//  Created by Paul Borokhov on 12/25/09.
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

#import "UIToggleButton.h"
#import <objc/runtime.h>

@implementation UIToggleButton

+ (UIButton*) buttonWithType:(UIButtonType)buttonType {
    NSLog(@"blah");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"creating from nib!");
    if (self = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]) { //[super initWithFrame:frame]) {
        if (class_getInstanceSize([self class]) == class_getInstanceSize([UIToggleButton class])) {
            self->isa = [UIToggleButton class];
            // More init code...
            NSLog(@"isa changed successfully");
        } else {
            NSLog(@"sizes differ, original: %d, UITB: %d, class of self is %s", class_getInstanceSize([self class]), class_getInstanceSize([UIToggleButton class]), class_getName([self class]));
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"Hello");
    if (self = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain]) { //[super initWithFrame:frame]) {
        if (class_getInstanceSize([self class]) == class_getInstanceSize([UIToggleButton class])) {
            self->isa = [UIToggleButton class];
            // More init code...
            NSLog(@"isa changed successfully");
        } else {
            NSLog(@"sizes differ, original: %d, UITB: %d, class of self is %s", class_getInstanceSize([self class]), class_getInstanceSize([UIToggleButton class]), class_getName([self class]));
        }
    } else {
        NSLog(@"OH HAI");
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (class_getInstanceSize([self class]) == class_getInstanceSize([objc_lookUpClass([@"UIRoundedRectButton" cStringUsingEncoding:NSUTF8StringEncoding]) class])) {
        NSLog(@"we have a winner!");
        [super drawRect:rect];
    } else {
        NSLog(@"getting class %@", objc_lookUpClass([@"UIRoundedRectButton" cStringUsingEncoding:NSUTF8StringEncoding]));
    }
}

- (void)dealloc {
    [super dealloc];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.selected = !self.selected;
    //NSLog(@"%@", [self allControlEvents]);
}

@end
