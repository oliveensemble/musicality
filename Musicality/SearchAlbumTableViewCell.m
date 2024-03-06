//
//  SearchAlbumTableViewCell.m
//  Musicality
//
//  Created by Elle Lewis on 7/18/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

#import "SearchAlbumTableViewCell.h"
#import "ColorScheme.h"

@implementation SearchAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
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
    [super prepareForReuse];
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

@end
