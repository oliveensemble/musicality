//
//  ArtistsNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 10/22/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
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
