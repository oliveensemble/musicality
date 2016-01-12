//
//  ArtistsNavigationBar.h
//  Musicality
//
//  Created by Evan Lewis on 10/22/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface ArtistsNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *importFromLibraryButton;
@property (weak, nonatomic) IBOutlet Button *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *artistsLabel;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

- (void)beginLoading;
- (void)updateLoadingLabelWithString:(NSString*)text;
- (void)endLoading;

@end
