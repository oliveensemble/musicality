//
//  LibraryNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "LibraryNavigationBar.h"
#import "UserPrefs.h"

@implementation LibraryNavigationBar

- (void)awakeFromNib {
  [self loadStyle];
}

- (void)loadStyle {
  self.layer.shadowOpacity = 0.4;
  self.layer.shadowRadius = 2.0;
  self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  
  if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
    self.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
  } else {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
  }
}

@end
