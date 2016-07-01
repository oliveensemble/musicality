//
//  GenreTableViewCell.m
//  Musicality
//
//  Created by Evan Lewis on 11/6/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

#import "FilterTableViewCell.h"
#import "UserPrefs.h"
#import "ColorScheme.h"

@implementation FilterTableViewCell

- (void)awakeFromNib {
    [self applyColorScheme];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        [self applyColorScheme];
    }
}

- (void)prepareForReuse {
    [self applyColorScheme];
}

- (void)applyColorScheme {
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.filterLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
}

@end
