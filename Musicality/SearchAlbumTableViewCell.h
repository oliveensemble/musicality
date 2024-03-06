//
//  SearchAlbumTableViewCell.h
//  Musicality
//
//  Created by Elle Lewis on 7/18/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

@import UIKit;
#import "Button.h"

@interface SearchAlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet Button *viewArtistButton;

@property (nonatomic) NSDictionary* cellInfo;

@end
