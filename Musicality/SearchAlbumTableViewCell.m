//
//  SearchAlbumTableViewCell.m
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "SearchAlbumTableViewCell.h"
#import "ColorScheme.h"

@implementation SearchAlbumTableViewCell

- (void)awakeFromNib {
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  if (highlighted) {
    self.backgroundColor = [[ColorScheme sharedScheme] secondaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
    self.albumLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
  } else {
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  }
}

- (void)prepareForReuse {
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

@end
