//
//  GenreTableViewCell.h
//  Musicality
//
//  Created by Elle Lewis on 11/6/15.
//  Copyright © 2015 Elle Lewis. All rights reserved.
//

@import UIKit;

@interface FilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (nonatomic) int filterId;

- (void)configure;

@end
