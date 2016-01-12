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
  self.layer.borderColor = [[UIColor blackColor] CGColor];
  [self setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
  [self setBackgroundImage:[self imageWithColor:[UIColor clearColor]] forState:UIControlStateHighlighted];
  self.layer.borderWidth = 2.0f;
}

- (void)setSelectedStyle {
  [self setBackgroundImage:[mStore imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
  [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)setDeselectedStyle {
  [self setBackgroundImage:[mStore imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
  [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  self.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)setHighlighted:(BOOL)highlighted {
  if (highlighted) {
    [self setBackgroundImage:[mStore imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
  } else {
    [self setBackgroundImage:[mStore imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
  }
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
