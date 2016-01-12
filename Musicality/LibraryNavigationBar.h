//
//  LibraryNavigationBar.h
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface LibraryNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *addArtistsButton;
@property (weak, nonatomic) IBOutlet Button *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *libraryArtistsLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

- (void)beginLoading;
- (void)endLoading;

@end
