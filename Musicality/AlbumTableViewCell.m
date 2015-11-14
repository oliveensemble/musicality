//
//  AlbumTableViewCell.m
//  Musicality
//
//  Created by Evan Lewis on 10/31/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "UserPrefs.h"

@implementation AlbumTableViewCell

- (void)awakeFromNib {
  [self loadStyle];
}

- (void)loadStyle {
  if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
    self.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor blackColor];
    self.albumLabel.textColor = [UIColor whiteColor];
    self.artistLabel.textColor = [UIColor whiteColor];
  } else {
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.albumLabel.textColor = [UIColor blackColor];
    self.artistLabel.textColor = [UIColor blackColor];
  }
  [self.viewArtistButton loadStyle];
}

@end
