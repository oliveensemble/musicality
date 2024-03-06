//
//  Button.h
//  Musicality
//
//  Created by Elle Lewis on 10/27/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

@import UIKit;
@interface Button : UIButton

@property (nonatomic) NSDictionary* buttonInfo;

- (void)setSelectedStyle;
- (void)setDeselectedStyle;
- (void)configure;

@end
