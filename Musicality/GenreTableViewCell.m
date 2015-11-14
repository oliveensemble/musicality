//
//  GenreTableViewCell.m
//  Musicality
//
//  Created by Evan Lewis on 11/6/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

#import "GenreTableViewCell.h"
#import "UserPrefs.h"

@implementation GenreTableViewCell

- (void)awakeFromNib {
  self.backgroundColor = [UIColor whiteColor];
  self.textLabel.textColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
