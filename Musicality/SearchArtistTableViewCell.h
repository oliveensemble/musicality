//
//  SearchArtistTableViewCell.h
//  Musicality
//
//  Created by Elle Lewis on 7/18/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

@import UIKit;
#import "Button.h"

@interface SearchArtistTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

@property (nonatomic) NSDictionary* cellInfo;

@end
