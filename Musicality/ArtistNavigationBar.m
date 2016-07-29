//
//  ArtistNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 10/21/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
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
