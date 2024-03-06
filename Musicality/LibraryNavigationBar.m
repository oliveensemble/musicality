//
//  LibraryNavigationBar.m
//  Musicality
//
//  Created by Elle Lewis on 11/27/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

#import "LibraryNavigationBar.h"
#import "ColorScheme.h"
#import "UserPrefs.h"

@implementation LibraryNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.libraryArtistsLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
