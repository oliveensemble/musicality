//
//  ArtistsNavigationBar.m
//  Musicality
//
//  Created by Elle Lewis on 10/22/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

#import "ArtistsNavigationBar.h"
#import "ColorScheme.h"

@implementation ArtistsNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.artistsLabel.textColor =  [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
