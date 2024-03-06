//
//  ArtistsNavigationBar.h
//  Musicality
//
//  Created by Elle Lewis on 10/22/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface ArtistsNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *importFromLibraryButton;
@property (weak, nonatomic) IBOutlet UILabel *artistsLabel;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

@end
