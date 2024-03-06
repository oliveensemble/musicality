//
//  ArtistNavigationBar.m
//  Musicality
//
//  Created by Elle Lewis on 10/21/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

#import "ArtistNavigationBar.h"
#import "ColorScheme.h"
#import "UserPrefs.h"

@implementation ArtistNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
