//
//  ArtistListViewModel.h
//  Musicality
//
//  Created by Elle Lewis on 6/28/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

@import Foundation;

@protocol ArtistListViewModelDelegate;

@interface ArtistListViewModel : NSObject

- (instancetype)initWithDelegate:(id<ArtistListViewModelDelegate>)delegate;
- (void)beginUpdates;

@end

@protocol ArtistListViewModelDelegate <NSObject>

- (void)didUpdateList:(NSDictionary *)statusInfo;
- (void)didFinishUpdatingList;

@end
