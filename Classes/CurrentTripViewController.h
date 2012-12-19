//
//  TableViewController.h
//  cctracker
//
//  Created by Paul Borokhov on 11/21/09.
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

#import <UIKit/UIKit.h>

@interface CurrentTripViewController : UIViewController<UITableViewDataSource> {

}
- (void)replaceRowsAtSection:(int)section withRows:(NSArray*)rows;

@property (readwrite, retain, nonatomic) NSArray *categories;
@property (readwrite, retain, nonatomic) NSMutableArray *rows;
@property (readwrite, retain, nonatomic) NSArray *labels;
@end
