//
//  Button.m
//  Musicality
//
//  Created by Evan Lewis on 10/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "UserPrefs.h"
#import "MStore.h"
#import "Button.h"

@implementation Button

- (void)awakeFromNib {
  [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  [self setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateHighlighted];
  self.layer.borderColor = [[UIColor blackColor] CGColor];
  self.layer.borderWidth = 2.0f;
}

- (UIImage *)imageWithColor:(UIColor *)color {
  
  CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

@end
