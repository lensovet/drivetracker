//
//  UIToggleButton.h
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

#import <UIKit/UIButton.h>

@class UIBezierPath;

@interface UIToggleButton : UIButton {
    UIBezierPath *_fillPath;
}

- (void)_commonRoundedRectButtonInit;
- (id)initWithFrame:(struct CGRect)fp8;
- (void)dealloc;
- (void)_invalidatePaths;
- (void)setFrame:(struct CGRect)fp8;
- (struct CGSize)sizeThatFits:(struct CGSize)fp8;
- (int)buttonType;
- (void)setHighlighted:(BOOL)fp8;
- (void)drawRect:(struct CGRect)fp8;

@end
