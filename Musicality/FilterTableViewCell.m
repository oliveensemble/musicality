//
//  GenreTableViewCell.m
//  Musicality
//
//  Created by Evan Lewis on 11/6/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

#import "FilterTableViewCell.h"
#import "UserPrefs.h"

@implementation FilterTableViewCell

- (void)awakeFromNib {
  self.backgroundColor = [UIColor whiteColor];
  self.genreLabel.textColor = [UIColor blackColor];
}

- (void)setHighlighted:(BOOL)highlighted {
  if (highlighted) {
    self.backgroundColor = [UIColor blackColor];
    self.genreLabel.textColor = [UIColor whiteColor];
  }
}

@end
