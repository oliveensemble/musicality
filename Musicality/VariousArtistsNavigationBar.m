//
//  VariousArtistsNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 8/8/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "VariousArtistsNavigationBar.h"
#import "UserPrefs.h"

@implementation VariousArtistsNavigationBar

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
    self.variousArtistsLabel.textColor = [UIColor whiteColor];
  } else {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.variousArtistsLabel.textColor = [UIColor blackColor];
  }
}

@end
