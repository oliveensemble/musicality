//
//  SearchNavigationBar.h
//  Musicality
//
//  Created by Elle Lewis on 7/18/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

@import UIKit;
#import "MNavigationBar.h"
#import "Button.h"

@interface SearchNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *artistsButton;
@property (weak, nonatomic) IBOutlet Button *albumsButton;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

- (void)configureView;

@end
