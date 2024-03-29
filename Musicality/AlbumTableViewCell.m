//
//  AlbumTableViewCell.m
//  Musicality
//
//  Created by Elle Lewis on 10/31/15.
//  Copyright © 2015 Later Creative LLC. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "ColorScheme.h"

@implementation AlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [[ColorScheme sharedScheme] secondaryColor];
        self.albumLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
        self.artistLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
    } else {
        self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
        self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
        self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.albumLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.artistLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.viewArtistButton configure];
}

@end
