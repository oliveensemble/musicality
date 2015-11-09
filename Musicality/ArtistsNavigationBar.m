//
//  ArtistsNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 10/22/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "ArtistsNavigationBar.h"
#import "UserPrefs.h"

@implementation ArtistsNavigationBar

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
    self.artistsLabel.textColor = [UIColor whiteColor];
  } else {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.artistsLabel.textColor = [UIColor blackColor];
  }
}

@end
