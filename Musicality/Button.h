//
//  Button.h
//  Musicality
//
//  Created by Evan Lewis on 10/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
@interface Button : UIButton

@property (nonatomic) NSDictionary* buttonInfo;

- (void)setSelectedStyle;
- (void)setDeselectedStyle;

@end
