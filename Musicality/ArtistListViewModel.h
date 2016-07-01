//
//  ArtistListViewModel.h
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
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