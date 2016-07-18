//
//  SearchArtistTableViewCell.m
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "SearchArtistTableViewCell.h"
#import "ColorScheme.h"

@implementation SearchArtistTableViewCell

- (void)awakeFromNib {
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  if (highlighted) {
    self.backgroundColor = [[ColorScheme sharedScheme] secondaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
  } else {
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  }
}

- (void)prepareForReuse {
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

@end
