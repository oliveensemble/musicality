//
//  ColorScheme.m
//  Musicality
//
//  Created by Elle Lewis on 6/22/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

#import "ColorScheme.h"
#import "UserPrefs.h"
#import "MStore.h"

@implementation ColorScheme

+ (instancetype)sharedScheme {
  static ColorScheme *sharedScheme = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedScheme = [[self alloc] initPrivate];
  });
  
  if (sharedScheme != nil) {
    if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
      sharedScheme.primaryColor = [UIColor blackColor];
      sharedScheme.secondaryColor = [UIColor whiteColor];
    } else {
      sharedScheme.primaryColor = [UIColor whiteColor];
      sharedScheme.secondaryColor = [UIColor blackColor];
    }
  }
  
  return sharedScheme;
}

- (instancetype)initPrivate {
  self = [super init];
  if (self) {
    if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
      self.primaryColor = [UIColor blackColor];
      self.secondaryColor = [UIColor whiteColor];
    } else {
      self.primaryColor = [UIColor whiteColor];
      self.secondaryColor = [UIColor blackColor];
    }
  }
  return self;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton"
                                 reason:@"Use sharedScheme instead"
                               userInfo:nil];
  return nil;
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
