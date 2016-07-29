//
//  SearchFetch.h
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;

@protocol SearchFetchDelegate;

// Searches for artists and albums the user types in from the search view controller
@interface SearchFetch : NSOperation

@property (weak, nonatomic) id<SearchFetchDelegate> delegate;

- (instancetype)initWithDelegate:(id<SearchFetchDelegate>)delegate;
- (void)fetchItemsForSearchTerm:(NSString *)searchTerm withType:(NSUInteger)searchType;

@end

@protocol SearchFetchDelegate <NSObject>

- (void)didFinishSearchWithResults:(NSArray *)searchResults;

@end
