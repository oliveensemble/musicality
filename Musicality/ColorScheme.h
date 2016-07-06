//
//  ColorScheme.h
//  Musicality
//
//  Created by Evan Lewis on 6/22/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import UIKit;

@interface ColorScheme : NSObject

@property (nonatomic) UIColor *primaryColor;
@property (nonatomic) UIColor *secondaryColor;

+ (instancetype)sharedScheme;

- (UIImage *)imageWithColor:(UIColor *)color;

@end