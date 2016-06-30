//
//  ExploreViewModel.h
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;

@protocol ExploreViewModelDelegate;

@interface ExploreViewModel : NSObject

- (instancetype)initWithDelegate:(id<ExploreViewModelDelegate>)delegate;
- (void)beginWithFeedType:(NSUInteger)feedType andGenre:(int)genreID;

@end

@protocol ExploreViewModelDelegate <NSObject>

- (void)didFinishFetchingFeed:(NSArray *)albumArray;

@end
