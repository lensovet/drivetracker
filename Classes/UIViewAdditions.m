//
//  UIViewAdditions.m
//  cctracker
//
//  Created by Paul Borokhov on 12/27/09.
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

#import "UIViewAdditions.h"


@implementation UIView (UIViewAdditions)

- (void)replaceSubviewsWithView:(UIView*)new {
    for (UIView *subview in self.subviews) {
        // presumably this works ok if .subviews is just an empty array
        [subview removeFromSuperview];
    }	
    [self addSubview:new];
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self layer] addAnimation:animation forKey:nil];
}

- (void)replaceSubviewsWithControllerView:(UIViewController*)new replacingOldView:(UIViewController*)old {
    [old viewWillDisappear:YES];
    [new viewWillAppear:YES];
    [self replaceSubviewsWithView:new.view];
    [old viewDidDisappear:YES];
    [new viewDidAppear:YES];
}

- (UIViewController *)viewController {
        // from http://stackoverflow.com/a/10964295/238683
    Class vcc = [UIViewController class];    // Called here to avoid calling it iteratively unnecessarily.
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: vcc])
            return (UIViewController *)responder;
    return nil;
}

@end