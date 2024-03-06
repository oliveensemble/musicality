//
//  LibraryNavigationBar.h
//  Musicality
//
//  Created by Elle Lewis on 11/27/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface LibraryNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *addArtistsButton;
@property (weak, nonatomic) IBOutlet Button *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *libraryArtistsLabel;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

@end
