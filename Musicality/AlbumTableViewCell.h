//
//  AlbumTableViewCell.h
//  Musicality
//
//  Created by Evan Lewis on 10/31/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"

@interface AlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet Button *viewArtistButton;

@property (nonatomic) NSDictionary* cellInfo;

- (void)loadStyle;

@end
